import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadDownloadManager {
  static final UploadDownloadManager _instance =
      UploadDownloadManager._internal();
  factory UploadDownloadManager() => _instance;
  UploadDownloadManager._internal();

  final String uploadUrl =
      "https://falcon-sweet-physically.ngrok-free.app/upload";

  final Map<String, bool> _uploadingMessages = {}; // Tracks ongoing uploads
  final Map<String, StreamController<double>> _uploadProgressStreams =
      {}; // Tracks progress streams

  final Map<String, bool> _downloadingMessages = {}; // Tracks ongoing downloads
  final Map<String, StreamController<double>> _downloadProgressStreams =
      {}; // Tracks progress streams

  /// Getter for tracking active uploads
  Map<String, bool> get uploadingMessages =>
      Map.unmodifiable(_uploadingMessages);

  /// Getter for tracking active downloads
  Map<String, bool> get downloadingMessages =>
      Map.unmodifiable(_downloadingMessages);

  /// Getter to access upload progress stream for a message
  Stream<double>? getUploadProgressStream(String messageId) =>
      _uploadProgressStreams[messageId]?.stream;

  /// Getter to access download progress stream for a message
  Stream<double>? getDownloadProgressStream(String messageId) =>
      _downloadProgressStreams[messageId]?.stream;

  Future<void> uploadFile({
    required File file,
    required String messageId,
    required Future<void> Function(String url) onComplete,
    // required Function(double progress) onProgressUpdate,
  }) async {
    if (_uploadingMessages.containsKey(messageId)) return;

    _uploadingMessages[messageId] = true;
    _uploadProgressStreams[messageId] = StreamController<double>();
    _uploadProgressStreams[messageId]?.add(0.0);

    var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    response.stream.transform(utf8.decoder).listen((value) {
      try {
        var jsonResponse = jsonDecode(value);
        if (jsonResponse.containsKey("uploaded")) {
          double progress = jsonResponse["uploaded"] / file.lengthSync();
          _uploadProgressStreams[messageId]
              ?.add(progress); // Update UI with real server-side progress
        } else if (jsonResponse.containsKey("file_url")) {
          String fileUrl = jsonResponse["file_url"];
          onComplete(fileUrl);
        }
      } catch (e) {
        print("Parsing error: $e");
      }
    });

    if (response.statusCode != 200) {
      print("Upload failed");
    }

    _uploadingMessages.remove(messageId);
    _uploadProgressStreams[messageId]?.close();
    _uploadProgressStreams.remove(messageId);
  }

  // /// Uploads a file, tracks progress, and updates DB on completion
  // Future<void> uploadFile({
  //   required File file,
  //   required String messageId,
  //   required Future<void> Function(String url) onComplete,
  // }) async {
  //   if (_uploadingMessages.containsKey(messageId)) return;

  //   _uploadingMessages[messageId] = true;
  //   _uploadProgressStreams[messageId] = StreamController<double>();
  //   // _uploadProgressStreams[messageId]?.add(0.0);

  //   var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
  //   var fileStream = http.ByteStream(Stream.castFrom(file.openRead()));
  //   var totalSize = await file.length();

  //   var multipartFile = http.MultipartFile(
  //     'file',
  //     fileStream,
  //     totalSize,
  //     filename: file.path.split('/').last,
  //   );

  //   request.files.add(multipartFile);
  //   var response = await request.send();

  //   // Handle streaming response
  //   response.stream.transform(utf8.decoder).listen((data) {
  //     // data = data.trim();
  //     print('received data:' + data + '\n');

  //     if (data.startsWith('event:progress')) {
  //       try {
  //         int progressIndex = data.indexOf("data:") + 5;
  //         double progress = double.parse(data.substring(progressIndex));
  //         _uploadProgressStreams[messageId]?.add(progress);
  //       } catch (e) {
  //         print("JSON Parse Error (progress): $e");
  //       }
  //       // }
  //     }
  //     // Only process final response if it's valid JSON
  //     else if (data.startsWith("{")) {
  //       try {
  //         var jsonResponse = jsonDecode(data);
  //         String fileUrl = jsonResponse["file_url"];
  //         print("File URL: $fileUrl");
  //         _uploadProgressStreams[messageId]?.add(1.0);
  //         onComplete(fileUrl);
  //       } catch (e) {
  //         print("Final Response Parse Error: $e");
  //       }
  //     } else {
  //       print("Ignoring non-JSON response: $data");
  //     }
  //   });

  //   // Cleanup
  //   _uploadingMessages.remove(messageId);
  //   _uploadProgressStreams[messageId]?.close();
  //   _uploadProgressStreams.remove(messageId);
  // }

  /// Downloads a file, tracks progress, and updates DB on completion
  Future<void> downloadFile({
    required String fileUrl,
    required String messageId,
    required String savePath,
    required Future<void> Function() onComplete,
  }) async {
    if (_downloadingMessages.containsKey(messageId)) return;

    _downloadingMessages[messageId] = true;
    _downloadProgressStreams[messageId] = StreamController<double>();

    var request =
        await http.Client().send(http.Request("GET", Uri.parse(fileUrl)));
    var totalSize = request.contentLength ?? 1;
    var receivedSize = 0;
    var file = File(savePath);
    var fileStream = file.openWrite();

    await request.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (List<int> chunk, EventSink<List<int>> sink) {
          receivedSize += chunk.length;
          double progress = receivedSize / totalSize;
          _downloadProgressStreams[messageId]?.add(progress);
          sink.add(chunk);
        },
      ),
    ).pipe(fileStream);

    await fileStream.close();

    _downloadProgressStreams[messageId]?.add(1.0);
    await onComplete();

    _downloadingMessages.remove(messageId);
    _downloadProgressStreams[messageId]?.close();
    _downloadProgressStreams.remove(messageId);
  }
}
