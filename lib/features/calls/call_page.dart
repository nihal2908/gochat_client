import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:whatsapp_clone/models/user.dart';

class CallPage extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final bool isCaller;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onHangUp;
  final User caller;
  final User receiver;

  const CallPage({
    super.key,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.isCaller,
    required this.onAccept,
    required this.onDecline,
    required this.onHangUp,
    required this.caller,
    required this.receiver,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool callAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: callAccepted
          ? _ongoingCallUI()
          : widget.isCaller
              ? _outgoingCallUI()
              : _incomingCallUI(),
    );
  }

  Widget _incomingCallUI() {
    return Stack(
      children: [
        RTCVideoView(widget.localRenderer, mirror: true),
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: widget.caller.ProfilePictureUrl != null
                    ? NetworkImage(widget.caller.ProfilePictureUrl!)
                    : AssetImage(
                        'assets/images/default_profile.jpg',
                      ), // Replace with caller avatar
              ),
              const SizedBox(height: 16),
              Text(
                widget.caller.Title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Incoming Call...",
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
                onPressed: () {
                  widget.onAccept();
                  setState(() => callAccepted = true);
                },
                child: const Icon(Icons.call),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  widget.onDecline();
                  Navigator.pop(context);
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
        RTCVideoView(widget.localRenderer, mirror: true),
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                widget.receiver.Title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Calling...",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          right: 0,
          left: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              widget.onHangUp();
              Navigator.pop(context);
            },
            child: const Icon(Icons.call_end),
          ),
        )
      ],
    );
  }

  Widget _ongoingCallUI() {
    return Stack(
      children: [
        Positioned.fill(
          child: RTCVideoView(widget.remoteRenderer),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          width: 120,
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: RTCVideoView(widget.localRenderer, mirror: true),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.onHangUp();
                Navigator.pop(context);
              },
              child: const Icon(Icons.call_end),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Do not dispose renderers here if WebRTCHandler manages them
  }
}
