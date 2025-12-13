import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:whatsapp_clone/features/image/image_result_page.dart';
import 'package:whatsapp_clone/features/video/video_result_page.dart';
import 'package:whatsapp_clone/models/user.dart';

class CameraScreen extends StatefulWidget {
  final User receiver;
  final String caption;
  const CameraScreen({
    super.key,
    required this.caption,
    required this.receiver,
  });

  static late final List<CameraDescription> cameras;

  static Future<void> fetchCameras() async {
    cameras = await availableCameras();
  }

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  bool flashOn = false;
  bool primaryCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      CameraScreen.cameras[0],
      ResolutionPreset.ultraHigh,
      enableAudio: true,
    );
    await _cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(_cameraController.value.aspectRatio);
                print(_cameraController.value.previewSize.toString());
                return Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              color: Colors.grey.shade900.withOpacity(0.5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: toggleFlash,
                        icon: Icon(
                          flashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => takePhoto(context),
                        onLongPress: startRecordingVideo,
                        onLongPressUp: () => endRecordingVideo(context),
                        child: Icon(
                          _isRecording
                              ? Icons.radio_button_on
                              : Icons.panorama_fish_eye,
                          color: _isRecording ? Colors.red : Colors.white,
                          size: 70,
                        ),
                      ),
                      IconButton(
                        onPressed: flipCamera,
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Hold for video, tap for photo',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void toggleFlash() async {
    if (!_cameraController.value.isInitialized) return;

    flashOn = !flashOn;
    await _cameraController
        .setFlashMode(flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  void flipCamera() async {
    if (CameraScreen.cameras.length < 2) return;

    final newCamera =
        primaryCamera ? CameraScreen.cameras[1] : CameraScreen.cameras[0];

    await _cameraController.dispose();
    _cameraController = CameraController(newCamera, ResolutionPreset.ultraHigh);
    _initializeControllerFuture = _cameraController.initialize();

    primaryCamera = !primaryCamera;
    setState(() {});
  }

  void takePhoto(BuildContext context) async {
    if (!_cameraController.value.isInitialized) return;

    final xfile = await _cameraController.takePicture();
    _cameraController.pausePreview();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageResultPage(
          file: File(xfile.path),
          receiver: widget.receiver,
          caption: widget.caption,
        ),
      ),
    ).then((result) {
      if (result == null) {
        _cameraController.resumePreview();
      } else {
        Navigator.pop(context, result);
      }
    });
  }

  void startRecordingVideo() async {
    if (!_cameraController.value.isInitialized || _isRecording) return;

    setState(() {
      _isRecording = true;
    });
    await _cameraController.startVideoRecording();
  }

  void endRecordingVideo(BuildContext context) async {
    if (!_cameraController.value.isInitialized || !_isRecording) return;

    setState(() {
      _isRecording = false;
    });

    final xfile = await _cameraController.stopVideoRecording();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoResultPage(
          file: File(xfile.path),
          receiver: widget.receiver,
          caption: widget.caption,
        ),
      ),
    ).then((result) {
      if (result == null) {
        _cameraController.resumePreview();
      } else {
        Navigator.pop(context, result);
      }
    });
  }

  @override
  void dispose() {
    if (_cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }
}
