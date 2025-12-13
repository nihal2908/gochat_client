// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:path/path.dart' as p;
// import 'package:intl/intl.dart'; // optional for file sizes formatting

// import 'package:whatsapp_clone/models/user.dart';

// class MediaPreviewPage extends StatefulWidget {
//   final List<File> files;
//   final User receiver;

//   MediaPreviewPage({super.key, required this.files, required this.receiver});

//   @override
//   State<MediaPreviewPage> createState() => _MediaPreviewPageState();
// }

// class _MediaPreviewPageState extends State<MediaPreviewPage> {
//   late PageController pageController;
//   int currentIndex = 0;

//   // per-file caption controllers
//   late List<TextEditingController> captionControllers;

//   // video controllers cache
//   final Map<int, VideoPlayerController> _videoControllers = {};
//   // trim ranges per video (seconds)
//   final Map<int, RangeValues> _videoTrimRanges = {};

//   @override
//   void initState() {
//     super.initState();
//     pageController = PageController();
//     captionControllers = List.generate(widget.files.length, (i) => TextEditingController());
//     // init possible video controllers lazily when needed
//     if (widget.files.isNotEmpty) {
//       _maybeInitVideoController(0);
//     }
//   }

//   @override
//   void dispose() {
//     pageController.dispose();
//     for (final c in captionControllers) c.dispose();
//     for (final e in _videoControllers.entries) {
//       try {
//         e.value.pause();
//         e.value.dispose();
//       } catch (_) {}
//     }
//     super.dispose();
//   }

//   // helpers
//   String ext(File f) => p.extension(f.path).toLowerCase().replaceFirst('.', '');
//   bool isImage(File f) => ['jpg','jpeg','png','gif','webp','bmp'].contains(ext(f));
//   bool isVideo(File f) => ['mp4','mov','mkv','webm','avi'].contains(ext(f));

//   String readableFileSize(int bytes) {
//     if (bytes <= 0) return "0 B";
//     const units = ['B','KB','MB','GB','TB'];
//     final i = (log(bytes) / log(1024)).floor();
//     final size = bytes / pow(1024, i);
//     final out = size < 10 ? size.toStringAsFixed(2) : size.toStringAsFixed(1);
//     return '$out ${units[i]}';
//   }

//   Future<void> _maybeInitVideoController(int index) async {
//     if (!isVideo(widget.files[index])) return;
//     if (_videoControllers.containsKey(index)) return;
//     final file = widget.files[index];
//     final controller = VideoPlayerController.file(file);
//     _videoControllers[index] = controller;
//     await controller.initialize();
//     // default trim range = full video
//     final duration = controller.value.duration.inMilliseconds / 1000.0;
//     _videoTrimRanges[index] = RangeValues(0.0, duration);
//     setState(() {});
//   }

//   // seek to start of trimmed range and play; stop at end
//   Future<void> _playTrimPreview(int index) async {
//     final controller = _videoControllers[index];
//     if (controller == null) return;
//     final range = _videoTrimRanges[index] ?? RangeValues(0, controller.value.duration.inMilliseconds / 1000.0);
//     final start = Duration(milliseconds: (range.start * 1000).toInt());
//     final end = Duration(milliseconds: (range.end * 1000).toInt());

//     await controller.pause();
//     await controller.seekTo(start);
//     await controller.play();

//     // schedule stop at end - poll periodically
//     // Alternatively, use addListener to monitor position
//     controller.addListener(() {
//       final pos = controller.value.position;
//       if (pos >= end) {
//         controller.pause();
//       }
//     });
//   }

//   // Called when user confirms (check icon). We'll build result list and pop.
//   Future<void> _finishAndPop() async {
//     final List<Map<String, dynamic>> result = [];
//     for (int i = 0; i < widget.files.length; i++) {
//       final f = widget.files[i];
//       final size = await f.length();
//       final type = isImage(f) ? 'image' : (isVideo(f) ? 'video' : 'document');
//       final map = <String, dynamic>{
//         'name': p.basename(f.path),
//         'path': f.path,
//         'size': size,
//         'caption': captionControllers[i].text,
//         'type': type,
//       };
//       if (isVideo(f)) {
//         final range = _videoTrimRanges[i];
//         if (range != null) {
//           map['trimStart'] = range.start;
//           map['trimEnd'] = range.end;
//         }
//       }
//       result.add(map);
//     }
//     Navigator.of(context).pop(result);
//   }

//   // OPTIONAL: If you want to actually create a trimmed file now:
//   // Use ffmpeg_kit_flutter to run a trim command:
//   //
//   // final newPath = '/.../trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4';
//   // FFmpegKit.execute('-i "${orig.path}" -ss $start -to $end -c copy "$newPath"')
//   // Note: using `-c copy` is fast but might not work with all codecs; re-encoding is possible.
//   //
//   // Implement trimming before calling _finishAndPop if you want final path updated.

