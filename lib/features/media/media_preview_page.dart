import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:whatsapp_clone/models/user.dart';

class MediaPreviewPage extends StatefulWidget {
  final List<File> files;
  final User receiver;

  MediaPreviewPage({super.key, required this.files, required this.receiver});

  @override
  State<MediaPreviewPage> createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  late final PageController pageController;
  late final ImagePicker _picker;

  // track current page index properly
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // pick more images (multi-image). copies picked files to temp dir and adds to list
  Future<void> _pickMedia() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage();
      if (picked == null || picked.isEmpty) return;

      final tempDir = Directory.systemTemp;
      final List<File> added = [];
      for (final x in picked) {
        // copy into a temp path to ensure stable access (and avoid picking content URIs)
        final name =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(x.path)}';
        final dest = File('${tempDir.path}/$name');
        final copied = await File(x.path).copy(dest.path);
        added.add(copied);
      }

      if (!mounted) return;
      setState(() {
        widget.files.addAll(added);
      });
    } catch (e) {
      // optionally show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  // remove item at index
  void _removeAt(int index) {
    if (index < 0 || index >= widget.files.length) return;
    setState(() {
      widget.files.removeAt(index);
      // adjust currentIndex if needed
      if (currentIndex >= widget.files.length) {
        currentIndex = widget.files.isEmpty ? 0 : widget.files.length - 1;
      }
      // jump safely
      if (widget.files.isNotEmpty) {
        pageController.jumpToPage(currentIndex);
      } else {
        // nothing remains, pop with empty list
        Navigator.of(context).pop();
      }
    });
  }

  // build final result and pop
  Future<void> _finishAndPop() async {
    final List<Map<String, dynamic>> result = [];
    for (int i = 0; i < widget.files.length; i++) {
      final f = widget.files[i];
      int size = 0;
      try {
        size = await f.length();
      } catch (_) {}
      result.add({
        'caption': "",
        'path': f.path,
        'size': size,
        'type': 'image',
      });
    }
    Navigator.of(context).pop(result);
  }

  // low-quality preview: use cacheWidth to reduce memory for previews
  Widget _buildPreviewImage(File file) {
    // main image — use a higher cacheWidth but not full raw size
    return InteractiveViewer(
      child: Image.file(
        file,
        fit: BoxFit.contain,
        // Request a reduced decode size (helps memory & speed). Adjust as needed.
        cacheWidth: 720,
        errorBuilder: (ctx, err, st) => const Center(
            child: Column(
          children: [
            Icon(Icons.broken_image, color: Colors.white24, size: 48),
            Text('Can not preview this image!'),
          ],
        )),
      ),
    );
  }

  Widget _buildThumbnail(File file, bool selected) {
    // small thumb using cacheWidth very small
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
            color: selected ? Colors.white : Colors.grey,
            width: selected ? 2 : 1),
      ),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        cacheWidth: 120, // small preview for the thumb
        errorBuilder: (ctx, err, st) =>
            Icon(Icons.broken_image, color: Colors.white24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceW = MediaQuery.of(context).size.width;
    final deviceH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Preview'),
        actions: [
          // add more images
          IconButton(
            onPressed: _pickMedia,
            icon: const Icon(Icons.add_a_photo),
            tooltip: 'Add images',
          ),
          // done / send
          IconButton(
            onPressed: _finishAndPop,
            icon: const Icon(Icons.check),
            tooltip: 'Done',
          ),
        ],
      ),
      body: SizedBox(
        height: deviceH,
        width: deviceW,
        child: Stack(
          children: [
            // main PageView (images)
            PageView.builder(
              controller: pageController,
              itemCount: widget.files.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final file = widget.files[index];
                return SizedBox(
                  height: deviceH - 150,
                  width: deviceW,
                  child: Center(child: _buildPreviewImage(file)),
                );
              },
            ),

            // bottom: thumbnails + caption input
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // thumbnail strip
                  SizedBox(
                    height: 80,
                    width: deviceW,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.files.length,
                      itemBuilder: (context, index) {
                        final file = widget.files[index];
                        final selected = index == currentIndex;
                        return GestureDetector(
                          onTap: () {
                            if (widget.files.isEmpty) return;
                            if (selected) {
                              _removeAt(index);
                              return;
                            }
                            pageController.jumpToPage(
                              index,
                              // duration: const Duration(milliseconds: 220),
                              // curve: Curves.easeInOut
                            );
                            setState(() => currentIndex = index);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildThumbnail(file, selected),
                              if (selected)
                                const Center(
                                  child: Icon(Icons.delete,
                                      size: 25, color: Colors.white),
                                ),
                            ],
                          ),
                        );
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
}
