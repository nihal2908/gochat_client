import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/calls/webrtc_handler.dart';
import 'package:whatsapp_clone/secrets/secrets.dart';

class WebSocketService {
  final String userId;
  late WebSocketChannel _channel;
  final DBHelper _dbHelper = DBHelper();
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isReconnecting = false;
  bool _isConnected = false;

  late final WebRTCHandler webrtcHandler;

  static WebSocketService? _instance;

  // Private constructor
  WebSocketService._internal({required this.userId});

  // Singleton factory method
  factory WebSocketService({required String userId}) {
    return _instance ??= WebSocketService._internal(userId: userId);
  }

  WebSocketChannel get channel => _channel;

  void connect() {
    // If already connected, return early
    if (_isConnected) {
      return;
    }
    _channel = WebSocketChannel.connect(
      Uri.parse(
        '${Secrets.websocketUrl}/ws?userId=$userId',
      ),
    );
    _isConnected = true;
    _listenToEvents();
    _sendPendingMessages();
  }

  void _listenToEvents() {
    _channel.stream.listen(
      (event) async {
        final decoded = jsonDecode(event);
        if (kDebugMode) {
          print(decoded);
        }
        switch (decoded['type']) {
          case 'message':
            await _handleMessageReceived(decoded['data']);
            break;
          case 'ack_sent':
            await _handleMessageAck(decoded['data'], 'sent');
            break;
          case 'ack_delivered':
            await _handleMessageAck(decoded['data'], 'delivered');
            break;
          case 'ack_read':
            await _handleMessageReadAck(decoded['data']);
            break;
          case 'user_typing':
            await _handleTypingStatus(decoded['data']);
            break;
          case 'edit_message':
            await _handleMessageEdit(decoded['data']);
            break;
          case 'delete_message':
            await _handleMessageDelete(decoded['data']);
            break;
          case 'webrtc_offer':
          case 'webrtc_answer':
          case 'webrtc_candidate':
          case 'webrtc_hangup':
          case 'webrtc_decline':
            webrtcHandler.handleSignal(decoded);
            break;
          case 'group_created':
            break;
          case 'group_updated':
            break;
          case 'group_deleted':
            break;
          case 'user_joined_group':
            break;
          case 'user_left_group':
            break;
          default:
            if (kDebugMode) {
              print('Unknown event type: ${decoded['type']}');
            }
        }
      },
      onDone: () {
        if (kDebugMode) {
          print('WebSocket connection closed.');
        }
        _isConnected = false;
        _reconnect(); // Attempt to reconnect
      },
      onError: (error) {
        if (kDebugMode) {
          print('WebSocket error: $error');
        }
        _isConnected = false;
        _reconnect(); // Attempt to reconnect
      },
    );
  }

  void _reconnect() {
    if (_isReconnecting) return;
    _isReconnecting = true;

    Future.delayed(
      const Duration(seconds: 5),
      () {
        if (kDebugMode) {
          print('Attempting to reconnect...');
        }
        try {
          connect();
          _isReconnecting = false; // Reset flag on successful connection
          if (kDebugMode) {
            print('Reconnected successfully.');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Reconnection failed: $e');
          }
          _isReconnecting = false; // Reset flag on failure, to allow retry
          _reconnect(); // Retry reconnection
        }
      },
    );
  }

  void setWebRTCHandler(WebRTCHandler handler) {
    webrtcHandler = handler;
  }

  Future<void> _handleMessageReceived(Map<String, dynamic> data) async {
    await _dbHelper.insertMessage(data, false);
    _sendAck(data, 'ack_delivered');

    final String senderId = data['sender_id'];
    final String? chatId = data['chat_id'];
    final String? groupId = data['group_id'];

    String? notificationTitle, notificationBody;
    String? targetId; // For grouping

    if (groupId != null) {
      final group = await _dbHelper.getGroupById(groupId);
      if (group != null) {
        targetId = groupId;
        notificationTitle = group['title'];
        notificationBody =
            data['type'] == 'text' ? data['content'] : 'Click to view message!';
      }
    } else if (chatId != null) {
      final user = await _dbHelper.getUserById(senderId);
      if (user != null) {
        targetId = chatId;
        notificationTitle = user['title'];
        notificationBody =
            data['type'] == 'text' ? data['content'] : 'Click to view message!';
      }
    }

    // Show grouped notification
    if (notificationTitle != null &&
        notificationBody != null &&
        targetId != null) {
      await showGroupedNotification(
        chatId: targetId,
        messageId: data['_id'],
        title: notificationTitle,
        body: notificationBody,
      );
    }
  }

