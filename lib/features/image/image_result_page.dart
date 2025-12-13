import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/models/user.dart';

class ImageResultPage extends StatefulWidget {
  final File file;
  final User receiver;
  final String caption;

  const ImageResultPage({
    super.key,
    required this.file,
    required this.receiver,
    required this.caption,
  });

  @override
  State<ImageResultPage> createState() => _ImageResultPageState();
}

class _ImageResultPageState extends State<ImageResultPage> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    _captionController = TextEditingController(text: widget.caption);
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
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              width: MediaQuery.of(context).size.width,
              child: Image.file(
                widget.file,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _captionController,
                      maxLines: 5,
                      textAlignVertical: TextAlignVertical.center,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add caption...',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                        prefixIcon: Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white,
                          size: 27,
                        ),
                        suffixIcon: InkWell(
                          onTap: () async {
                            final directory =
                                await getApplicationDocumentsDirectory();
                            final savePath =
                                '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                            File file = File(savePath);
                            await file
                                .writeAsBytes(await widget.file.readAsBytes());
                            Navigator.pop(
                              context,
                              {
                                'caption': _captionController.text.trim(),
                                'path': savePath,
                                'size': file.lengthSync(),
                                'type': 'image',
                              },
                            );
                          },
                          child: CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
