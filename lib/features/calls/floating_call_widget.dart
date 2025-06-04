import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:whatsapp_clone/features/calls/webrtc_handler.dart';

class FloatingCallWidget extends StatefulWidget {
  final WebRTCHandler webRTCHandler;
  final VoidCallback onClose;
  final VoidCallback onFullscreen;

  const FloatingCallWidget({
    super.key,
    required this.webRTCHandler,
    required this.onClose,
    required this.onFullscreen,
  });

  @override
  State<FloatingCallWidget> createState() => _FloatingCallWidgetState();
}

class _FloatingCallWidgetState extends State<FloatingCallWidget> {
  Offset position = const Offset(15, 100);
  double width = 160;
  double height = 220;
  bool showControls = false;
  Timer? _hideControlsTimer;

  final double minWidth = 120;
  final double maxWidth = 320;
  final double minHeight = 160;
  final double maxHeight = 400;

  void _onTap() {
    if (showControls) {
      setState(() => showControls = false);
      _hideControlsTimer?.cancel();
    } else {
      setState(() => showControls = true);
      _hideControlsTimer?.cancel();
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        setState(() => showControls = false);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final newWidth = (width * details.scale).clamp(minWidth, maxWidth);
    final newHeight = (height * details.scale).clamp(minHeight, maxHeight);
    setState(() {
      width = newWidth;
      height = newHeight;
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  Widget _localVideoWidget() {
    return Hero(
      tag: 'localVideo',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RTCVideoView(
          widget.webRTCHandler.localRenderer,
          mirror: true,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        ),
      ),
    );
  }

  Widget _remoteVideoWidget() {
    return Hero(
      tag: 'remoteVideo',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RTCVideoView(
          widget.webRTCHandler.remoteRenderer,
          mirror: true,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: _onTap,
        onPanUpdate: _onPanUpdate,
        // onScaleUpdate: _onScaleUpdate,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: widget.webRTCHandler.isCallAccepted,
              builder: (context, callAccepted, _) {
                return Stack(
                  children: [
                    widget.webRTCHandler.isCaller
                        ? _localVideoWidget()
                        : _remoteVideoWidget(),
                    if (callAccepted)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: _localVideoWidget(),
                      ),
                    if (showControls) ...[
                      Positioned(
                        top: 3,
                        right: 3,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: widget.onClose,
                        ),
                      ),
                      Center(
                        child: IconButton(
                          icon:
                              const Icon(Icons.fullscreen, color: Colors.white),
                          onPressed: widget.onFullscreen,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
