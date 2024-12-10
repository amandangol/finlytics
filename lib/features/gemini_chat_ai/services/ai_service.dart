import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../models/account_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/user_model.dart';

class AiService {
  final GenerativeModel _geminiModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AiService()
      : _geminiModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: 'AIzaSyALcSdmiKasf9T6DxVT1x5C-CfRveNNBcs', // Secure this key
        );

  Future<String> generateResponse(String query, String? userId) async {
    try {
      userId = userId ?? getCurrentUserId();
      if (userId == null) {
        return "Please log in to access your personalized financial assistant.";
      }

      // Build context-aware query
      String enhancedQuery = await _prepareEnhancedQuery(query, userId);

      // Send query to Gemini AI
      final content = [Content.text(enhancedQuery)];
      final response = await _geminiModel.generateContent(content);

      return response.text?.trim() ?? "I couldn't generate a response.";
    } catch (e) {
      print('Error in generateResponse: $e');
      return "Sorry, an error occurred while processing your request.";
    }
  }

  Future<String> _prepareEnhancedQuery(
      String originalQuery, String userId) async {
    List<Map<String, dynamic>> recentTransactions =
        await fetchRecentTransactions(userId);
    String transactionsContext =
        _formatTransactionsForGemini(recentTransactions);

    return """
    You are a financial assistant for my personal finance app, *FinlyticsAI*. 
    This app helps users manage budgets, track transactions, and improve financial habits.

    Context: 
    ${transactionsContext.isEmpty ? "No recent transactions found." : transactionsContext}

    User Query: "$originalQuery"

    Provide a detailed, actionable, and context-aware response based on the user's financial activity and query. Ensure suggestions align with the app's capabilities, avoiding generic financial advice.
    """;
  }

  String _formatTransactionsForGemini(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return "No recent transactions to display.";

    return transactions.map((transaction) {
      return "- ${transaction['type']} of ${transaction['amount']} in ${transaction['category']} on ${transaction['date']}";
    }).join('\n');
  }

  Future<void> handleSpecificIntents(String query, String response) async {
    query = query.toLowerCase();
    String? userId = getCurrentUserId();
    if (userId == null) return;

    try {
      if (query.contains("add transaction")) {
        await _extractAndAddTransaction(response);
      } else if (query.contains("savings tip") ||
          query.contains("reduce expense")) {
        await _logFinancialAdvice(userId, response);
      }
    } catch (e) {
      print('Error in handleSpecificIntents: $e');
    }
  }

  Future<void> _extractAndAddTransaction(String response) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    RegExp amountRegex = RegExp(r'?(\d+(\.\d+)?)');
    RegExp categoryRegex = RegExp(r'(Expense|Income)', caseSensitive: false);

    double amount =
        double.tryParse(amountRegex.firstMatch(response)?.group(1) ?? '0') ??
            0.0;
    String type = categoryRegex.firstMatch(response)?.group(1) ?? 'Expense';
    String category = _inferCategory(response);

    final transaction = TransactionModel(
      id: '',
      userId: user.uid,
      amount: amount,
      type: type,
      category: category,
      details: response,
      account: 'Main',
      havePhotos: false,
    );

    await _firestore.collection('transactions').add(transaction.toDocument());
    await _updateAccountBalance('Main', type == 'Expense' ? -amount : amount);
  }

  String _inferCategory(String response) {
    final categoryMap = {
      'food': 'Food & Dining',
      'grocery': 'Groceries',
      'travel': 'Transportation',
      'bill': 'Utilities',
      'shopping': 'Shopping',
      'movie': 'Entertainment',
    };

    for (var entry in categoryMap.entries) {
      if (response.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Other';
  }

  Future<void> _logFinancialAdvice(String userId, String advice) async {
    await _firestore.collection('financial_advice').add({
      'userId': userId,
      'advice': advice,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<List<Map<String, dynamic>>> fetchRecentTransactions(
      String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<void> _updateAccountBalance(String accountName, double amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      UserModel userModel = UserModel.fromDocument(userDoc);
      Account? accountToUpdate = userModel.accounts.firstWhere(
        (account) => account.name == accountName,
        orElse: () => Account(name: accountName, balance: 0),
      );

      accountToUpdate.balance += amount;

      await userRef.update({
        'accounts':
            userModel.accounts.map((account) => account.toMap()).toList()
      });
    }
  }
}
