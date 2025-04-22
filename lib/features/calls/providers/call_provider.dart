// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
// import '../../../models/call_model.dart';
// import '../services/webrtc_service.dart';

// class CallProvider with ChangeNotifier {
//   final WebRTCService _webRTCService = WebRTCService();

//   // Current call
//   CallModel? _currentCall;
//   CallModel? get currentCall => _currentCall;

//   // Stream subscriptions
//   StreamSubscription<CallModel>? _callSubscription;
//   StreamSubscription<MediaStream>? _localStreamSubscription;
//   StreamSubscription<MediaStream>? _remoteStreamSubscription;

//   // Media streams
//   MediaStream? _localStream;
//   MediaStream? _remoteStream;
//   MediaStream? get localStream => _localStream;
//   MediaStream? get remoteStream => _remoteStream;

//   // Call UI state
//   bool _isMuted = false;
//   bool _isSpeakerOn = true;
//   bool _isVideoEnabled = true;
//   bool get isMuted => _isMuted;
//   bool get isSpeakerOn => _isSpeakerOn;
//   bool get isVideoEnabled => _isVideoEnabled;

//   // Recent calls history
//   List<CallModel> _recentCalls = [];
//   List<CallModel> get recentCalls => _recentCalls;

//   // Initialize the provider
//   Future<void> initialize(WebSocketService webSocketService) async {
//     await _webRTCService.initialize(webSocketService);
//     _setupSubscriptions();
//     // Load recent calls from storage in a real app
//     _recentCalls = [];
//   }

//   // Set up stream subscriptions
//   void _setupSubscriptions() {
//     _callSubscription = _webRTCService.callStream.listen((call) {
//       _currentCall = call;

//       // If call ended, add to recent calls
//       if (call.status == CallStatus.ended ||
//           call.status == CallStatus.declined ||
//           call.status == CallStatus.timedOut) {
//         _addToRecentCalls(call);
//       }

//       notifyListeners();
//     });

//     _localStreamSubscription = _webRTCService.localStreamStream.listen((stream) {
//       _localStream = stream;
//       notifyListeners();
//     });

//     _remoteStreamSubscription = _webRTCService.remoteStreamStream.listen((stream) {
//       _remoteStream = stream;
//       notifyListeners();
//     });
//   }

//   // Initiate a new call
//   Future<void> startCall({
//     required String callerId,
//     required String callerName,
//     String? callerAvatar,
//     required String receiverId,
//     required String receiverName,
//     String? receiverAvatar,
//     required bool isVideoCall,
//   }) async {
//     try {
//       _isVideoEnabled = isVideoCall;
//       _currentCall = await _webRTCService.createCall(
//         callerId: callerId,
//         callerName: callerName,
//         callerAvatar: callerAvatar,
//         receiverId: receiverId,
//         receiverName: receiverName,
//         receiverAvatar: receiverAvatar,
//         isVideoCall: isVideoCall,
//       );
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error starting call: $e');
//       rethrow;
//     }
//   }

//   // Answer an incoming call
//   Future<void> answerCall(CallModel call) async {
//     try {
//       _isVideoEnabled = call.isVideoCall;
//       await _webRTCService.answerCall(call);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error answering call: $e');
//       rethrow;
//     }
//   }

//   // End the current call
//   Future<void> endCall() async {
//     try {
//       await _webRTCService.endCall();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error ending call: $e');
//       rethrow;
//     }
//   }

//   // Decline an incoming call
//   Future<void> declineCall(CallModel call) async {
//     try {
//       await _webRTCService.declineCall(call);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error declining call: $e');
//       rethrow;
//     }
//   }

//   // Toggle microphone mute
//   Future<void> toggleMute() async {
//     try {
//       _isMuted = await _webRTCService.toggleMute();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error toggling mute: $e');
//     }
//   }

//   // Toggle speaker
//   Future<void> toggleSpeaker() async {
//     try {
//       _isSpeakerOn = !_isSpeakerOn;
//       await _webRTCService.toggleSpeaker(_isSpeakerOn);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error toggling speaker: $e');
//     }
//   }

//   // Toggle camera (front/back)
//   Future<void> toggleCamera() async {
//     try {
//       await _webRTCService.toggleCamera();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error toggling camera: $e');
//     }
//   }

//   // Toggle video on/off
//   Future<void> toggleVideo() async {
//     if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
//       _isVideoEnabled = !_isVideoEnabled;
//       _localStream!.getVideoTracks()[0].enabled = _isVideoEnabled;
//       notifyListeners();
//     }
//   }

//   // Add a call to recent calls history
//   void _addToRecentCalls(CallModel call) {
//     // Add to the beginning of the list
//     _recentCalls = [call, ..._recentCalls];
//     // Limit to last 30 calls
//     if (_recentCalls.length > 30) {
//       _recentCalls = _recentCalls.sublist(0, 30);
//     }
//     // In a real app, save to storage here
//     notifyListeners();
//   }

//   // Clean up resources
//   @override
//   void dispose() {
//     _callSubscription?.cancel();
//     _localStreamSubscription?.cancel();
//     _remoteStreamSubscription?.cancel();
//     _webRTCService.dispose();
//     super.dispose();
//   }
// }
