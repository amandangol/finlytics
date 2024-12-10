import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;
  final bool isLoading;

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/lottie2.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20.0),
            Text(
              "Welcome to FinlyticsAI Assistant",
              style: GoogleFonts.roboto(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              "Your personal financial advisor powered by AI",
              style: GoogleFonts.roboto(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              "Try asking about:",
              style: GoogleFonts.roboto(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10.0),
            _buildExampleChip("Analyze recent expenses"),
            _buildExampleChip("Show income vs expenses"),
            _buildExampleChip("Provide savings tips"),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return const _LoadingIndicator();
        }
        var message = messages[index];
        return MessageBubble(
          message: message["message"].toString(),
          isUserMessage: message["isUserMessage"] as bool,
        );
      },
    );
  }

  Widget _buildExampleChip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Chip(
        label: Text(
          text,
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitWave(
            color: Colors.blue,
            size: 30.0,
          ),
        ],
      ),
    );
  }
}
