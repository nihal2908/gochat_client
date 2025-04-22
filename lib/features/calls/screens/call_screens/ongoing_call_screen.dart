// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:provider/provider.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:intl/intl.dart';
// import '../../../../common/theme.dart';
// import '../../../../models/call_model.dart';
// import '../../providers/call_provider.dart';

// class OngoingCallScreen extends StatefulWidget {
//   final CallModel call;

//   const OngoingCallScreen({
//     super.key,
//     required this.call,
//   });

//   @override
//   State<OngoingCallScreen> createState() => _OngoingCallScreenState();
// }

// class _OngoingCallScreenState extends State<OngoingCallScreen> {
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   bool _controlsVisible = true;
//   Timer? _controlsTimer;
//   Timer? _callDurationTimer;
//   Duration _callDuration = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     // Keep screen on during call
//     WakelockPlus.enable();
//     _initRenderers();
//     _startCallTimer();
//     _resetControlsTimer();
//   }

//   Future<void> _initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();

//     final callProvider = Provider.of<CallProvider>(context, listen: false);

//     if (callProvider.localStream != null) {
//       _localRenderer.srcObject = callProvider.localStream;
//     }

//     if (callProvider.remoteStream != null) {
//       _remoteRenderer.srcObject = callProvider.remoteStream;
//     }

//     setState(() {});
//   }

//   void _startCallTimer() {
//     _callDurationTimer = Timer.periodic(
//       const Duration(seconds: 1),
//       (timer) {
//         setState(() {
//           _callDuration = Duration(seconds: timer.tick);
//         });
//       },
//     );
//   }

//   void _resetControlsTimer() {
//     _controlsTimer?.cancel();
//     setState(() {
//       _controlsVisible = true;
//     });

//     if (widget.call.isVideoCall) {
//       _controlsTimer = Timer(const Duration(seconds: 5), () {
//         if (mounted) {
//           setState(() {
//             _controlsVisible = false;
//           });
//         }
//       });
//     }
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));

//     return duration.inHours > 0
//         ? '$hours:$minutes:$seconds'
//         : '$minutes:$seconds';
//   }

//   @override
//   void dispose() {
//     WakelockPlus.disable();
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _controlsTimer?.cancel();
//     _callDurationTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final callProvider = Provider.of<CallProvider>(context);

//     // Listen for call status changes and exit if call ended
//     final currentCall = callProvider.currentCall;
//     if (currentCall != null &&
//         (currentCall.status == CallStatus.ended ||
//             currentCall.status == CallStatus.declined ||
//             currentCall.status == CallStatus.timedOut)) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pop(context);
//       });
//     }

