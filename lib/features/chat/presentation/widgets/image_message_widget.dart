import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/features/media/api/upload_download_manager.dart';
import 'package:whatsapp_clone/models/media.dart';
import 'package:whatsapp_clone/models/message.dart';

class ImageMessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;
  final DBHelper dbHelper;
  final WebSocketService webSocketService;
  const ImageMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.dbHelper,
    required this.webSocketService,
  });

  @override
  State<ImageMessageWidget> createState() => _ImageMessageWidgetState();
}

class _ImageMessageWidgetState extends State<ImageMessageWidget> {
  bool isDownloading = false;
  bool isUploading = false;
  Media? mediaMessage;
  late final DBHelper _dbHelper;
  late final WebSocketService _webSocketService;

  late final Stream<double>? _uploadStream;
  late final Stream<double>? _downloadStream;

  @override
  void initState() {
    _dbHelper = widget.dbHelper;
    _webSocketService = widget.webSocketService;
    _uploadStream =
        UploadDownloadManager().getUploadProgressStream(widget.message.Id);
    _downloadStream =
        UploadDownloadManager().getDownloadProgressStream(widget.message.Id);
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
        if (!mounted) return;
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
      } else {
        final Map<String, dynamic>? media =
            await _dbHelper.loadMediaMessage(widget.message.Id);
        if (media == null) return;
        if (!mounted) return;
        setState(() {
          mediaMessage = Media.fromMap(media);
        });
      }
    } else {
      final bool? downloading =
          UploadDownloadManager().downloadingMessages[widget.message.Id];
      if (downloading != null && downloading) {
        if (!mounted) return;
        setState(() {
          isDownloading = true;
        });
      } else {
        final Map<String, dynamic>? media =
            await _dbHelper.loadMediaMessage(widget.message.Id);
        if (media == null) return;
        if (!mounted) return;
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
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Stack(
                    children: [
                      StreamBuilder<double>(
                          stream: _uploadStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == 1.0) {
                              return CircularProgressIndicator(
                                color: Colors.green,
                              );
                            }
                            double progress = snapshot.data!;
                            return CircularProgressIndicator(
                              value: progress,
                              color: Colors.green,
                            );
                          }),
                      IconButton(
                        onPressed: _stopUpload,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
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
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: _uploadFile,
                  icon: Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
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
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black.withOpacity(0.5),
            child: Stack(
              children: [
                StreamBuilder<double>(
                  stream: _downloadStream,
                  builder: (context, snapshot) {
                    double progress = snapshot.data ?? 0;
                    return CircularProgressIndicator(
                      value: progress,
                      color: Colors.green,
                    );
                  },
                ),
                IconButton(
                  onPressed: _pauseDownload,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (mediaMessage == null) {
        return Center(
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: Icon(
                Icons.download,
                color: Colors.white,
              ),
              onPressed: _downloadMedia,
            ),
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

    loadMedia();
  }

  void _stopUpload() {}

  @override
  void dispose() {
    super.dispose();
  }
}
