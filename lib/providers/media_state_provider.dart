import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'dart:convert';
import 'package:whatsapp_clone/secrets/secrets.dart';

class MediaController extends ChangeNotifier {
  static final MediaController _instance = MediaController._internal();
  factory MediaController() => _instance;
  MediaController._internal();
  final _dbHelper = DBHelper();

  late final WebSocketService _webSocketService;

  void init(WebSocketService webSocketService) {
    _webSocketService = webSocketService;
  }

  // Map to track uploading/downloading states
  final Map<String, double> uploadProgress = {};
  final Map<String, double> downloadProgress = {};

  // Upload a file and track progress
  Future<void> uploadFile(File file, List<String> receiverIds) async {
    String fileId = file.path; // Unique identifier
    uploadProgress[fileId] = 0.0;
    notifyListeners();

    var uri = Uri.parse('${Secrets.serverUrl}/api/media/upload-image');
    var request = http.MultipartRequest("POST", uri);
    var stream = http.ByteStream(file.openRead());
    var length = await file.length();

    var multipartFile = http.MultipartFile(
      'image',
      stream,
      length,
      filename: file.path.split('/').last,
    );

    request.files.add(multipartFile);

    // Listen for upload progress
    var response = await request.send();

    // _dbHelper.insertMediaMessage(fileId, file.path, 'image');    

    response.stream.listen((value) {
      uploadProgress[fileId] = value.length / length;
      notifyListeners();
    });

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseData);
      String imageUrl = jsonData["image_url"];

      // Upload finished, remove from progress tracker
      uploadProgress.remove(fileId);
      notifyListeners();

      for (int index = 0; index < receiverIds.length; index++) {
        final Ids = [CurrentUser.userId, receiverIds[index]]..sort();
        final String chatId = Ids.join('_');

        final Map<String, dynamic> message = {
          '_id': const Uuid().v4(),
          'sender_id': CurrentUser.userId,
          'receiver_id': receiverIds[index],
          'content': imageUrl,
          'chat_id': chatId,
          'type': 'image',
          'status': 'pending',
          'timestamp': DateTime.now().toIso8601String(),
          'deleted_for_everyone': 0,
          'edited': 0,
        };

        _webSocketService.sendMessage(message);
      }
    } else {
      uploadProgress.remove(fileId);
      notifyListeners();
    }
  }

  // Download a file and track progress (Optional)
  Future<void> downloadFile(String url, String savePath) async {
    downloadProgress[url] = 0.0;
    notifyListeners();

    var response = await http.get(Uri.parse(url));
    File file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);

    downloadProgress.remove(url);
    notifyListeners();
  }
}
