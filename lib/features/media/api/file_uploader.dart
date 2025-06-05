import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class UploadDownloadManager {
  static final UploadDownloadManager _instance =
      UploadDownloadManager._internal();
  factory UploadDownloadManager() => _instance;
  UploadDownloadManager._internal();

  final String fileserverUrl = "https://falcon-sweet-physically.ngrok-free.app";

  final Map<String, bool> _uploadingMessages = {};
  final Map<String, StreamController<double>> _uploadProgressStreams = {};

  final Map<String, bool> _downloadingMessages = {};
  final Map<String, StreamController<double>> _downloadProgressStreams = {};

  final Dio _dio = Dio();

  Map<String, bool> get uploadingMessages =>
      Map.unmodifiable(_uploadingMessages);
  Map<String, bool> get downloadingMessages =>
      Map.unmodifiable(_downloadingMessages);

  Stream<double>? getUploadProgressStream(String messageId) =>
      _uploadProgressStreams[messageId]?.stream;

  Stream<double>? getDownloadProgressStream(String messageId) =>
      _downloadProgressStreams[messageId]?.stream;

  Future<void> uploadFile({
    required File file,
    required String messageId,
    required Future<void> Function(String url) onComplete,
  }) async {
    if (_uploadingMessages.containsKey(messageId)) return;

    _uploadingMessages[messageId] = true;
    _uploadProgressStreams[messageId] = StreamController<double>();
    _uploadProgressStreams[messageId]?.add(0.0);

    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });

      final response = await _dio.post(
        '$fileserverUrl/upload',
        data: formData,
        onSendProgress: (int sent, int total) {
          double progress = sent / total;
          _uploadProgressStreams[messageId]?.add(progress);
        },
      );

      if (response.statusCode == 200 && response.data['file_id'] != null) {
        print(response.data);
        await onComplete(
            '$fileserverUrl/download/${response.data['file_id'].toString()}');
      } else {
        print("Upload failed or invalid response");
      }
    } catch (e) {
      print("Upload error: $e");
    }

    _uploadingMessages.remove(messageId);
    await _uploadProgressStreams[messageId]?.close();
    _uploadProgressStreams.remove(messageId);
  }

  Future<void> downloadFile({
    required String fileUrl,
    required String messageId,
    required String savePath,
    required Future<void> Function() onComplete,
  }) async {
    if (_downloadingMessages.containsKey(messageId)) return;

    _downloadingMessages[messageId] = true;
    _downloadProgressStreams[messageId] = StreamController<double>();
    _downloadProgressStreams[messageId]?.add(0.0);

    try {
      await _dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          double progress = total > 0 ? received / total : 0;
          _downloadProgressStreams[messageId]?.add(progress);
        },
      );
      _downloadProgressStreams[messageId]?.add(1.0);
      await onComplete();
    } catch (e) {
      print("Download error: $e");
    }

    _downloadingMessages.remove(messageId);
    await _downloadProgressStreams[messageId]?.close();
    _downloadProgressStreams.remove(messageId);
  }
}
