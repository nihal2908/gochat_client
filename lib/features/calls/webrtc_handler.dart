import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/calls/call_page.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/models/user.dart';

class WebRTCHandler {
  static final WebRTCHandler _instance = WebRTCHandler._internal();
  factory WebRTCHandler() => _instance;
  WebRTCHandler._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  BuildContext? appContext;
  WebSocketService? webSocketService;
  DBHelper? dbHelper;
  bool _remoteDescriptionSet = false;
  final List<RTCIceCandidate> _cachedCandidates = [];

  String? selfId;
  String? remoteId;
  bool isCaller = false;
  bool isInCall = false;
  User? caller;
  User? receiver;

  final _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  void init(
    BuildContext context, {
    required String self,
    required WebSocketService websocket,
    required DBHelper dbHelper,
  }) {
    appContext = context;
    webSocketService = websocket;
    this.dbHelper = dbHelper;
    selfId = self;
  }

  Future<void> _createPeerConnection() async {
    localRenderer.initialize();
    remoteRenderer.initialize();

    _peerConnection = await createPeerConnection(_iceServers);

    _peerConnection?.onIceCandidate = (candidate) {
      if (_remoteDescriptionSet) {
        _sendSignal({
          'type': 'webrtc_candidate',
          'data': candidate.toMap(),
        });
      } else {
        _cachedCandidates.add(candidate);
      }
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
      }
    };
  }

  Future<void> startCall(String toUserId) async {
    if (dbHelper == null || webSocketService == null) {
      if (kDebugMode) {
        print('DBHelper or WebSocketService is not initialized');
      }
      if (dbHelper == null) {
        print('DBHelper is null');
      }
      if (webSocketService == null) {
        print('WebSocketService is null');
      }
      return;
    }
    caller = User.fromMap(await dbHelper!.getCurrentUser());
    receiver = User.fromMap(
        await dbHelper!.getUserById(toUserId) as Map<String, dynamic>);
    isCaller = true;
    remoteId = toUserId;
    isInCall = true;

    await _createPeerConnection();
    await _getUserMedia();

    for (var track in _localStream!.getTracks()) {
      _peerConnection?.addTrack(track, _localStream!);
    }

    RTCSessionDescription offer = await _peerConnection!.createOffer();

    _sendSignal({
      'type': 'webrtc_offer',
      'data': offer.toMap(),
    });

    await _peerConnection!.setLocalDescription(offer);

    _openCallPage();
  }

  Future<void> _getUserMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      // 'video': {'facingMode': 'user'}
      'video': true,
    });
    localRenderer.srcObject = _localStream;
  }

  void handleSignal(Map<String, dynamic> msg) async {
    final String type = msg['type'];
    final Map<String, dynamic> data = msg['data'] as Map<String, dynamic>;
    final String sender = data['sender_id'];
    final callerUser = await dbHelper!.getCallerUserById(sender);
    if (callerUser != null) {
      caller = User.fromMap(callerUser);
    } else {
      if (kDebugMode) {
        print('Caller user not found for ID: $sender');
      }
      return;
    }
    receiver = User.fromMap(await dbHelper!.getCurrentUser());
    remoteId = sender;

    switch (type) {
      case 'webrtc_offer':
        if (_peerConnection == null) {
          await _createPeerConnection();
          await _getUserMedia();
          for (var track in _localStream!.getTracks()) {
            _peerConnection?.addTrack(track, _localStream!);
          }
        }

        isInCall = true;
        isCaller = false;

        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']),
        );

        _openCallPage();

        break;

      case 'webrtc_answer':
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']),
        );

        _remoteDescriptionSet = true;
        for (var candidate in _cachedCandidates) {
          _sendSignal({
            'type': 'webrtc_candidate',
            'data': candidate.toMap(),
          });
        }
        _cachedCandidates.clear();

        break;

      case 'webrtc_candidate':
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );
        await _peerConnection?.addCandidate(candidate);
        break;

      case 'webrtc_decline':
        _closeCall();
        break;

      case 'webrtc_hangup':
        _closeCall();
        break;
    }
  }

  Future<void> acceptCall() async {
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _sendSignal({
      'data': answer.toMap(),
      'type': 'webrtc_answer',
    });

    _remoteDescriptionSet = true;

    for (var candidate in _cachedCandidates) {
      _sendSignal({
        'type': 'webrtc_candidate',
        'data': candidate.toMap(),
      });
    }
  }

  void declineCall() {
    _sendSignal({
      'type': 'webrtc_decline',
      'data': {},
    });
    _closeCall();
  }

  void hangUp() {
    _sendSignal({
      'type': 'webrtc_hangup',
      'data': {},
    });
    _closeCall();
  }

  void _closeCall() {
    isInCall = false;
    isCaller = false;
    remoteId = null;

    _peerConnection?.close();
    _peerConnection = null;

    _localStream?.dispose();
    _remoteStream?.dispose();

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    if (appContext != null) {
      Navigator.of(appContext!).pop();
    }
  }

  void _openCallPage() {
    if (appContext == null) return;

    Navigator.of(appContext!).push(
      MaterialPageRoute(
        builder: (_) => CallPage(
          localRenderer: localRenderer,
          remoteRenderer: remoteRenderer,
          caller: caller!,
          receiver: receiver!,
          isCaller: isCaller,
          onAccept: acceptCall,
          onDecline: declineCall,
          onHangUp: hangUp,
        ),
      ),
    );
  }

  void _sendSignal(Map<String, dynamic> msg) {
    if (webSocketService == null) {
      if (kDebugMode) {
        print('WebSocketService is not initialized');
      }
      return;
    }

    msg['data']['sender_id'] = selfId;
    msg['data']['receiver_id'] = remoteId;
    msg['data']['timestamp'] = DateTime.now().toIso8601String();
    webSocketService!.send(msg);
  }
}
