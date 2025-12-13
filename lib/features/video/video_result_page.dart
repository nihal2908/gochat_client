import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:whatsapp_clone/models/user.dart';

class VideoResultPage extends StatefulWidget {
  final File file;
  final User receiver;
  final String caption;

  const VideoResultPage({
    super.key,
    required this.file,
    required this.receiver,
    required this.caption,
  });

  @override
  State<VideoResultPage> createState() => _VideoResultPageState();
}

class _VideoResultPageState extends State<VideoResultPage> {
  late final VideoPlayerController _videoPlayerController;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
    _captionController.text = widget.caption;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.crop_rotate,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.emoji_emotions_outlined,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.title,
              size: 27,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit,
              size: 27,
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    // height: MediaQuery.of(context).size.height - 159,
                    width: MediaQuery.of(context).size.width,
                    child: _videoPlayerController.value.isInitialized
                        ? AspectRatio(
                            aspectRatio:
                                _videoPlayerController.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController),
                          )
                        : Container(),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 33,
                      backgroundColor: Colors.black38,
                      child: InkWell(
                        onTap: () {
                          _videoPlayerController.value.isPlaying
                              ? _videoPlayerController.pause()
                              : _videoPlayerController.play();
                        },
                        child: Icon(
                          _videoPlayerController.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      margin: EdgeInsets.only(left: 2, right: 2, bottom: 8),
                      child: TextField(
                        controller: _captionController,
                        keyboardType: TextInputType.multiline,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Add caption...',
                          contentPadding: EdgeInsets.all(5),
                          border: InputBorder.none,
                          prefixIcon: IconButton(
                            icon: Icon(Icons.emoji_emotions),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        final result = {};
                        Navigator.pop(context, result);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }
}
