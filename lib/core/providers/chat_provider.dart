import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class ChatMessage {
  final String text;
  final bool isUser;
  bool isRead;

  ChatMessage({required this.text, required this.isUser, this.isRead = false});
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _sessionId;
  
  // Endpoint configuration
  final String _baseUrl = 'https://chatbot-wzdu.onrender.com';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  bool get hasUnreadMessages => _messages.any((m) => !m.isUser && !m.isRead);

  void markMessagesAsRead() {
    bool changed = false;
    for (var msg in _messages) {
      if (!msg.isUser && !msg.isRead) {
        msg.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, {dynamic profile}) async {
    if (text.trim().isEmpty) return;

    // Add user message to UI immediately
    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    _isLoading = true;
    notifyListeners();

    // Ensure session ID is initialized
    _sessionId ??= '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';

    try {
      final body = <String, dynamic>{
        'message': text.trim(),
        'session_id': _sessionId,
      };
      if (profile != null) {
        // If the profile object has a toJson method, call it.
        body['profile'] = profile.toJson();
      }

      final bodyString = jsonEncode(body);
      
      print('--- ChatBot API Request ---');
      print('URL: $_baseUrl/chat');
      print('Method: POST');
      print('Body: $bodyString');
      print('---------------------------');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: bodyString,
      );

      print('--- ChatBot API Response ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('----------------------------');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['response'] as String?;
        final newSessionId = data['session_id'] as String?;

        if (newSessionId != null) {
          _sessionId = newSessionId;
        }

        if (reply != null && reply.isNotEmpty) {
          _messages.add(ChatMessage(text: reply, isUser: false));
        } else {
          _messages.add(ChatMessage(text: 'Sorry, I did not understand that.', isUser: false));
        }
      } else if (response.statusCode == 503 || response.statusCode == 502) {
        _messages.add(ChatMessage(
          text: 'The AI server is currently waking up. Please wait about 30 seconds and try again.', 
          isUser: false
        ));
      } else {
        _messages.add(ChatMessage(text: 'Error: Failed to get response from server.', isUser: false));
      }
    } catch (e) {
      _messages.add(ChatMessage(text: 'Network Error: $e', isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearSession() async {
    if (_sessionId != null) {
      try {
        await http.delete(Uri.parse('$_baseUrl/session/$_sessionId'));
      } catch (e) {
        debugPrint('Failed to delete session: $e');
      }
    }
    _messages.clear();
    _sessionId = null;
    notifyListeners();
  }
}