  Future<void> showGroupedNotification({
    required String chatId,
    required String messageId,
    required String title,
    required String body,
  }) async {
    final int notificationId = messageId.hashCode;
    final int groupKeyHash = chatId.hashCode;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          groupKey: groupKeyHash.toString(), // String group key
        ),
      ),
    );

    // Group summary (optional, shown on Android)
    await _localNotifications.show(
      groupKeyHash,
      title,
      'New messages',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for grouped notifications',
          styleInformation: const DefaultStyleInformation(true, true),
          groupKey: groupKeyHash.toString(),
          setAsGroupSummary: true,
        ),
      ),
    );
  }

  // Future<void> _handleMessageReceived(Map<String, dynamic> data) async {
  //   await _dbHelper.insertMessage(data, false);
  //   _sendAck(data, 'ack_delivered');

  //   final String senderId = data['sender_id'];
  //   final String? chatId = data['chat_id'];
  //   final String? groupId = data['group_id'];

  //   String? notificationTitle, notificationBody;

  //   if (groupId != null) {
  //     final group = await _dbHelper.getGroupById(groupId);
  //     if (group != null) {
  //       notificationTitle = group['title'];
  //       notificationBody =
  //           data['type'] == 'text' ? data['content'] : 'Click to view message!';
  //     }
  //   }

  //   if (chatId != null) {
  //     // Step 3a: Check if chat exists
  //     final user = await _dbHelper.getUserById(senderId);

  //     if (user != null) {
  //       notificationTitle = user['title'];
  //       notificationBody = data['type'] == 'text'
  //           ? data['content']
  //           : data['caption'] != null
  //               ? data['caption'] as String
  //               : 'Click to view message!';
  //     }
  //   }

  //   if (notificationTitle != null && notificationBody != null) {
  //     // show notification
  //     await _localNotifications.show(
  //       0,
  //       notificationTitle,
  //       notificationBody,
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'high_importance_channel',
  //           'High Importance Notifications',
  //           channelDescription:
  //               'This channel is used for important notifications.',
  //           importance: Importance.high,
  //           priority: Priority.high,
  //           icon: '@mipmap/ic_launcher',
  //         ),
  //         iOS: DarwinNotificationDetails(
  //           presentAlert: true,
  //           presentBadge: true,
  //           presentSound: true,
  //         ),
  //       ),
  //     );
  //   }

  // }

  Future<void> _handleMessageAck(
    Map<String, dynamic> data,
    String status,
  ) async {
    final String messageId = data['message_id'];
    final String? groupId = data['group_id'];

    // Update the message status in the database
    if (status == 'sent') {
      await _dbHelper.updateMessageServerTSandStatus(
          messageId, groupId, status, data['server_ts']);
    } else {
      await _dbHelper.updateMessageStatus(messageId, groupId, status);
    }
  }

  Future<void> _handleMessageReadAck(Map<String, dynamic> data) async {
    final String chatId = data['chat_id'];

    // Update the message status in the database
    await _dbHelper.ackReadAllMessages(chatId);
  }

  _handleTypingStatus(Map<String, dynamic> data) async {}

  _handleMessageEdit(Map<String, dynamic> data) async {
    if (data['type'] == 'text') {
      await _dbHelper.updateMessage(
        data['_id'],
        {
          'content': data['content'],
          'edited': 1,
        },
      );
    } else {
      await _dbHelper.updateMessage(
        data['_id'],
        {
          'caption': data['caption'],
          'edited': 1,
        },
      );
    }
    _sendAck(data, 'ack_delivered');
  }

  _handleMessageDelete(Map<String, dynamic> data) async {
    await _dbHelper.updateMessage(
      data['_id'],
      {
        'deleted_for_everyone': 1,
        'content': 'This message was deleted.',
        'caption': 'This message was deleted.',
      },
    );
    await _dbHelper.deleteMedia(data['_id']);
  }

  Future<void> sendMessage(Map<String, dynamic> message) async {
    await _dbHelper.insertMessage(message, true);

    _channel.sink.add(
      jsonEncode({
        'type': 'message',
        'data': message,
      }),
    );
  }

  Future<void> send(Map<String, dynamic> message) async {
    _channel.sink.add(
      jsonEncode(message),
    );
  }

  Future<void> sendDeleteMessage(Map<String, dynamic> message) async {
    await _dbHelper.updateMessage(
      message['_id'],
      {
        'deleted_for_everyone': 1,
        'content': 'This message was deleted.',
        'status': 'pending',
      },
    );
    await _dbHelper.deleteMedia(message['_id']);

    _channel.sink.add(
      jsonEncode({
        'type': 'delete_message',
        'data': {
          '_id': message['_id'],
          'sender_id': message['sender_id'],
          'receiver_id': message['receiver_id'],
          'chat_id': message['chat_id'],
          'group_id': message['group_id'],
          'timestamp': DateTime.now().toIso8601String(),
        },
      }),
    );
  }

  Future<void> sendEditMessage(Map<String, dynamic> message) async {
    await _dbHelper.updateMessage(
      message['_id'],
      {
        'edited': 1,
        'content': message['content'],
        'caption': message['caption'],
        'status': 'pending',
      },
    );

    _channel.sink.add(
      jsonEncode({
        'type': 'edit_message',
        'data': message,
      }),
    );
  }

  void sendReadAcknowledement({
    required String chatId,
    required String senderId,
    required String receiverId,
  }) async {
    await _dbHelper.marksAllMessagesRead(chatId);

    _channel.sink.add(
      jsonEncode({
        'type': 'ack_read',
        'data': {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'chat_id': chatId,
          'group_id': null,
          'timestamp': DateTime.now().toIso8601String(),
        },
      }),
    );
  }

  void _sendPendingMessages() async {
    final pendingMessages = await _dbHelper.getPendingMessages();
    for (var message in pendingMessages) {
      _channel.sink.add(
        jsonEncode(
          {
            'type': 'message',
            'data': message,
          },
        ),
      );
    }
  }

  void _sendAck(Map<String, dynamic> message, String ack) {
    _channel.sink.add(
      jsonEncode(
        {
          'type': ack,
          'data': {
            'message_id': message['_id'],
            'sender_id': message['sender_id'],
            'receiver_id': message['receiver_id'],
            'chat_id': message['chat_id'],
            'group_id': message['group_id'],
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
      ),
    );
  }

  void sendTypingEvent(String receiverId, int isTyping) {
    _channel.sink.add(jsonEncode({
      'type': 'typing',
      'sender_id': userId,
      'recever_id': receiverId,
      'isTyping': isTyping,
    }));
  }

  void disconnect() {
    _channel.sink.close();
  }
}
