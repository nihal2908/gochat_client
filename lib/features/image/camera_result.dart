import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/features/contact/select_receivers_page.dart';
import 'package:whatsapp_clone/models/user.dart';

class CameraResult extends StatefulWidget {
  final File file;
  final List<User> receivers;
  final String caption;

  const CameraResult({
    super.key,
    required this.file,
    required this.receivers,
    required this.caption,
  });

  @override
  State<CameraResult> createState() => _CameraResultState();
}

class _CameraResultState extends State<CameraResult> {
  late final TextEditingController captionController;
  late final List<User> receivers;

  @override
  void initState() {
    captionController = TextEditingController(text: widget.caption);
    receivers = widget.receivers;
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
                      controller: captionController,
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
                            if (receivers.isEmpty) {
                              addReceivers();
                            } else {
                              final directory =
                                  await getApplicationDocumentsDirectory();
                              final savePath =
                                  '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                              File file = File(savePath);
                              await file.writeAsBytes(
                                  await widget.file.readAsBytes());
                              Navigator.pop(
                                context,
                                {
                                  'caption': captionController.text.trim(),
                                  'path': savePath,
                                  'size': file.lengthSync(),
                                  'type': 'image',
                                },
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.teal,
                            child: Icon(
                              receivers.isEmpty ? Icons.check : Icons.send,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    receivers.isNotEmpty
                        ? SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: receivers.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Chip(
                                          label: Text(receivers[index].Title),
                                          deleteIcon: Icon(Icons.close),
                                          onDeleted: () {
                                            setState(() {
                                              receivers.removeAt(index);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    addReceivers();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void addReceivers() async {
    final List<User>? selectedReceivers = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectReceivers(
          selectedContacts: receivers,
        ),
      ),
    );
    if (selectedReceivers != null) {
      setState(() {
        receivers.clear();
        receivers.addAll(selectedReceivers);
      });
    }
  }
}
