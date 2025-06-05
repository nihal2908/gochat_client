// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/audio_message_widget.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/image_message_widget.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/models/media.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/secrets/secrets.dart';
import 'package:whatsapp_clone/statics/static_widgets.dart';

class MediaBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final DBHelper dbHelper;
  final WebSocketService webSocketService;
  const MediaBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.dbHelper,
    required this.webSocketService,
  });

  @override
  State<MediaBubble> createState() => _MediaBubbleState();
}

class _MediaBubbleState extends State<MediaBubble> {
  late final DBHelper _dbHelper;
  Media? mediaMessage;
  bool _isDownloading = false;
  final ValueNotifier<bool> _download = ValueNotifier(false);
  late final HttpClientRequest? _downloadRequest;
  late final WebSocketService _webSocketService;
  @override
  void initState() {
    _dbHelper = widget.dbHelper;
    _webSocketService = widget.webSocketService;
    loadMedia();
    super.initState();
  }

  void loadMedia() async {
    final Map<String, dynamic>? media =
        await _dbHelper.loadMediaMessage(widget.message.Id);
    if (media == null) return;
    setState(() {
      mediaMessage = Media.fromMap(media);
    });
  }

  void downloadImage() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _download.value = true;
    });

    try {
      var request = await HttpClient().getUrl(
        Uri.parse(Secrets.serverUrl + widget.message.Content),
      );
      _downloadRequest = request;
      var response = await request.close();

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final savePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        File file = File(savePath);
        List<int> bytes = [];

        await for (var chunk in response) {
          bytes.addAll(chunk);
          if (!_download.value) {
            if (kDebugMode) {
              print('Download cancelled!');
            }
            return;
          }
        }

        await file.writeAsBytes(bytes);
        await _dbHelper.updateMediaMessage(
          widget.message,
          savePath,
        );

        loadMedia();

        setState(() {
          _isDownloading = false;
        });
      } else {
        if (kDebugMode) {
          print('Failed to download file!');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        _download.value = false;
      });
    }
  }

  void pauseDownload() {
    if (!_isDownloading) return;
    setState(() {
      _isDownloading = false;
      _download.value = false;
      _downloadRequest?.abort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double side = MediaQuery.of(context).size.width * 0.80;
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
        height: side,
        width: side,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: widget.isMe ? Colors.green.shade200 : Colors.grey.shade300,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 20,
                ),
                child: buildMediaBox(),
              ),
              Positioned(
                right: 10,
                bottom: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.message.Edited == 1)
                      Text(
                        'Edited',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    Text(
                      widget.message.Timestamp.toString().substring(11, 16),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Statics.statusIcon[widget.message.Status]!,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMediaBox() {
    if (widget.message.Type == 'image') {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey,
        ),
        child: ImageMessageWidget(
          message: widget.message,
          isMe: widget.isMe,
          dbHelper: _dbHelper,
          webSocketService: _webSocketService,
        ),
      );
    }
    if (widget.message.Type == 'video') {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey,
        ),
        child: buildVideoMedia(),
      );
    }
    if (widget.message.Type == 'audio') {
      return AudioMessageWidget(
        message: widget.message,
        isMe: widget.isMe,
        dbHelper: _dbHelper,
        webSocketService: _webSocketService,
      );
    }
    if (widget.message.Type == 'voice') {
      return Row(
        children: [
          Icon(
            Icons.mic,
            size: 20,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            'Voice message',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      );
    }
    if (widget.message.Type == 'document') {
      return Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 20,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            'Document',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget buildVideoMedia() {
    if (widget.message.Status == 'uploading') {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (mediaMessage == null) {
      return Center(
        child: _isDownloading
            ? IconButton(
                onPressed: () {},
                icon: Icon(Icons.close),
              )
            : IconButton(
                icon: Icon(Icons.download),
                onPressed: downloadVideo,
              ),
      );
    } else {
      return Image.file(
        File(mediaMessage!.Path),
        fit: BoxFit.cover,
      );
    }
  }

  void downloadVideo() {}
}
