import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;

  Future<bool> checkPermissionAndListen(
    BuildContext context, {
    required Function(String) onResult,
    required Function(bool) onListeningStateChanged,
  }) async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        return _startListening(onResult, onListeningStateChanged);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission not granted')),
        );
        return false;
      }
    }
    return false;
  }

  Future<bool> _startListening(
    Function(String) onResult,
    Function(bool) onListeningStateChanged,
  ) async {
    if (!isListening) {
      bool isInitialized = await _speech.initialize(
        onStatus: (status) {
          isListening = status == 'listening';
          onListeningStateChanged(isListening);
        },
        onError: (errorNotification) {
          isListening = false;
          onListeningStateChanged(isListening);
        },
      );

      if (isInitialized && _speech.isAvailable) {
        _speech.listen(
          onResult: (val) {
            onResult(val.recognizedWords);
            if (val.finalResult) {
              isListening = false;
              onListeningStateChanged(isListening);
            }
          },
        );
        return true;
      }
    }
    return false;
  }

  void stopListening() {
    _speech.stop();
    isListening = false;
  }
}
