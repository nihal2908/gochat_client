// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:whatsapp_clone/providers/webRTC_provider.dart';
// import '../../../../common/theme.dart';
// import '../../../../models/call_model.dart';

// class OutgoingCallPage extends StatefulWidget {

//   const OutgoingCallPage({
//     super.key,
//   });

//   @override
//   State<OutgoingCallPage> createState() => _OutgoingCallPageState();
// }

// class _OutgoingCallPageState extends State<OutgoingCallPage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   bool _callInitiated = false;

//   @override
//   void initState() {
//     super.initState();
//     // Keep the screen on during call
//     WakelockPlus.enable();

//     // Pulsating animation for rings
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     )..repeat(reverse: true);

//     _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _initiateCall();
//   }

//   Future<void> _initiateCall() async {
//     if (_callInitiated) return;

//     _callInitiated = true;
//     final callProvider = Provider.of<WebrtcProvider>(context, listen: false);

//     try {
//        callProvider.startCall();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to start call: $e')),
//         );
//         Navigator.pop(context);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     // Allow screen to turn off when this screen is disposed
//     WakelockPlus.disable();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final callProvider = Provider.of<WebrtcProvider>(context);
//     final currentCall = callProvider.currentCall;

//     // If call is connected, go to ongoing call screen
//     if (currentCall != null && currentCall.status == CallStatus.connected) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OngoingCallScreen(
//               call: currentCall,
//             ),
//           ),
//         );
//       });
//     }

//     // If call was declined or ended, go back
//     if (currentCall != null &&
//         (currentCall.status == CallStatus.declined ||
//          currentCall.status == CallStatus.ended ||
//          currentCall.status == CallStatus.busy ||
//          currentCall.status == CallStatus.timedOut)) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pop(context);
//       });
//     }

//     return WillPopScope(
//       onWillPop: () async => false, // Prevent back button
//       child: Scaffold(
//         body: Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 WhatsAppTheme.tealGreen.withOpacity(0.8),
//                 WhatsAppTheme.darkGreen,
//               ],
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 const SizedBox(height: 50),
//                 Text(
//                   widget.isVideoCall ? 'Video Calling' : 'Calling',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Animated ring effect
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Outer animated ring
//                     AnimatedBuilder(
//                       animation: _animation,
//                       builder: (context, child) {
//                         return Container(
//                           width: 150 * _animation.value,
//                           height: 150 * _animation.value,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.2),
//                               width: 2,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     // Middle animated ring
//                     AnimatedBuilder(
//                       animation: _animation,
//                       builder: (context, child) {
//                         return Container(
//                           width: 120 * _animation.value,
//                           height: 120 * _animation.value,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.3),
//                               width: 2,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     // Avatar
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       child: widget.receiverAvatar != null
//                           ? CircleAvatar(
//                               radius: 45,
//                               backgroundImage: NetworkImage(widget.receiverAvatar!),
//                             )
//                           : const CircleAvatar(
//                               radius: 45,
//                               backgroundColor: WhatsAppTheme.lightGreen,
//                               child: Icon(
//                                 Icons.person,
//                                 size: 45,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 24),
//                 Text(
//                   widget.receiverName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   currentCall?.getStatusText ?? 'Ringing...',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const Spacer(),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 50),
//                   child: FloatingActionButton(
//                     backgroundColor: Colors.red,
//                     onPressed: () {
//                       if (callProvider.currentCall != null) {
//                         callProvider.endCall();
//                       }
//                       Navigator.pop(context);
//                     },
//                     child: const Icon(
//                       Icons.call_end,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
