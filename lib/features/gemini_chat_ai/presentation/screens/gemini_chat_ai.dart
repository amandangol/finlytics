import 'package:expense_tracker/core/common/custom_appbar.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/gemini_chat_ai/services/chatprovider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../services/speech_service.dart';
import '../widgets/message_input_field.dart';
import '../widgets/message_list.dart';
import '../widgets/predefined_queries_row.dart';

class GeminiChatAiPage extends StatefulWidget {
  const GeminiChatAiPage({super.key});

  @override
  _GeminiChatAiPageState createState() => _GeminiChatAiPageState();
}

class _GeminiChatAiPageState extends State<GeminiChatAiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final int _maxMessageLength = 250;

  final AiService _aiService = AiService();
  final SpeechService _speechService = SpeechService();

  bool _isLoading = false;
  String? _warning;
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
    Provider.of<ChatState>(context, listen: false)
        .checkAndClearMessagesForNewUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text,
      {bool isPredefinedQuery = false}) async {
    // Get ChatState from context
    final chatState = Provider.of<ChatState>(context, listen: false);

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
    });

    // Add user message using ChatState
    chatState.addMessage({"message": text, "isUserMessage": true});

    _controller.clear();
    _scrollToBottom();

    try {
      String? userId = await _getCurrentUserId();

      if (userId == null) {
        chatState.addMessage({
          "message": "Please log in to use this feature.",
          "isUserMessage": false
        });
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String response = await _aiService.generateResponse(text, userId);

      // Add AI response using ChatState
      chatState.addMessage({"message": response, "isUserMessage": false});

      setState(() {
        _isLoading = false;
      });

      await _aiService.handleSpecificIntents(text, response);
    } catch (e) {
      chatState.addMessage({
        "message": "An error occurred: ${e.toString()}",
        "isUserMessage": false
      });
      setState(() {
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _resetChat() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    chatState.clearMessages();
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

  Future<String?> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void _handleMicPress() {
    _speechService.checkPermissionAndListen(
      context,
      onResult: (recognizedWords) {
        setState(() {
          _controller.text = recognizedWords;
        });
      },
      onListeningStateChanged: (isListening) {
        setState(() {
          _isListening = isListening;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatState>(builder: (context, chatState, child) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "FinlyticsAI",
          actions: [
            IconButton(
              onPressed: _resetChat,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Chat',
            ),
            IconButton(
              onPressed: () {
                _showAppInfoDialog();
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 230, 236, 241),
                Color.fromARGB(255, 220, 239, 225),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: MessageList(
                  messages: chatState.messages,
                  scrollController: _scrollController,
                  isLoading: _isLoading,
                ),
              ),
              PredefinedQueriesRow(
                predefinedQueries: _predefinedQueries,
                onQuerySelected: (query) =>
                    _sendMessage(query, isPredefinedQuery: true),
              ),
              MessageInputField(
                controller: _controller,
                onSend: () => _sendMessage(_controller.text),
                onMicPress: _handleMicPress,
                isListening: _isListening,
                warning: _warning,
                maxMessageLength: _maxMessageLength,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('FinlyticsAI Assistant', style: GoogleFonts.roboto()),
        content: Text(
          'Your personal AI-powered financial advisor. '
          'Get insights, analyze expenses, and receive personalized financial guidance.',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: GoogleFonts.roboto()),
          ),
        ],
      ),
    );
  }
}
