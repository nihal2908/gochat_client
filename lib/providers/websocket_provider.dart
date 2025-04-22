import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';

class WebSocketProvider extends ChangeNotifier {
  WebSocketService? _webSocketService;

  // Getter to access the WebSocketService instance
  WebSocketService get webSocketService {
    if (_webSocketService == null) {
      throw Exception("WebSocketService is not initialized!");
    }
    return _webSocketService!;
  }

  // Initialize WebSocketService (e.g., pass userId)
  void initialize(String userId) {
    if (_webSocketService == null) {
      _webSocketService = WebSocketService(userId: userId);
      _webSocketService!
          .connect(); // Automatically connect after initialization
      // notifyListeners();
    }
  }

  // Disconnect and clean up the WebSocketService instance
  void disposeService() {
    _webSocketService?.disconnect();
    _webSocketService = null;
    notifyListeners();
  }
}
