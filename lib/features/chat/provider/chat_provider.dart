import 'package:flutter/material.dart';

class ChatState extends ChangeNotifier {
  String? _openChatId;

  String? get openChatId => _openChatId;

  void openChat(String chatId) {
    _openChatId = chatId;
    // notifyListeners();
  }

  void closeChat() {
    _openChatId = null;
    notifyListeners();
  }
}
