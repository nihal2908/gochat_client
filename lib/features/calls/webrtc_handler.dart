import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/calls/call_page.dart';
import 'package:whatsapp_clone/features/calls/floating_call_widget.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/models/user.dart';

class WebRTCHandler {
  static final WebRTCHandler _instance = WebRTCHandler._internal();
  factory WebRTCHandler() => _instance;
  WebRTCHandler._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  late RTCVideoRenderer localRenderer;
  late RTCVideoRenderer remoteRenderer;
  BuildContext? appContext;
  WebSocketService? webSocketService;
  DBHelper? dbHelper;
  bool _remoteDescriptionSet = false;
  final List<RTCIceCandidate> _cachedCandidates = [];

  String? selfId;
  String? remoteId;
  bool isCaller = false;
  final ValueNotifier<bool>  isInCall = ValueNotifier<bool>(false);
  final ValueNotifier<String> callStatus = ValueNotifier<String>('');
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> videoOff = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isSpeakerOn = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isCallAccepted = ValueNotifier<bool>(false);
  final ValueNotifier<Duration> callDuration = ValueNotifier(Duration.zero);

  Timer? _callTimer;

  bool isVideoCall = false;
  User? caller;
  User? receiver;

  bool get isVideo => isVideoCall;
  bool get isCallInitiator => isCaller;
  User? get callReceiver => receiver;
  User? get callCaller => caller;

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
    if (isVideoCall) {
      localRenderer = RTCVideoRenderer();
      remoteRenderer = RTCVideoRenderer();

      await localRenderer.initialize();
      await remoteRenderer.initialize();
    }

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
        _startTimer();
        _remoteStream = event.streams[0];
        if (isVideoCall) {
          remoteRenderer.srcObject = _remoteStream;
        }
      }
    };
  }

  Future<void> _getUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': isVideoCall
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'maxWidth': '640',
                'maxHeight': '480',
                'minFrameRate': '15',
                'maxFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    if (isVideoCall) {
      localRenderer.srcObject = _localStream;
    }
  }

  Future<void> startCall({
    required String toUserId,
    required bool videoCall,
  }) async {
    if (dbHelper == null || webSocketService == null) {
      if (kDebugMode) {
        print('DBHelper or WebSocketService is not initialized');
      }
      return;
    }
    caller = User.fromMap(await dbHelper!.getCurrentUser());
    receiver = User.fromMap(
        await dbHelper!.getUserById(toUserId) as Map<String, dynamic>);
    isCaller = true;
    remoteId = toUserId;
    isInCall.value = true;
    isVideoCall = videoCall;

    await _createPeerConnection();

    await _getUserMedia();
    callStatus.value = 'Calling...';

    for (var track in _localStream!.getTracks()) {
      _peerConnection?.addTrack(track, _localStream!);
    }

    RTCSessionDescription offer = await _peerConnection!.createOffer();

    _sendSignal({
      'type': 'webrtc_offer',
      'data': {
        ...offer.toMap() as Map<String, dynamic>,
        'call_type': videoCall ? 'video' : 'audio'
      },
    });

    await _peerConnection!.setLocalDescription(offer);

    _openCallPage();
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
        isVideoCall = data['call_type'] == 'video';
        if (_peerConnection == null) {
          await _createPeerConnection();
          await _getUserMedia();
          for (var track in _localStream!.getTracks()) {
            _peerConnection?.addTrack(track, _localStream!);
          }
        }

        isInCall.value = true;
        isCaller = false;

        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']),
        );

        _sendSignal({
          'type': 'webrtc_delivered',
          'data': {},
        });

        _openCallPage();

        break;

      case 'webrtc_answer':
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']),
        );

        callStatus.value = 'Connecting...';
        isCallAccepted.value = true;
        _remoteDescriptionSet = true;

        for (var candidate in _cachedCandidates) {
          _sendSignal({
            'type': 'webrtc_candidate',
            'data': candidate.toMap(),
          });
        }
        _cachedCandidates.clear();

        break;

      case 'webrtc_delivered':
        callStatus.value = 'Ringing...';
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

    isCallAccepted.value = true;

    _sendSignal({
      'data': answer.toMap(),
      'type': 'webrtc_answer',
    });

    _remoteDescriptionSet = true;
    callStatus.value = 'Connecting...';

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

  void toggleMuteAudio() {
    final audioTrack = _localStream?.getAudioTracks().first;
    if (audioTrack != null) {
      isMuted.value = !isMuted.value;
      audioTrack.enabled = !isMuted.value;
    }
  }

  void toggleVideo() {
    if (!isVideoCall) return;
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      videoOff.value = !videoOff.value;
      videoTrack.enabled = !videoOff.value;
    }
  }

  Future<void> switchCamera() async {
    if (!isVideoCall) return;
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
    }
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await Helper.setSpeakerphoneOn(isSpeakerOn.value);
  }

  void _startTimer() {
    _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      callDuration.value += Duration(seconds: 1);
    });
  }

  void _stopTimer() {
    _callTimer?.cancel();
    callDuration.value = Duration.zero;
    _callTimer = null;
  }

  OverlayEntry? _floatingOverlay;

void showFloatingWindow() {
  if (_floatingOverlay != null || appContext == null) return;

  _floatingOverlay = OverlayEntry(
    builder: (context) {
      return FloatingCallWidget(
        webRTCHandler: this,
        onClose: () {
          _floatingOverlay?.remove();
          _floatingOverlay = null;
        },
        onFullscreen: () {
          _floatingOverlay?.remove();
          _floatingOverlay = null;
          _openCallPage(); // reopen call page
        },
      );
    },
  );

  Overlay.of(appContext!).insert(_floatingOverlay!);
}


  void _closeCall() async {
    _stopTimer();
    await _peerConnection?.close();
    _peerConnection = null;

    _localStream?.getAudioTracks().forEach((t) => t.enabled = false);

    await _localStream?.dispose();
    await _remoteStream?.dispose();

    if (isVideoCall) {
      localRenderer.srcObject = null;
      await localRenderer.dispose();

      remoteRenderer.srcObject = null;
      await remoteRenderer.dispose();
    }

    isMuted.value = false;
    videoOff.value = false;
    isSpeakerOn.value = true;
    isCallAccepted.value = false;
    callStatus.value = '';
    _remoteDescriptionSet = false;
    isInCall.value = false;
    isCaller = false;
    isVideoCall = false;
    caller = null;
    receiver = null;
    remoteId = null;

    if (appContext != null) {
      Navigator.of(appContext!).pop();
    }
  }

  void _openCallPage() {
    if (appContext == null) return;

    Navigator.of(appContext!).push(
      MaterialPageRoute(
        builder: (_) => CallPage(
          webRTCHandler: this,
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
