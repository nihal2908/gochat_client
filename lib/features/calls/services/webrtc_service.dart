// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:uuid/uuid.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
// import 'package:whatsapp_clone/secrets/secrets.dart';
// import '../../../models/call_model.dart';

// String socketServerUrl = Secrets.websocketUrl;

// class WebRTCService {
//   // WebRTC connections
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   MediaStream? _remoteStream;

//   // Signaling server connection
//   String? _userId;
//   String? _sessionId;

//   // Call info
//   CallModel? _currentCall;
//   final StreamController<CallModel> _callStreamController =
//       StreamController<CallModel>.broadcast();
//   Stream<CallModel> get callStream => _callStreamController.stream;

//   // Media streams
//   final StreamController<MediaStream> _localStreamController =
//       StreamController<MediaStream>.broadcast();
//   final StreamController<MediaStream> _remoteStreamController =
//       StreamController<MediaStream>.broadcast();
//   Stream<MediaStream> get localStreamStream => _localStreamController.stream;
//   Stream<MediaStream> get remoteStreamStream => _remoteStreamController.stream;

//   // Singleton implementation
//   static final WebRTCService _instance = WebRTCService._internal();
//   factory WebRTCService() => _instance;
//   WebRTCService._internal();

//   WebSocketService? _webSocketService;

//   // Initialize the service
//   Future<void> initialize(WebSocketService webSocketService) async {
//     _webSocketService = webSocketService;
//     await _initializeSocket();
//   }

//   // Clean up resources when not needed
//   Future<void> dispose() async {
//     await _cleanUp();
//     _callStreamController.close();
//     _localStreamController.close();
//     _remoteStreamController.close();
//   }

//   // Initialize WebSocket connection and event handlers
//   Future<void> _initializeSocket() async {}

//   // Create a new call
//   Future<CallModel> createCall({
//     required String callerId,
//     required String callerName,
//     String? callerAvatar,
//     required String receiverId,
//     required String receiverName,
//     String? receiverAvatar,
//     required bool isVideoCall,
//   }) async {
//     // Generate a new call
//     final call = CallModel.newCall(
//       callerId: callerId,
//       callerName: callerName,
//       callerAvatar: callerAvatar,
//       receiverId: receiverId,
//       receiverName: receiverName,
//       receiverAvatar: receiverAvatar,
//       isVideoCall: isVideoCall,
//     );

//     _sessionId = const Uuid().v4();
//     _currentCall = call.copyWith(
//       sessionId: _sessionId,
//       status: CallStatus.ringing,
//     );

//     // Initialize local stream
//     await _initializeMediaDevices(isVideoCall);

//     // Create offer
//     await _createPeerConnection();

//     _callStreamController.add(_currentCall!);
//     return _currentCall!;
//   }

//   // Answer an incoming call
//   Future<void> answerCall(CallModel call) async {
//     _currentCall = call.copyWith(status: CallStatus.connecting);
//     _sessionId = call.sessionId;

//     // Initialize local stream
//     await _initializeMediaDevices(call.isVideoCall);

//     // Create peer connection and answer
//     await _createPeerConnection();

//     _callStreamController.add(_currentCall!);
//   }

//   // End the current call
//   Future<void> endCall({bool notifyRemote = true}) async {
//     if (_currentCall != null) {
//       final endedCall = _currentCall!.copyWith(
//         status: CallStatus.ended,
//         duration: DateTime.now().difference(_currentCall!.timestamp).inSeconds,
//       );
//       _currentCall = endedCall;

//       if (notifyRemote && _webSocketService != null && _sessionId != null) {}

//       _callStreamController.add(endedCall);
//       await _cleanUp();
//     }
//   }

//   // Decline an incoming call
//   Future<void> declineCall(CallModel call) async {
//     final declinedCall = call.copyWith(
//       status: CallStatus.declined,
//       isMissed: true,
//     );

//     if (_webSocketService != null) {
//       _webSocketService!.sendToWebSocket({
//         'type': 'decline-call',
//         'data': {
//           'to': call.callerId,
//           'sessionId': call.sessionId,
//           'call': declinedCall.toJson(),
//         },
//       });
//     }

//     if (call.id == _currentCall?.id) {
//       _currentCall = declinedCall;
//       _callStreamController.add(declinedCall);
//       await _cleanUp();
//     }
//   }

//   // Toggle audio mute status
//   Future<bool> toggleMute() async {
//     if (_localStream != null) {
//       final audioTrack = _localStream!.getAudioTracks().first;
//       final muted = !audioTrack.enabled;
//       audioTrack.enabled = muted;
//       return muted;
//     }
//     return false;
//   }

//   // Toggle camera (front/back)
//   Future<void> toggleCamera() async {
//     if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
//       final videoTrack = _localStream!.getVideoTracks().first;
//       await Helper.switchCamera(videoTrack);
//     }
//   }

//   // Toggle speaker
//   Future<void> toggleSpeaker(bool speakerOn) async {
//     await Helper.setSpeakerphoneOn(speakerOn);
//   }

//   // Initialize media devices for audio/video
//   Future<void> _initializeMediaDevices(bool isVideoCall) async {
//     final mediaConstraints = <String, dynamic>{
//       'audio': true,
//       'video': isVideoCall
//           ? {
//               'mandatory': {
//                 'minWidth': '640',
//                 'minHeight': '480',
//                 'minFrameRate': '30',
//               },
//               'facingMode': 'user',
//               'optional': [],
//             }
//           : false,
//     };