//   @override
//   Widget build(BuildContext context) {
//     final deviceW = MediaQuery.of(context).size.width;
//     final deviceH = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text('Preview'),
//         actions: [
//           IconButton(
//             onPressed: _finishAndPop,
//             icon: const Icon(Icons.check),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             PageView.builder(
//               controller: pageController,
//               itemCount: widget.files.length,
//               onPageChanged: (idx) {
//                 setState(() {
//                   currentIndex = idx;
//                 });
//                 // ensure video controller exists for new index
//                 _maybeInitVideoController(idx);
//               },
//               itemBuilder: (context, index) {
//                 final file = widget.files[index];
//                 if (isImage(file)) {
//                   // image: zoomable viewer
//                   return GestureDetector(
//                     onDoubleTap: () {
//                       // could toggle scale if desired
//                     },
//                     child: Container(
//                       color: Colors.black,
//                       width: deviceW,
//                       height: deviceH,
//                       child: InteractiveViewer(
//                         child: Image.file(
//                           file,
//                           fit: BoxFit.contain,
//                           errorBuilder: (ctx, e, st) => Center(child: Icon(Icons.broken_image, color: Colors.white30)),
//                         ),
//                       ),
//                     ),
//                   );
//                 } else if (isVideo(file)) {
//                   final controller = _videoControllers[index];
//                   if (controller == null || !controller.value.isInitialized) {
//                     // still initializing
//                     // start initialization if not done
//                     _maybeInitVideoController(index);
//                     return const Center(child: CircularProgressIndicator());
//                   } else {
//                     return Column(
//                       children: [
//                         Expanded(
//                           child: Center(
//                             child: AspectRatio(
//                               aspectRatio: controller.value.aspectRatio,
//                               child: Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   VideoPlayer(controller),
//                                   // simple play/pause overlay
//                                   _VideoPlayPauseOverlay(controller: controller),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),

//                         // trimming UI area
//                         _buildVideoTrimArea(index, controller),
//                       ],
//                     );
//                   }
//                 } else {
//                   // fallback: show file info
//                   return _buildFileInfo(file);
//                 }
//               },
//             ),

