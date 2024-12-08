import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsernameInputDialog extends StatefulWidget {
  final String userId;

  const UsernameInputDialog({super.key, required this.userId});

  @override
  _UsernameInputDialogState createState() => _UsernameInputDialogState();
}

class _UsernameInputDialogState extends State<UsernameInputDialog> {
  final TextEditingController _usernameController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Username',
          style: TextStyle(color: Color(0xFFEF6C06))),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Avoid unnecessary space
        children: [
          TextField(
            controller: _usernameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Username',
              errorText: _errorMessage, // Display error message below the field
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK', style: TextStyle(color: Color(0xFFEF6C06))),
          onPressed: () async {
            String username = _usernameController.text.trim();
            setState(() {
              // Update UI for error message
              if (username.isEmpty) {
                _errorMessage = 'Username cannot be empty';
              } else if (username.length > 25) {
                _errorMessage = 'Username should be smaller than 25 characters';
              } else {
                _errorMessage = null;
              }
            });

            if (username.isNotEmpty && username.length <= 25) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .update({'username': username});
              Navigator.of(context).pop(username);
            }
          },
        ),
      ],
    );
  }
}
