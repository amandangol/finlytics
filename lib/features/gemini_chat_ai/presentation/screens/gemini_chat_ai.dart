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

class GeminiChatAiPage extends StatefulWidget {
  const GeminiChatAiPage({super.key});

  @override
  _GeminiChatAiPageState createState() => _GeminiChatAiPageState();
}

class _GeminiChatAiPageState extends State<GeminiChatAiPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final int _maxMessageLength = 250;

  final AiService _aiService = AiService();
  final SpeechService _speechService = SpeechService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String? _warning;
  bool _isListening = false;

  // Predefined query templates with descriptions
  final List<Map<String, String>> _predefinedQueries = [
    {
      "query": "Analyze my recent expenses",
      "description": "Get a comprehensive breakdown of your spending patterns"
    },
    {
      "query": "Show my income vs expenses",
      "description": "Compare your earnings and expenditures"
    },
    {
      "query": "Provide savings tips",
      "description": "Receive personalized financial advice"
    },
    {
      "query": "Categorize my spending",
      "description": "Understand where your money goes"
    },
    {
      "query": "Predict future expenses",
      "description": "Forecast potential financial needs"
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create a fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _animationController.forward();

    Provider.of<ChatState>(context, listen: false)
        .checkAndClearMessagesForNewUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
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

  // Enhanced method to show predefined query details
  void _showQueryDetailsDialog(Map<String, String> queryInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor.withOpacity(0.9),
        title: Text(queryInfo['query']!,
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        content: Text(
          queryInfo['description']!,
          style: GoogleFonts.roboto(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendMessage(queryInfo['query']!);
            },
            child: Text('Send Query',
                style: GoogleFonts.roboto(color: AppTheme.primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: GoogleFonts.roboto(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatState>(builder: (context, chatState, child) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          appBar: CustomAppBar(
            title: "FinlyticsAI",
            actions: [
              // Reset Chat Button with Hover Effect
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..scale(1.0),
                child: IconButton(
                  onPressed: _resetChat,
                  icon: const Icon(Icons.refresh),
                  color: AppTheme.accentColor,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..scale(1.0),
                child: IconButton(
                  onPressed: () => _showAppInfoDialog(),
                  icon: const Icon(Icons.info_outline),
                  color: AppTheme.primaryColor,
                ),
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
                // Animated Predefined Queries Row
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _predefinedQueries
                          .map((queryInfo) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () =>
                                      _showQueryDetailsDialog(queryInfo),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.3),
                                          width: 1),
                                    ),
                                    child: Text(
                                      queryInfo['query']!,
                                      style: GoogleFonts.roboto(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
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
        ),
      );
    });
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('FinlyticsAI Assistant',
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        content: Text(
          'Your personal AI-powered financial advisor. '
          'Get insights, analyze expenses, and receive personalized financial guidance.',
          style: GoogleFonts.roboto(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close',
                style: GoogleFonts.roboto(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }
}

// Detailed App Info View for OpenContainer
class AppInfoDetailView extends StatelessWidget {
  const AppInfoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FinlyticsAI Details',
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(
              icon: Icons.insights,
              title: 'Real-time Financial Insights',
              description:
                  'Get instant analysis of your spending patterns and financial health.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.chat,
              title: 'AI-Powered Advisor',
              description:
                  'Receive personalized financial advice tailored to your unique situation.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.savings,
              title: 'Savings Recommendations',
              description:
                  'Discover strategies to optimize your savings and reduce unnecessary expenses.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String description}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.roboto(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
