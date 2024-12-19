import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMicPress;
  final bool isListening;
  final String? warning;
  final int maxMessageLength;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onMicPress,
    this.isListening = false,
    this.warning,
    this.maxMessageLength = 250,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    final transform = isKeyboardOpen
        ? Matrix4.translationValues(0.0, 60.0, 0.0)
        : Matrix4.translationValues(0.0, 0.0, 0.0);

    return Container(
      transform: transform,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 230, 236, 241),
            Color.fromARGB(255, 220, 239, 225),
          ],
        ),
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
          if (warning != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                warning!,
                style: GoogleFonts.roboto(color: Colors.red, fontSize: 14.0),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  // maxLength: maxMessageLength,
                  cursorColor: const Color(0xFFEF6C06),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    hintText:
                        isListening ? "Listening..." : "Type your message...",
                    hintStyle: GoogleFonts.roboto(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                    suffixIcon: GestureDetector(
                      onTap: () => onMicPress(),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          isListening ? Icons.mic_off : Icons.mic,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                margin: const EdgeInsets.fromLTRB(2, 0, 4, 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade600, // Top color
                      Colors.blue.shade900, // Bottom color
                    ],
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
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
