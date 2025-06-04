import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:whatsapp_clone/features/calls/webrtc_handler.dart';

class CallPage extends StatefulWidget {
  final WebRTCHandler webRTCHandler;

  const CallPage({super.key, required this.webRTCHandler});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool callAccepted = false;

  WebRTCHandler get handler => widget.webRTCHandler;

  @override
void initState() {
  super.initState();

  handler.isInCall.addListener(() {
    if (!handler.isInCall.value) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          if (handler.isVideoCall) {
            handler.showFloatingWindow();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ValueListenableBuilder<bool>(
          valueListenable: handler.isCallAccepted,
          builder: (context, callAccepted, _) {
            return callAccepted
                ? _ongoingCallUI()
                : handler.isCaller
                    ? _outgoingCallUI()
                    : _incomingCallUI();
          },
        ),
      ),
    );
  }

  Widget _incomingCallUI() {
    return Stack(
      children: [
        handler.isVideo
            ? Hero(
                tag: 'localVideo',
                child: RTCVideoView(handler.localRenderer, mirror: true))
            : handler.isCallAccepted.value
                ? Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          handler.caller?.ProfilePictureUrl != null &&
                                  handler.caller!.ProfilePictureUrl!.isNotEmpty
                              ? NetworkImage(handler.caller!.ProfilePictureUrl!)
                              : const AssetImage(
                                      'assets/images/default_profile.jpg')
                                  as ImageProvider,
                    ),
                  )
                : Container(),
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: handler.caller?.ProfilePictureUrl != null &&
                        handler.caller!.ProfilePictureUrl!.isNotEmpty
                    ? NetworkImage(handler.caller!.ProfilePictureUrl!)
                    : const AssetImage('assets/images/default_profile.jpg')
                        as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                handler.caller?.Title ?? "Unknown User",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                handler.isVideo
                    ? "Incoming Video Call..."
                    : "Incoming Voice Call...",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          right: 0,
          left: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  await handler.acceptCall();
                  setState(
                    () => callAccepted = true,
                  );
                },
                child: const Icon(Icons.call),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  handler.declineCall();
                  // Navigator.pop(context);
                },
                child: const Icon(Icons.call_end),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _outgoingCallUI() {
    return Stack(
      children: [
        handler.isVideo
            ? Hero(
                tag: 'loaclVideo',
                child: RTCVideoView(handler.localRenderer, mirror: true))
            : Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: handler.receiver?.ProfilePictureUrl !=
                              null &&
                          handler.receiver!.ProfilePictureUrl!.isNotEmpty
                      ? NetworkImage(handler.receiver!.ProfilePictureUrl!)
                      : const AssetImage('assets/images/default_profile.jpg')
                          as ImageProvider,
                ),
              ),
        Positioned(
          top: 45,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                handler.receiver?.Title ?? "Unknown User",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                "Calling...",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          right: 0,
          left: 0,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                handler.hangUp();
                // Navigator.pop(context);
              },
              child: const Icon(Icons.call_end),
            ),
          ),
        )
      ],
    );
  }

  Widget _ongoingCallUI() {
    return handler.isVideo
        ? Stack(
            children: [
              Positioned.fill(
                  child: Hero(
                      tag: 'remoteVideo',
                      child: RTCVideoView(handler.remoteRenderer))),
              Positioned(
                bottom: 10,
                right: 10,
                width: 120,
                height: 160,
                child: Hero(
                  tag: 'localVideo',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: RTCVideoView(handler.localRenderer, mirror: true),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: handler.isMuted,
                      builder: (_, isMuted, __) => IconButton(
                        icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
                        color: Colors.white,
                        onPressed: handler.toggleMuteAudio,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: handler.videoOff,
                      builder: (_, videoOff, __) => IconButton(
                        icon: Icon(
                            videoOff ? Icons.videocam_off : Icons.videocam),
                        color: Colors.white,
                        onPressed: handler.toggleVideo,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.switch_camera),
                      color: Colors.white,
                      onPressed: handler.switchCamera,
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: handler.isSpeakerOn,
                      builder: (_, speakerOn, __) => IconButton(
                        icon: Icon(
                            speakerOn ? Icons.volume_up : Icons.volume_off),
                        color: Colors.white,
                        onPressed: handler.toggleSpeaker,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end),
                      color: Colors.red,
                      onPressed: () {
                        handler.hangUp();
                        // Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          )
        : Stack(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: handler.receiver?.ProfilePictureUrl !=
                              null &&
                          handler.receiver!.ProfilePictureUrl!.isNotEmpty
                      ? NetworkImage(handler.receiver!.ProfilePictureUrl!)
                      : const AssetImage('assets/images/default_profile.jpg')
                          as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: handler.isMuted,
                      builder: (_, isMuted, __) => IconButton(
                        icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
                        color: Colors.white,
                        onPressed: handler.toggleMuteAudio,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: handler.isSpeakerOn,
                      builder: (_, speakerOn, __) => IconButton(
                        icon: Icon(
                            speakerOn ? Icons.volume_up : Icons.volume_off),
                        color: Colors.white,
                        onPressed: handler.toggleSpeaker,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end),
                      color: Colors.red,
                      onPressed: () {
                        handler.hangUp();
                        // Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  @override
  void dispose() {
    super.dispose();
    // Do not dispose video renderers if managed inside handler
  }
}
