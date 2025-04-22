import 'dart:io';

import 'package:flutter/material.dart';

class MediaPreviewPage extends StatefulWidget {
  final List<File> files;

  MediaPreviewPage({super.key, required this.files});

  @override
  State<MediaPreviewPage> createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  final PageController pageController = PageController();

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
            PageView.builder(
              controller: pageController,
              itemCount: widget.files.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  width: MediaQuery.of(context).size.width,
                  child: Image.file(
                    widget.files[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width - 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.files.length,
                      itemBuilder: (context, index) {
                        if (pageController.page == index) {
                          return InkWell(
                            onTap: () {
                              widget.files.removeAt(index);
                              setState(() {});
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.file(
                                    widget.files[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return InkWell(
                            onTap: () {
                              pageController.jumpToPage(
                                index,
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Image.file(
                                widget.files[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
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
                        suffixIcon: CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.teal,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