//     return WillPopScope(
//       onWillPop: () async => false, // Prevent back button
//       child: Scaffold(
//         body: GestureDetector(
//           onTap: _resetControlsTimer,
//           child: widget.call.isVideoCall
//               ? _buildVideoCallUI(callProvider)
//               : _buildAudioCallUI(callProvider),
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoCallUI(CallProvider callProvider) {
//     final size = MediaQuery.of(context).size;
//     final hasRemoteStream = callProvider.remoteStream != null;

//     return Stack(
//       children: [
//         // Remote video (full screen)
//         hasRemoteStream &&
//                 callProvider.remoteStream!.getVideoTracks().isNotEmpty
//             ? RTCVideoView(
//                 _remoteRenderer,
//                 objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//               )
//             : Container(
//                 color: Colors.black,
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircleAvatar(
//                         radius: 70,
//                         backgroundColor: WhatsAppTheme.lightGreen,
//                         child: widget.call.getDisplayAvatar != null
//                             ? CircleAvatar(
//                                 radius: 65,
//                                 backgroundImage:
//                                     NetworkImage(widget.call.getDisplayAvatar!),
//                               )
//                             : const Icon(
//                                 Icons.person,
//                                 size: 65,
//                                 color: Colors.white,
//                               ),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         widget.call.getDisplayName,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         hasRemoteStream
//                             ? callProvider.currentCall?.getStatusText ??
//                                 'Connecting...'
//                             : 'Connecting...',
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//         // Call duration
//         Positioned(
//           top: 60,
//           left: 0,
//           right: 0,
//           child: Visibility(
//             visible: _controlsVisible,
//             child: Column(
//               children: [
//                 Text(
//                   _formatDuration(_callDuration),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (callProvider.currentCall?.status == CallStatus.connecting)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       'Connecting...',
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),

//         // Local video (picture-in-picture)
//         if (callProvider.localStream != null && callProvider.isVideoEnabled)
//           Positioned(
//             top: 100,
//             right: 20,
//             child: Container(
//               width: size.width * 0.3,
//               height: size.width * 0.4,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: RTCVideoView(
//                   _localRenderer,
//                   mirror: true,
//                   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                 ),
//               ),
//             ),
//           ),

//         // Call controls
//         Positioned(
//           bottom: 50,
//           left: 0,
//           right: 0,
//           child: AnimatedOpacity(
//             opacity: _controlsVisible ? 1.0 : 0.0,
//             duration: const Duration(milliseconds: 200),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildCallControlButton(
//                   icon: callProvider.isMuted ? Icons.mic_off : Icons.mic,
//                   label: callProvider.isMuted ? 'Unmute' : 'Mute',
//                   onPressed: () => callProvider.toggleMute(),
//                 ),
//                 _buildCallControlButton(
//                   icon: Icons.call_end,
//                   backgroundColor: Colors.red,
//                   label: 'End',
//                   onPressed: () => callProvider.endCall(),
//                 ),
//                 _buildCallControlButton(
//                   icon: callProvider.isVideoEnabled
//                       ? Icons.videocam
//                       : Icons.videocam_off,
//                   label: callProvider.isVideoEnabled
//                       ? 'Stop Video'
//                       : 'Start Video',
//                   onPressed: () => callProvider.toggleVideo(),
//                 ),
//                 _buildCallControlButton(
//                   icon: Icons.cameraswitch,
//                   label: 'Switch',
//                   onPressed: () => callProvider.toggleCamera(),
//                 ),
//                 _buildCallControlButton(
//                   icon: callProvider.isSpeakerOn
//                       ? Icons.volume_up
//                       : Icons.volume_off,
//                   label: callProvider.isSpeakerOn ? 'Speaker' : 'Earpiece',
//                   onPressed: () => callProvider.toggleSpeaker(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAudioCallUI(CallProvider callProvider) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             WhatsAppTheme.tealGreen,
//             WhatsAppTheme.darkGreen,
//           ],
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 60),
//             CircleAvatar(
//               radius: 70,
//               backgroundColor: Colors.white.withOpacity(0.2),
//               child: widget.call.getDisplayAvatar != null
//                   ? CircleAvatar(
//                       radius: 65,
//                       backgroundImage:
//                           NetworkImage(widget.call.getDisplayAvatar!),
//                     )
//                   : const CircleAvatar(
//                       radius: 65,
//                       backgroundColor: WhatsAppTheme.lightGreen,
//                       child: Icon(
//                         Icons.person,
//                         size: 65,
//                         color: Colors.white,
//                       ),
//                     ),
//             ),
//             const SizedBox(height: 30),
//             Text(
//               widget.call.getDisplayName,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _formatDuration(_callDuration),
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 18,
//               ),
//             ),
//             if (callProvider.currentCall?.status == CallStatus.connecting)
//               const Padding(
//                 padding: EdgeInsets.only(top: 8.0),
//                 child: Text(
//                   'Connecting...',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             const Spacer(),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildCallControlButton(
//                     icon: callProvider.isMuted ? Icons.mic_off : Icons.mic,
//                     label: callProvider.isMuted ? 'Unmute' : 'Mute',
//                     onPressed: () => callProvider.toggleMute(),
//                   ),
//                   _buildCallControlButton(
//                     icon: Icons.call_end,
//                     backgroundColor: Colors.red,
//                     label: 'End',
//                     onPressed: () => callProvider.endCall(),
//                   ),
//                   _buildCallControlButton(
//                     icon: callProvider.isSpeakerOn
//                         ? Icons.volume_up
//                         : Icons.volume_off,
//                     label: callProvider.isSpeakerOn ? 'Speaker' : 'Earpiece',
//                     onPressed: () => callProvider.toggleSpeaker(),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCallControlButton({
//     required IconData icon,
//     required String label,
//     Color backgroundColor = Colors.white24,
//     required VoidCallback onPressed,
//   }) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         FloatingActionButton(
//           heroTag: label, // Needed to prevent hero animations conflict
//           onPressed: onPressed,
//           backgroundColor: backgroundColor,
//           mini: false,
//           child: Icon(icon, color: Colors.white),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }
