import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';

class UsernameBottomSheet extends StatefulWidget {
  final String userId;

  const UsernameBottomSheet({super.key, required this.userId});

  static Future<String?> show(BuildContext context, String userId) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => UsernameBottomSheet(userId: userId),
    );
  }

  @override
  _UsernameBottomSheetState createState() => _UsernameBottomSheetState();
}

class _UsernameBottomSheetState extends State<UsernameBottomSheet> {
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _isUsernameUnique(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  void _validateAndSubmit() async {
    String username = _usernameController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validation checks
      if (username.isEmpty) {
        setState(() {
          _errorMessage = 'Username cannot be empty';
          _isLoading = false;
        });
        return;
      }

      if (username.length > 25) {
        setState(() {
          _errorMessage = 'Username should be smaller than 25 characters';
          _isLoading = false;
        });
        return;
      }

      // Check for username uniqueness
      bool isUnique = await _isUsernameUnique(username);
      if (!isUnique) {
        setState(() {
          _errorMessage = 'Username is already taken';
          _isLoading = false;
        });
        return;
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'username': username});

      Navigator.of(context).pop(username);
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Your Username',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_]*$')),
            ],
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Choose a unique username',
              errorText: _errorMessage,
              prefixIcon: const Icon(Icons.alternate_email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _validateAndSubmit(),
          ),
          const SizedBox(height: 10),
          if (_isLoading) const LinearProgressIndicator(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(_isLoading ? 'Submitting...' : 'Create'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }
}
