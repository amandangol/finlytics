import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '', // Fetch from .env
        ) {
    // Ensure API key is loaded correctly
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'API Key not found. Please set GEMINI_API_KEY in the .env file.');
    }
  }

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

  Future<Map<String, dynamic>> calculateFinancialMetrics(String userId) async {
    try {
      // Fetch user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {'error': 'User not found'};
      }

      UserModel userModel = UserModel.fromDocument(userDoc);

      // Fetch transactions
      List<Map<String, dynamic>> transactions =
          await fetchRecentTransactions(userId);

      // Calculate total balance across all accounts
      double totalBalance = userModel.totalBalance;

      // Income and Expense Calculations
      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      Map<String, double> categoryExpenses = {};

      for (var transaction in transactions) {
        double amount = transaction['amount'] ?? 0.0;
        String type = transaction['type'] ?? '';
        String category = transaction['category'] ?? 'Uncategorized';

        if (type == 'Income') {
          totalIncome += amount;
        } else if (type == 'Expense') {
          totalExpenses += amount;
          categoryExpenses[category] =
              (categoryExpenses[category] ?? 0) + amount;
        }
      }

      // Calculate Savings Rate
      double savingsRate = totalIncome > 0
          ? ((totalIncome - totalExpenses) / totalIncome * 100)
              .clamp(0.0, 100.0)
          : 0.0;

      // Net Worth Calculation ( totalBalance represents liquid assets)
      double netWorth = totalBalance;

      // Expense Breakdown by Category
      List<Map<String, dynamic>> expenseBreakdown = categoryExpenses.entries
          .map((entry) => {
                'category': entry.key,
                'amount': entry.value,
                'percentage':
                    (entry.value / totalExpenses * 100).toStringAsFixed(2)
              })
          .toList();

      // Financial Health Score
      double financialHealthScore = _calculateFinancialHealthScore(
          savingsRate: savingsRate,
          expenseRatio: totalExpenses / totalIncome,
          balanceToIncomeRatio:
              totalBalance / (totalIncome > 0 ? totalIncome : 1));

      return {
        'totalBalance': totalBalance,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'savingsRate': savingsRate.toStringAsFixed(2),
        'netWorth': netWorth,
        'expenseBreakdown': expenseBreakdown,
        'financialHealthScore': financialHealthScore.toStringAsFixed(2),
        'largestExpenseCategory': _findLargestExpenseCategory(categoryExpenses),
      };
    } catch (e) {
      print('Error calculating financial metrics: $e');
      return {'error': 'Failed to calculate financial metrics'};
    }
  }

  // Helper method to find the largest expense category
  String _findLargestExpenseCategory(Map<String, double> categoryExpenses) {
    if (categoryExpenses.isEmpty) return 'No expenses';

    return categoryExpenses.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Calculate a basic financial health score
  double _calculateFinancialHealthScore({
    required double savingsRate,
    required double expenseRatio,
    required double balanceToIncomeRatio,
  }) {
    // Base score components (0-100)
    double savingsScore = (savingsRate * 1.0).clamp(0.0, 40.0);

    // Lower expense ratio is better (aim for < 0.7)
    double expenseScore = expenseRatio < 0.7
        ? (40 * (1 - expenseRatio / 0.7)).clamp(0.0, 40.0)
        : 0.0;

    // Balance to income ratio (aim for > 0.5)
    double balanceScore = (balanceToIncomeRatio * 20).clamp(0.0, 20.0);

    return savingsScore + expenseScore + balanceScore;
  }

  Future<String> _prepareEnhancedQuery(
      String originalQuery, String userId) async {
    // Fetch recent transactions and financial metrics
    List<Map<String, dynamic>> recentTransactions =
        await fetchRecentTransactions(userId);
    Map<String, dynamic> financialMetrics =
        await calculateFinancialMetrics(userId);

    String transactionsContext =
        _formatTransactionsForGemini(recentTransactions);
    String metricsContext = _formatMetricsForGemini(financialMetrics);

    return """
    You are a financial assistant for my personal finance app, *FinlyticsAI*. 
    This app helps users manage budgets, track transactions, and improve financial habits.

    Recent Transactions Context: 
    ${transactionsContext.isEmpty ? "No recent transactions found." : transactionsContext}

    Financial Metrics Context:
    ${metricsContext.isEmpty ? "No financial metrics available." : metricsContext}

    User Query: "$originalQuery"

    Provide a detailed, actionable, and context-aware response based on the user's financial activity and query. 
    Ensure suggestions align with the app's capabilities and the user's specific financial situation.
    """;
  }

  // Format financial metrics for Gemini context
  String _formatMetricsForGemini(Map<String, dynamic> metrics) {
    if (metrics.containsKey('error')) return '';

    return '''
    Financial Overview:
    - Total Balance: \$${metrics['totalBalance'].toStringAsFixed(2)}
    - Total Income: \$${metrics['totalIncome'].toStringAsFixed(2)}
    - Total Expenses: \$${metrics['totalExpenses'].toStringAsFixed(2)}
    - Savings Rate: ${metrics['savingsRate']}%
    - Net Worth: \$${metrics['netWorth'].toStringAsFixed(2)}
    - Financial Health Score: ${metrics['financialHealthScore']}/100
    - Largest Expense Category: ${metrics['largestExpenseCategory']}
    ''';
  }

  // Additional method to provide AI-powered financial recommendations
  Future<String> generateFinancialRecommendations(String userId) async {
    try {
      Map<String, dynamic> metrics = await calculateFinancialMetrics(userId);

      if (metrics.containsKey('error')) {
        return "Unable to generate recommendations at this time.";
      }

      final content = [
        Content.text("""
        Based on the following financial metrics:
        - Savings Rate: ${metrics['savingsRate']}%
        - Total Expenses: \$${metrics['totalExpenses']}
        - Largest Expense Category: ${metrics['largestExpenseCategory']}
        - Financial Health Score: ${metrics['financialHealthScore']}/100

        Provide 3-5 personalized, actionable financial recommendations to improve financial health.
        """)
      ];

      final response = await _geminiModel.generateContent(content);
      return response.text?.trim() ?? "No recommendations available.";
    } catch (e) {
      print('Error generating financial recommendations: $e');
      return "Sorry, an error occurred while generating recommendations.";
    }
  }
}
