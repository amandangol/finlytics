import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: isUserMessage
            ? const EdgeInsets.fromLTRB(35, 7, 2, 7)
            : const EdgeInsets.fromLTRB(2, 7, 35, 7),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isUserMessage
              ? const Color(0xFF2196F3) // Changed to a more professional blue
              : const Color(0xFFF5F5F5), // Light grey for AI messages
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft:
                isUserMessage ? const Radius.circular(16.0) : Radius.zero,
            bottomRight:
                isUserMessage ? Radius.zero : const Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: MarkdownBody(
          data: message,
          styleSheet: MarkdownStyleSheet(
            p: GoogleFonts.roboto(
              fontSize: 16.0,
              color: isUserMessage ? Colors.white : Colors.black87,
            ),
            h1: GoogleFonts.roboto(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: isUserMessage ? Colors.white : Colors.black87,
            ),
            h2: GoogleFonts.roboto(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: isUserMessage ? Colors.white : Colors.black87,
            ),
            // Add more style configurations as needed
          ),
        ),
      ),
    );
  }
}
