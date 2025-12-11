import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class DocumentPreviewPage extends StatefulWidget {
  final List<File> files;

  const DocumentPreviewPage({Key? key, required this.files}) : super(key: key);

  @override
  State<DocumentPreviewPage> createState() => _DocumentPreviewPageState();
}

class _DocumentPreviewPageState extends State<DocumentPreviewPage> {
  late PageController _pageController;
  int _currentPage = 0;

  // caption controllers per file
  late List<TextEditingController> _captionControllers;

  // cache thumbnails / pdf page images as bytes
  final Map<String, Uint8List?> _thumbCache = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _captionControllers = List.generate(
      widget.files.length,
      (_) => TextEditingController(),
    );

    // Pre-start thumbnail generation for first few files (optional)
    if (widget.files.isNotEmpty) {
      _ensureThumb(widget.files[0]);
      if (widget.files.length > 1) _ensureThumb(widget.files[1]);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _captionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // helpers to detect types
  String _extension(File f) =>
      p.extension(f.path).toLowerCase().replaceFirst('.', '');

  bool _isImage(File f) {
    final ext = _extension(f);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  bool _isVideo(File f) {
    final ext = _extension(f);
    return ['mp4', 'mov', 'mkv', 'webm', 'avi', 'flv'].contains(ext);
  }

  bool _isPdf(File f) => _extension(f) == 'pdf';

  String _fileTypeLabel(File f) {
    if (_isImage(f)) return 'image';
    if (_isVideo(f)) return 'video';
    return 'document';
  }

  String _readableFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = (bytes / pow(1024, i));
    return '${size.toStringAsFixed(size < 10 ? 2 : 1)} ${suffixes[i]}';
  }

  // ensure thumbnail exists in cache, start generation if absent
  Future<void> _ensureThumb(File file) async {
    final key = file.path;
    if (_thumbCache.containsKey(key)) return;
    _thumbCache[key] = null; // mark as generating
    Uint8List? bytes;
    try {
      if (_isImage(file)) {
        // for image use lower-res by reading file bytes and decoding is handled by Image.memory.
        // We'll read a small chunk by relying on Image.file with cacheWidth in widget, so here leave null
        bytes = await file
            .readAsBytes(); // fallback full image bytes (will be displayed with cacheWidth)
      } else if (_isVideo(file)) {
        // final uint8list = await VideoThumbnail.thumbnailData(
        //   video: file.path,
        //   imageFormat: ImageFormat.JPEG,
        //   maxWidth: 400, // low quality
        //   quality: 50,
        // );
        // bytes = uint8list;
        bytes = null;
      } else if (_isPdf(file)) {
        // render first page using pdf_render
        // final doc = await PdfDocument.openFile(file.path);
        // final page = await doc.getPage(1);
        // final pageImage = await page.render(
        //   width: page.width, // keep native resolution, we'll scale when displaying
        //   height: page.height,
        //   format: PdfPageImageFormat.jpeg,
        // );
        // bytes = pageImage.bytes;
        // await page.close();
        // await doc.dispose();
        bytes = null;
      } else {
        bytes = null; // not previewable
      }
    } catch (e) {
      // generation failed -> leave null
      bytes = null;
    }
    if (mounted) {
      setState(() {
        _thumbCache[key] = bytes;
      });
    } else {
      _thumbCache[key] = bytes;
    }
  }

  Widget _buildPreviewWidget(File file) {
    final key = file.path;
    final ext = _extension(file);

    // If image: show image scaled down (low-quality via cacheWidth)
    if (_isImage(file)) {
      // Show a lower-res preview by letting Image.file set cacheWidth via ImageProvider
      return InteractiveViewer(
        child: Image.file(
          file,
          fit: BoxFit.contain,
          // use loadingBuilder to show progress while large images load
          // loadingBuilder: (context, child, loadingProgress) {
          //   if (loadingProgress == null) return child;
          //   return const Center(child: CircularProgressIndicator());
          // },
          errorBuilder: (context, error, stackTrace) {
            return _centerFileInfo(file);
          },
        ),
      );
    }

    // If video: show thumbnail from cache or loading indicator
    if (_isVideo(file)) {
      final thumb = _thumbCache[key];
      if (thumb == null) {
        // start generation if not started
        _ensureThumb(file);
        return const Center(child: CircularProgressIndicator());
      } else if (thumb.isEmpty) {
        return _centerFileInfo(file);
      } else {
        return Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(child: Image.memory(thumb, fit: BoxFit.contain)),
            // play icon overlay
            Container(
              decoration:
                  BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.play_arrow, size: 50, color: Colors.white),
              ),
            ),
          ],
        );
      }
    }

    // If PDF: show rendered first page if available
    if (_isPdf(file)) {
      final thumb = _thumbCache[key];
      if (thumb == null) {
        _ensureThumb(file);
        return const Center(child: CircularProgressIndicator());
      } else if (thumb.isEmpty) {
        return _centerFileInfo(file);
      } else {
        return InteractiveViewer(
            child: Image.memory(thumb, fit: BoxFit.contain));
      }
    }

    // fallback for other documents
    return _centerFileInfo(file);
  }

  Widget _centerFileInfo(File file) {
    final name = p.basename(file.path);
    return FutureBuilder<int>(
      future: file.length(),
      builder: (context, snap) {
        final sizeStr = snap.hasData ? _readableFileSize(snap.data!) : '...';
        final ext = _extension(file).toUpperCase();
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: _basicFileIcon(file),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '$ext • $sizeStr',
                style: TextStyle(color: Colors.grey[300], fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _basicFileIcon(File file) {
    final ext = _extension(file);
    IconData icon;
    if (['pdf'].contains(ext)) {
      icon = Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      icon = Icons.description;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      icon = Icons.archive;
    } else if (['mp4', 'mkv', 'mov', 'avi'].contains(ext)) {
      icon = Icons.movie;
    } else if (['mp3', 'wav', 'aac'].contains(ext)) {
      icon = Icons.audiotrack;
    } else {
      icon = Icons.insert_drive_file;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[300], size: 48),
          const SizedBox(height: 6),
          Text(
            ext.toUpperCase(),
            style: TextStyle(fontSize: 12, color: Colors.grey[350]),
          ),
        ],
      ),
    );
  }

  // bottom tile builder: shows image thumb / video thumb / file icon
  Widget _buildTile(File file, bool selected) {
    final key = file.path;
    final size = 70.0;
    if (_isImage(file)) {
      // low quality: use Image.file but constrained
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? Colors.white : Colors.grey,
              width: selected ? 2 : 1),
        ),
        child: Image.file(file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _basicFileIcon(file)),
      );
    } else {
      // video/pdf/document: show generated thumbnail if ready
      final thumb = _thumbCache[key];
      if (thumb == null) {
        // start generation
        _ensureThumb(file);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
                color: selected ? Colors.white : Colors.grey,
                width: selected ? 2 : 1),
            color: Colors.grey[850],
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      } else if (thumb.isEmpty) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
                color: selected ? Colors.white : Colors.grey,
                width: selected ? 2 : 1),
          ),
          child: _basicFileIcon(file),
        );
      } else {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
                color: selected ? Colors.white : Colors.grey,
                width: selected ? 2 : 1),
          ),
          child: Image.memory(thumb,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _basicFileIcon(file)),
        );
      }
    }
  }

  void _onPageChanged(int idx) {
    setState(() {
      _currentPage = idx;
    });
    // ensure caption field shows text of new page (controllers are per-file so no extra action needed)
    // pre-generate next thumb
    if (idx + 1 < widget.files.length) _ensureThumb(widget.files[idx + 1]);
  }

  void _onTileTap(int idx) {
    _pageController.animateToPage(idx,
        duration: const Duration(milliseconds: 240), curve: Curves.easeInOut);
  }

  void _onActiveTileTap(int idx) {
    // delete active file
    if (idx < 0 || idx >= widget.files.length) return;
    setState(() {
      widget.files.removeAt(idx);
      _captionControllers.removeAt(idx).dispose();
      // remove cache
      _thumbCache.remove(widget
          .files[idx >= widget.files.length ? widget.files.length - 1 : idx]
          .path);
      if (widget.files.isEmpty) {
        Navigator.of(context).pop(<Map<String, dynamic>>[]);
        return;
      }
      final newIndex = min(idx, widget.files.length - 1);
      _pageController.jumpToPage(newIndex);
      _currentPage = newIndex;
    });
  }

  // finalizing and returning the list of maps
  Future<void> _finishAndPop() async {
    final List<Map<String, dynamic>> result = [];
    for (int i = 0; i < widget.files.length; i++) {
      final f = widget.files[i];
      final len = await f.length();
      result.add({
        'name': p.basename(f.path),
        'path': f.path,
        'size': len,
        'caption': _captionControllers[i].text,
        'type': _fileTypeLabel(f),
      });
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Document preview'),
        actions: [
          IconButton(
            onPressed: _finishAndPop,
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final file = widget.files[index];
                return SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    alignment: Alignment.center,
                    child: _buildPreviewWidget(file),
                  ),
                );
              },
            ),

            // bottom list + caption area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.files.length,
                    itemBuilder: (context, index) {
                      final file = widget.files[index];
                      final selected = index == _currentPage;
                      return GestureDetector(
                        onTap: () => _onTileTap(index),
                        onLongPress:
                            selected ? () => _onActiveTileTap(index) : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildTile(file, selected),
                              if (selected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(6)),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.delete,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // caption input
                Container(
                  width: double.infinity,
                  color: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _captionControllers[_currentPage],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Add caption for this file',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.teal,
                        child: IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: _finishAndPop,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
