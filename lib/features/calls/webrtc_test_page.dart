import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/models/user.dart';

class WebRTCTestPage extends StatefulWidget {
  final String remoteUserId;
  final WebSocketChannel webSocketChannel;

  const WebRTCTestPage({
    Key? key,
    required this.remoteUserId,
    required this.webSocketChannel,
  }) : super(key: key);

  @override
  State<WebRTCTestPage> createState() => _WebRTCTestPageState();

  static late String _localUserId;
  static late String _remoteUserId;
  static late WebSocketChannel _ws;
  static late RTCPeerConnection _peerConnection;
  static late MediaStream _localStream;
  static late RTCVideoRenderer _localRenderer;
  static late RTCVideoRenderer _remoteRenderer;

  static Future<void> initWebRTC({
    required String localUserId,
    required String remoteUserId,
    required RTCVideoRenderer localRenderer,
    required RTCVideoRenderer remoteRenderer,
    required WebSocketChannel ws,
  }) async {
    _localUserId = localUserId;
    _remoteUserId = remoteUserId;
    _localRenderer = localRenderer;
    _remoteRenderer = remoteRenderer;
    _ws = ws;

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      _sendSignal('webrtc_ice_candidate', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _localRenderer.srcObject = _localStream;
    for (var track in _localStream.getTracks()) {
      _peerConnection.addTrack(track, _localStream);
    }
  }

  static void _sendSignal(String type, Map<String, dynamic> data) {
    final signal = {
      'type': type,
      'data': {
        'sender_id': _localUserId,
        'receiver_id': _remoteUserId,
        ...data,
      },
    };
    _ws.sink.add(jsonEncode(signal));
  }

  static Future<void> handleOffer(Map<String, dynamic> data, User caller) async {
    print('this called');
    await initWebRTC(
      localUserId: data['sender_id'],
      remoteUserId: data['receiver_id'],
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
      ws: _ws,
    );
    print('this called');

    final offer = RTCSessionDescription(data['sdp'], data['type']);
    print('this called');
    await _peerConnection.setRemoteDescription(offer);
    print('this called');
    final answer = await _peerConnection.createAnswer();
    print('this called');
    await _peerConnection.setLocalDescription(answer);
    print('this called');
    _sendSignal('webrtc_answer', {
      'sdp': answer.sdp,
      'type': answer.type,
    });
    print('this called');
  }

  static Future<void> handleAnswer(Map<String, dynamic> data) async {
    final answer = RTCSessionDescription(data['sdp'], data['type']);
    await _peerConnection.setRemoteDescription(answer);
  }

  static Future<void> handleIceCandidate(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
      data['candidate'],
      data['sdpMid'],
      data['sdpMLineIndex'],
    );
    await _peerConnection.addCandidate(candidate);
  }
}

class _WebRTCTestPageState extends State<WebRTCTestPage> {
  final _remoteRenderer = RTCVideoRenderer();
  final _localRenderer = RTCVideoRenderer();
  final TextEditingController _receiverIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _receiverIdController.text = widget.remoteUserId;
    _localRenderer.initialize();
    _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _receiverIdController.dispose();
    super.dispose();
  }

  Future<void> _startCall() async {
    final remoteId = _receiverIdController.text.trim();
    if (remoteId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receiver ID is required")),
      );
      return;
    }

    await WebRTCTestPage.initWebRTC(
      localUserId: CurrentUser().UserId!,
      remoteUserId: remoteId,
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
      ws: widget.webSocketChannel,
    );

    final offer = await WebRTCTestPage._peerConnection.createOffer();
    await WebRTCTestPage._peerConnection.setLocalDescription(offer);

    WebRTCTestPage._sendSignal('webrtc_offer', {
      'sdp': offer.sdp,
      'type': offer.type,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebRTC Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _receiverIdController,
              decoration: const InputDecoration(labelText: 'Receiver ID'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _startCall,
              child: const Text('Start Call'),
            ),
            const SizedBox(height: 20),
            const Text('Local Video'),
            SizedBox(
                height: 180, child: RTCVideoView(_localRenderer, mirror: true)),
            const SizedBox(height: 12),
            const Text('Remote Video'),
            SizedBox(height: 180, child: RTCVideoView(_remoteRenderer)),
          ],
        ),
      ),
    );
  }
}
