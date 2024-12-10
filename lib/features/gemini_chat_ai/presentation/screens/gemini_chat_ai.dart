import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../models/account_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../../models/user_model.dart';

class GeminiAiPage extends StatefulWidget {
  const GeminiAiPage({super.key});

  @override
  _GeminiAiPageState createState() => _GeminiAiPageState();
}

class _GeminiAiPageState extends State<GeminiAiPage> {
  late GenerativeModel _geminiModel;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final int _maxMessageLength = 250;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _warning;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Predefined query templates
  final List<String> _predefinedQueries = [
    "Analyze my recent expenses",
    "Show my income vs expenses",
    "Provide savings tips",
    "Categorize my spending",
    "Predict future expenses",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize Gemini AI
    // IMPORTANT: Replace 'YOUR_GEMINI_API_KEY' with your actual Gemini API key
    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyALcSdmiKasf9T6DxVT1x5C-CfRveNNBcs',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String text,
      {bool isPredefinedQuery = false}) async {
    if (text.isEmpty || text.length > _maxMessageLength) {
      setState(() {
        _warning = text.length > _maxMessageLength
            ? "Message cannot exceed $_maxMessageLength characters."
            : null;
      });
      return;
    }

    setState(() {
      _warning = null;
      _isLoading = true;
      _messages.add({"message": text, "isUserMessage": true});
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Get current user
      String userId = await getCurrentUserId();

      // Prepare context-aware query
      String enhancedQuery = await _prepareEnhancedQuery(text, userId);

      // Send query to Gemini
      final content = [Content.text(enhancedQuery)];
      final response = await _geminiModel.generateContent(content);

      setState(() {
        _messages.add({
          "message": response.text ?? "I couldn't generate a response.",
          "isUserMessage": false
        });
        _isLoading = false;
      });

      // Check for specific intents and perform actions
      await _handleSpecificIntents(text, response.text ?? "");
    } catch (e) {
      setState(() {
        _messages.add({
          "message": "Sorry, I encountered an error: $e",
          "isUserMessage": false
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _prepareEnhancedQuery(
      String originalQuery, String userId) async {
    // Fetch recent transactions to provide context
    List<Map<String, dynamic>> recentTransactions =
        await fetchRecentTransactions(userId);

    // Convert transactions to a readable format
    String transactionsContext =
        _formatTransactionsForGemini(recentTransactions);

    // Enhance the original query with transaction context
    return """
    I'm using a personal finance app. Here's context about my recent transactions:
    $transactionsContext

    Query: $originalQuery

    Please provide a helpful, detailed, and personalized response based on my recent financial activity.
    """;
  }

  String _formatTransactionsForGemini(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return "No recent transactions found.";

    return transactions.map((transaction) {
      return "- ${transaction['type']} of ₹${transaction['amount']} in ${transaction['category']} on ${transaction['date']}";
    }).join('\n');
  }

  Future<void> _handleSpecificIntents(String query, String response) async {
    query = query.toLowerCase();
    String userId = await getCurrentUserId();

    if (query.contains("add transaction")) {
      // Extract transaction details from Gemini's response
      await _extractAndAddTransaction(response);
    } else if (query.contains("savings tip") ||
        query.contains("reduce expense")) {
      // Log savings advice for future reference
      await _logFinancialAdvice(userId, response);
    }
  }

  Future<void> _extractAndAddTransaction(String response) async {
    // Use Gemini to extract transaction details
    // This is a simplified example and might need more robust parsing
    RegExp amountRegex = RegExp(r'₹?(\d+(\.\d+)?)');
    RegExp categoryRegex = RegExp(r'(Expense|Income)', caseSensitive: false);

    double amount =
        double.tryParse(amountRegex.firstMatch(response)?.group(1) ?? '0') ??
            0.0;
    String type = categoryRegex.firstMatch(response)?.group(1) ?? 'Expense';
    String category = 'Other'; // Default category

    try {
      User? user = FirebaseAuth.instance.currentUser;
      final transaction = TransactionModel(
        id: '',
        userId: user!.uid,
        amount: amount,
        type: type,
        category: category,
        details: response,
        account: 'Main',
        havePhotos: false,
      );

      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transaction.toDocument());

      // Update account balance
      await _updateAccountBalance('Main', type == 'Expense' ? -amount : amount);
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  Future<void> _logFinancialAdvice(String userId, String advice) async {
    await FirebaseFirestore.instance.collection('financial_advice').add({
      'userId': userId,
      'advice': advice,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  Future<List<Map<String, dynamic>>> fetchRecentTransactions(
      String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _updateAccountBalance(String accountName, double amount) async {
    final user = FirebaseAuth.instance.currentUser;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildPredefinedQueriesRow(),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildPredefinedQueriesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: _predefinedQueries.map((query) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () => sendMessage(query, isPredefinedQuery: true),
              child: Text(query, style: GoogleFonts.roboto()),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageList() {
    return _messages.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Gemini Finance Assistant!",
                  style:
                      GoogleFonts.roboto(fontSize: 18.0, color: Colors.black54),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Try asking about your finances",
                  style:
                      GoogleFonts.roboto(fontSize: 16.0, color: Colors.black45),
                ),
                const SizedBox(height: 5.0),
                Text(
                  "Examples:",
                  style:
                      GoogleFonts.roboto(fontSize: 16.0, color: Colors.black45),
                ),
                Text(
                  "- Analyze my recent expenses",
                  style:
                      GoogleFonts.roboto(fontSize: 14.0, color: Colors.black45),
                ),
                Text(
                  "- Provide savings tips",
                  style:
                      GoogleFonts.roboto(fontSize: 14.0, color: Colors.black45),
                ),
              ],
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isLoading) {
                return _buildLoadingIndicator();
              }
              var message = _messages[index];
              return _buildMessageItem(message["message"].toString(),
                  message["isUserMessage"] as bool);
            },
          );
  }

  Widget _buildMessageItem(String message, bool isUserMessage) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isUserMessage
            ? const EdgeInsets.fromLTRB(35, 7, 2, 7)
            : const EdgeInsets.fromLTRB(2, 7, 35, 7),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color:
              isUserMessage ? const Color(0xFFFFA726) : const Color(0xFFE0E0E0),
          borderRadius: isUserMessage
              ? const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message,
          style: GoogleFonts.roboto(
            fontSize: 16.0,
            color: isUserMessage ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Speech-to-text methods remain the same as in the previous implementation
  Future<void> _checkPermissionAndListen() async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        _startListening();
      } else {
        setState(() {
          _warning = 'Microphone permission not granted';
        });
      }
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
              if (val.finalResult) {
                _isListening = false;
              }
            });
          },
        );
      } else {
        setState(() => _isListening = false);
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Widget _buildInputField() {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    // Adjust padding based on keyboard visibility
    final transform = isKeyboardOpen
        ? Matrix4.translationValues(0.0, 60.0, 0.0)
        : Matrix4.translationValues(0.0, 0.0, 0.0);

    return Container(
      transform: transform,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xF0D7D5D5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_warning != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _warning!,
                style: GoogleFonts.roboto(color: Colors.red, fontSize: 14.0),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLength: _maxMessageLength,
                  cursorColor: const Color(0xFFEF6C06),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    hintText:
                        _isListening ? "Listening..." : "Type your message...",
                    hintStyle: GoogleFonts.roboto(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                    suffixIcon: GestureDetector(
                      onLongPressStart: (_) => _checkPermissionAndListen(),
                      onLongPressEnd: (_) => _stopListening(),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                margin: const EdgeInsets.fromLTRB(2, 2, 4, 22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitThreeBounce(
            color: Color(0xFFFFA726),
            size: 20.0,
          ),
        ],
      ),
    );
  }
}
