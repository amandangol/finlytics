import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatState extends ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];
  String? _currentUserId;

  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  void addMessage(Map<String, dynamic> message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void checkAndClearMessagesForNewUser() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // If current user is different from previous user, clear messages
    if (currentUser != null && currentUser.uid != _currentUserId) {
      clearMessages();
      _currentUserId = currentUser.uid;
    }
  }

  void addMessages(List<Map<String, dynamic>> newMessages) {
    _messages.addAll(newMessages);
    notifyListeners();
  }
}
