import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/features/media/api/file_uploader.dart';
import 'package:whatsapp_clone/models/media.dart';
import 'package:whatsapp_clone/models/message.dart';

class AudioMessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;
  final DBHelper dbHelper;
  final WebSocketService webSocketService;
  const AudioMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.dbHelper,
    required this.webSocketService,
  });

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  bool isPlaying = false;
  bool isUploading = false;
  bool isDownloading = false;
  late final DBHelper _dbHelper;
  Media? mediaMessage;
  late final WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();
    _dbHelper = widget.dbHelper;
    _webSocketService = widget.webSocketService;
    loadMedia();
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
      return Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange,
            child: Center(
              child: widget.message.Status == 'uploading'
                  ? isUploading
                      ? Stack(
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
                              onPressed: () {},
                              icon: Icon(Icons.close),
                            ),
                          ],
                        )
                      : IconButton(
                          onPressed: _uploadFile,
                          icon: Icon(Icons.upload),
                        )
                  : mediaMessage != null
                      ? Icon(
                          Icons.headset,
                          size: 20,
                          color: Colors.white,
                        )
                      : Text('Error'),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Column(
            children: [
              Row(
                children: [
                  isPlaying
                      ? IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.pause),
                        )
                      : IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.play_arrow),
                        ),
                  const SizedBox(
                    width: 2,
                  ),
                  Slider(
                    value: 1,
                    onChanged: (value) {},
                    activeColor: Colors.orange,
                    inactiveColor: Colors.grey,
                  ),
                ],
              ),
              Text(
                'Audio Message',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange,
            child: Center(
              child: isDownloading
                  ? Stack(
                      children: [
                        StreamBuilder<double>(
                            stream: UploadDownloadManager()
                                .getDownloadProgressStream(widget.message.Id),
                            builder: (context, snapshot) {
                              return CircularProgressIndicator(
                                value: snapshot.data ?? 0,
                                color: Colors.green,
                              );
                            }),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.close),
                        ),
                      ],
                    )
                  : mediaMessage != null
                      ? Icon(Icons.headset)
                      : IconButton(
                          onPressed: _downloadFile,
                          icon: Icon(
                            Icons.headset,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Column(
            children: [
              Row(
                children: [
                  isPlaying
                      ? IconButton(
                          onPressed: _pauseAudio,
                          icon: Icon(Icons.pause),
                        )
                      : IconButton(
                          onPressed: _playAudio,
                          icon: Icon(Icons.play_arrow),
                        ),
                  const SizedBox(
                    width: 2,
                  ),
                  Slider(
                    value: 1,
                    onChanged: (value) {},
                    activeColor: Colors.orange,
                    inactiveColor: Colors.grey,
                  ),
                ],
              ),
              Text(
                'Audio Message',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      );
    }
  }

  void _downloadFile() {}

  void _playAudio() {}

  void _pauseAudio() {}

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
}