//     try {
//       _localStream =
//           await navigator.mediaDevices.getUserMedia(mediaConstraints);
//       _localStreamController.add(_localStream!);
//     } catch (e) {
//       debugPrint('Error getting user media: $e');
//       throw Exception('Could not get user media: $e');
//     }
//   }

//   // Create and initialize the peer connection
//   Future<void> _createPeerConnection() async {
//     final configuration = <String, dynamic>{
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//         {
//           'urls': Secrets.turnServerUrl,
//           'username': Secrets.turn_username,
//           'credential': Secrets.turn_password,
//         },
//       ],
//       'sdpSemantics': 'unified-plan'
//     };

//     _peerConnection = await createPeerConnection(configuration);

//     // Add local stream to peer connection
//     if (_localStream != null) {
//       _localStream!.getTracks().forEach((track) {
//         _peerConnection!.addTrack(track, _localStream!);
//       });
//     }

//     // Set up event listeners
//     _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
//       if (_webSocketService != null && _currentCall != null) {
//         final recipientId = _currentCall!.isOutgoing
//             ? _currentCall!.receiverId
//             : _currentCall!.callerId;

//         _webSocketService!.sendToWebSocket({
//           'type': 'ice-candidate',
//           'data': {
//             'to': recipientId,
//             'sessionId': _sessionId,
//             'candidate': {
//               'sdpMLineIndex': candidate.sdpMLineIndex,
//               'sdpMid': candidate.sdpMid,
//               'candidate': candidate.candidate,
//             },
//           },
//         });
//       }
//     };

//     _peerConnection!.onTrack = (RTCTrackEvent event) {
//       if (event.streams.isNotEmpty) {
//         _remoteStream = event.streams[0];
//         _remoteStreamController.add(_remoteStream!);
//       }
//     };

//     // Create offer if initiating call
//     if (_currentCall!.isOutgoing) {
//       try {
//         final offer = await _peerConnection!.createOffer();
//         await _peerConnection!.setLocalDescription(offer);

//         _webSocketService!.sendToWebSocket({
//           'type': 'call-offer',
//           'data': {
//             'to': _currentCall!.receiverId,
//             'from': _currentCall!.callerId,
//             'sessionId': _sessionId,
//             'sdp': offer.sdp,
//             'type': offer.type,
//             'call': _currentCall!.toJson(),
//           },
//         });
//       } catch (e) {
//         debugPrint('Error creating offer: $e');
//       }
//     }
//   }

//   // Handle incoming WebRTC offer
//   Future<void> handleOffer(dynamic data) async {
//     if (data == null || _peerConnection == null) return;

//     final fromId = data['from'];
//     final sessionId = data['sessionId'];
//     final sdp = data['sdp'];
//     final type = data['type'];
//     final callData = data['call'];

//     if (callData != null) {
//       final incomingCall = CallModel.fromJson(jsonDecode(callData));
//       _currentCall = incomingCall;
//       _sessionId = sessionId;
//       _callStreamController.add(_currentCall!);
//     }

//     await _peerConnection!.setRemoteDescription(
//       RTCSessionDescription(sdp, type),
//     );

//     final answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);

//     _webSocketService!.sendToWebSocket({
//       'type': 'call-answer',
//       'data': {
//         'to': fromId,
//         'sessionId': sessionId,
//         'sdp': answer.sdp,
//         'type': answer.type,
//       },
//     });

//     _currentCall = _currentCall!.copyWith(status: CallStatus.connected);
//     _callStreamController.add(_currentCall!);
//   }

//   // Handle answer to our offer
//   Future<void> handleAnswer(dynamic data) async {
//     if (data == null || _peerConnection == null) return;

//     final sessionId = data['sessionId'];
//     final sdp = data['sdp'];
//     final type = data['type'];

//     if (sessionId == _sessionId) {
//       await _peerConnection!.setRemoteDescription(
//         RTCSessionDescription(sdp, type),
//       );

//       _currentCall = _currentCall!.copyWith(status: CallStatus.connected);
//       _callStreamController.add(_currentCall!);
//     }
//   }

//   // Handle ICE candidate from remote peer
//   Future<void> handleIceCandidate(dynamic data) async {
//     if (data == null || _peerConnection == null) return;

//     final sessionId = data['sessionId'];
//     final candidateData = data['candidate'];

//     if (sessionId == _sessionId && candidateData != null) {
//       final candidate = RTCIceCandidate(
//         candidateData['candidate'],
//         candidateData['sdpMid'],
//         candidateData['sdpMLineIndex'],
//       );

//       await _peerConnection!.addCandidate(candidate);
//     }
//   }

//   // Handle remote call ending
//   Future<void> handleCallEnded(dynamic data) async {
//     if (data == null) return;

//     final sessionId = data['sessionId'];
//     final callData = data['call'];

//     if (sessionId == _sessionId && callData != null) {
//       final remoteCall = CallModel.fromJson(jsonDecode(callData));
//       _currentCall = remoteCall;
//       _callStreamController.add(_currentCall!);
//       await _cleanUp();
//     }
//   }

//   // Clean up resources
//   Future<void> _cleanUp() async {
//     if (_localStream != null) {
//       _localStream!.getTracks().forEach((track) {
//         track.stop();
//       });
//       _localStream = null;
//     }

//     _remoteStream = null;

//     if (_peerConnection != null) {
//       await _peerConnection!.close();
//       _peerConnection = null;
//     }

//     _sessionId = null;
//   }
// }