//             // bottom thumbnail strip + caption
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: _buildBottomPanel(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFileInfo(File file) {
//     return FutureBuilder<int>(
//       future: file.length(),
//       builder: (context, snap) {
//         final sizeStr = snap.hasData ? readableFileSize(snap.data!) : '...';
//         return Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.insert_drive_file, size: 80, color: Colors.white24),
//               const SizedBox(height: 12),
//               Text(p.basename(file.path), style: const TextStyle(color: Colors.white, fontSize: 16)),
//               const SizedBox(height: 6),
//               Text(sizeStr, style: const TextStyle(color: Colors.white54)),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildVideoTrimArea(int index, VideoPlayerController controller) {
//     final durationSec = controller.value.duration.inMilliseconds / 1000.0;
//     final range = _videoTrimRanges[index] ?? RangeValues(0.0, durationSec);

//     return Container(
//       color: Colors.black87,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Column(
//         children: [
//           // show current trim preview times
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(_formatTime(range.start), style: TextStyle(color: Colors.white70)),
//               Text(_formatTime(range.end), style: TextStyle(color: Colors.white70)),
//             ],
//           ),
//           const SizedBox(height: 8),
//           RangeSlider(
//             min: 0.0,
//             max: durationSec,
//             values: range,
//             divisions: (durationSec * 10).round().clamp(1, 1000),
//             onChanged: (r) {
//               setState(() {
//                 _videoTrimRanges[index] = r;
//               });
//             },
//             onChangeEnd: (r) {
//               // optionally seek to start to show preview
//               controller.seekTo(Duration(milliseconds: (r.start * 1000).toInt()));
//             },
//             labels: RangeLabels(_formatTime(range.start), _formatTime(range.end)),
//             activeColor: Colors.teal,
//             inactiveColor: Colors.white24,
//           ),

//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () {
//                   controller.seekTo(Duration(milliseconds: (range.start * 1000).toInt()));
//                 },
//                 icon: const Icon(Icons.replay_10),
//                 label: const Text('Seek Start'),
//               ),
//               const SizedBox(width: 12),
//               ElevatedButton.icon(
//                 onPressed: () => _playTrimPreview(index),
//                 icon: const Icon(Icons.play_arrow),
//                 label: const Text('Play Selection'),
//               ),
//               const SizedBox(width: 12),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   // Option: actually trim now using ffmpeg_kit_flutter and replace path
//                   // Show simple confirmation dialog first
//                   final confirmed = await showDialog<bool>(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text('Trim video'),
//                       content: const Text('Trim the video now? This will create a new file.'),
//                       actions: [
//                         TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//                         TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Trim')),
//                       ],
//                     ),
//                   );
//                   if (confirmed == true) {
//                     await _trimVideoFile(index); // implement below (optional)
//                   }
//                 },
//                 icon: const Icon(Icons.content_cut),
//                 label: const Text('Trim & Replace'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTime(double seconds) {
//     final mm = (seconds ~/ 60).toInt();
//     final ss = (seconds % 60).toInt();
//     final mmStr = mm.toString().padLeft(2, '0');
//     final ssStr = ss.toString().padLeft(2, '0');
//     return '$mmStr:$ssStr';
//   }

//   Widget _buildBottomPanel() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // thumbnails row
//         SizedBox(
//           height: 80,
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             scrollDirection: Axis.horizontal,
//             itemCount: widget.files.length,
//             itemBuilder: (context, index) {
//               // final file = widget.files[index];
//               final selected = index == currentIndex;
//               return GestureDetector(
//                 onTap: () {
//                   pageController.animateToPage(index, duration: const Duration(milliseconds: 240), curve: Curves.easeInOut);
//                 },
//                 onLongPress: selected ? () {
//                   // delete selected file
//                   setState(() {
//                     widget.files.removeAt(index);
//                     captionControllers.removeAt(index).dispose();
//                     if (currentIndex >= widget.files.length) currentIndex = max(0, widget.files.length - 1);
//                     pageController.jumpToPage(currentIndex);
//                   });
//                 } : null,
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 6),
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       _buildThumbnail(widget.files[index], selected),
//                       if (selected)
//                         Positioned(top: 6, right: 6, child: Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), padding: const EdgeInsets.all(4), child: const Icon(Icons.delete, size: 16, color: Colors.white))),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),

//         // caption input
//         Container(
//           width: double.infinity,
//           color: Colors.black,
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   controller: captionControllers[currentIndex],
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                   decoration: InputDecoration(
//                     hintText: 'Add caption...',
//                     hintStyle: TextStyle(color: Colors.grey[500]),
//                     filled: true,
//                     fillColor: Colors.grey[900],
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                     border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
//                   ),
//                   maxLines: 3,
//                   minLines: 1,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               CircleAvatar(
//                 radius: 22,
//                 backgroundColor: Colors.teal,
//                 child: IconButton(
//                   icon: const Icon(Icons.check, color: Colors.white),
//                   onPressed: _finishAndPop,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildThumbnail(File file, bool selected) {
//     final size = 70.0;
//     if (isImage(file)) {
//       return Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(border: Border.all(color: selected ? Colors.white : Colors.grey, width: selected ? 2 : 1)),
//         child: Image.file(file, fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.broken_image, color: Colors.white24)),
//       );
//     } else if (isVideo(file)) {
//       final controller = _videoControllers[widget.files.indexOf(file)];
//       if (controller != null && controller.value.isInitialized) {
//         // show first frame via controller (not a direct API for thumbnail but we can use texture)
//         return Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(border: Border.all(color: selected ? Colors.white : Colors.grey, width: selected ? 2 : 1)),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
//               Container(color: Colors.black26),
//               const Icon(Icons.play_arrow, color: Colors.white),
//             ],
//           ),
//         );
//       } else {
//         // video not initialized yet
//         _maybeInitVideoController(widget.files.indexOf(file));
//         return Container(
//           width: size,
//           height: size,
//           color: Colors.grey[850],
//           child: const Center(child: CircularProgressIndicator()),
//         );
//       }
//     } else {
//       return Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(border: Border.all(color: selected ? Colors.white : Colors.grey, width: selected ? 2 : 1)),
//         child: Center(child: Icon(Icons.insert_drive_file, color: Colors.white24)),
//       );
//     }
//   }

//   // Optional: trim using ffmpeg (ffmpeg_kit_flutter_min_gpl)
//   // If you include ffmpeg_kit_flutter_min_gpl in pubspec, you can enable actual trimming.
//   // Example snippet (uncomment and add dependency when needed):
//   //
//   Future<void> _trimVideoFile(int index) async {
//     final orig = widget.files[index];
//     final range = _videoTrimRanges[index];
//     if (range == null) return;
//     final start = range.start;
//     final end = range.end;
//     final dir = await getTemporaryDirectory();
//     final out = File('${dir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}${p.extension(orig.path)}');
//     // Example command using ffmpeg_kit: re-encode to avoid codec issues
//     final cmd = '-ss $start -to $end -i "${orig.path}" -c:v libx264 -c:a aac -strict -2 "${out.path}"';
//     final session = await FFmpegKit.execute(cmd);
//     final returnCode = await session.getReturnCode();
//     if (ReturnCode.isSuccess(returnCode)) {
//       // replace file in list
//       setState(() {
//         widget.files[index] = out;
//       });
//       // reinitialize video controller
//       _videoControllers[index]?.dispose();
//       _videoControllers.remove(index);
//       await _maybeInitVideoController(index);
//     } else {
//       // handle failure
//     }
//   }

// }
