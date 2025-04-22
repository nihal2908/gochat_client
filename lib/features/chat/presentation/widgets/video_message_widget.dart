import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/features/media/api/file_uploader.dart';
import 'package:whatsapp_clone/models/media.dart';
import 'package:whatsapp_clone/models/message.dart';

class VideoMessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;
  final DBHelper dbHelper;
  final WebSocketService webSocketService;
  const VideoMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.dbHelper,
    required this.webSocketService,
  });

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  bool isDownloading = false;
  bool isUploading = false;
  Media? mediaMessage;
  late final DBHelper _dbHelper;
  late final WebSocketService _webSocketService;
  File? thumbnail;

  @override
  void initState() {
    _dbHelper = widget.dbHelper;
    _webSocketService = widget.webSocketService;
    loadMedia();
    super.initState();
  }

  void loadMedia() async {
    if (widget.isMe) {
      if (widget.message.Status == 'uploading') {
        final Map<String, dynamic>? media =
            await _dbHelper.loadMediaMessage(widget.message.Id);
        final bool? uploading =
            UploadDownloadManager().uploadingMessages[widget.message.Id];

        if (uploading != null && uploading) {
          setState(() {
            isUploading = true;
            mediaMessage = Media.fromMap(media!);
          });
        } else {
          setState(() {
            mediaMessage = Media.fromMap(media!);
          });
        }
      }
    } else {
      final bool? downloading =
          UploadDownloadManager().downloadingMessages[widget.message.Id];
      if (downloading != null && downloading) {
        setState(() {
          isDownloading = true;
        });
      } else {
        final Map<String, dynamic>? media =
            await _dbHelper.loadMediaMessage(widget.message.Id);
        if (media == null) return;
        setState(() {
          mediaMessage = Media.fromMap(media);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMe) {
      if (widget.message.Status == 'uploading') {
        if (isUploading) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(
                  File(widget.message.Content),
                ),
              ),
            ),
            child: Center(
              child: Stack(
                children: [
                  StreamBuilder<double>(
                      stream: UploadDownloadManager()
                          .getUploadProgressStream(widget.message.Id),
                      builder: (context, snapshot) {
                        return CircularProgressIndicator(
                          value: snapshot.data ?? 0,
                          color: Colors.green,
                        );
                      }),
                  IconButton(
                    onPressed: _stopUpload,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(
                  File(widget.message.Content),
                ),
              ),
            ),
            child: Center(
              child: IconButton(
                onPressed: _uploadFile,
                icon: Icon(Icons.file_upload_outlined),
              ),
            ),
          );
        }
      } else if (mediaMessage == null) {
        return Text('Error');
      } else {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(
                File(mediaMessage!.Path),
              ),
            ),
          ),
        );
      }
    }
    // recieved message
    else {
      if (isDownloading) {
        return Center(
          child: Stack(
            children: [
              StreamBuilder<double>(
                stream: UploadDownloadManager()
                    .getDownloadProgressStream(widget.message.Id),
                builder: (context, snapshot) {
                  return CircularProgressIndicator(
                    value: snapshot.data ?? 0,
                    color: Colors.green,
                  );
                },
              ),
              IconButton(
                onPressed: _pauseDownload,
                icon: Icon(Icons.close),
              ),
            ],
          ),
        );
      } else if (mediaMessage == null) {
        return Center(
          child: IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadMedia,
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(
                File(mediaMessage!.Path),
              ),
            ),
          ),
        );
      }
    }
  }

  void _pauseDownload() {}

  void _downloadMedia() {}

  void _uploadFile() {
    UploadDownloadManager().uploadFile(
      file: File(widget.message.Content),
      messageId: widget.message.Id,
      onComplete: (url) async {
        widget.message.Content = url;
        widget.message.Status = 'pending';
        await _dbHelper.updateMediaMessage(
          widget.message,
          mediaMessage!.Path,
        );
        _webSocketService.sendMessage(widget.message.toMap());
      },
    );
  }

  void _stopUpload() {}
}
