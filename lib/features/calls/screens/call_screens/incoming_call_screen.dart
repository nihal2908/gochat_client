// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import '../../../../common/theme.dart';
// import '../../../../models/call_model.dart';
// import '../../providers/call_provider.dart';
// import 'ongoing_call_screen.dart';

// class IncomingCallScreen extends StatefulWidget {
//   final CallModel call;

//   const IncomingCallScreen({
//     super.key,
//     required this.call,
//   });

//   @override
//   State<IncomingCallScreen> createState() => _IncomingCallScreenState();
// }

// class _IncomingCallScreenState extends State<IncomingCallScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     // Keep the screen on during call
//     WakelockPlus.enable();

//     // Pulsating animation for avatar
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     )..repeat(reverse: true);

//     _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );
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
//     final size = MediaQuery.of(context).size;
//     final callProvider = Provider.of<CallProvider>(context);

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
//                   widget.call.isVideoCall ? 'Video Call' : 'Voice Call',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 AnimatedBuilder(
//                   animation: _animation,
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: _animation.value,
//                       child: child,
//                     );
//                   },
//                   child: CircleAvatar(
//                     radius: 70,
//                     backgroundColor: Colors.white.withOpacity(0.2),
//                     child: widget.call.getDisplayAvatar != null
//                         ? CircleAvatar(
//                             radius: 65,
//                             backgroundImage: NetworkImage(widget.call.getDisplayAvatar!),
//                           )
//                         : const CircleAvatar(
//                             radius: 65,
//                             backgroundColor: WhatsAppTheme.lightGreen,
//                             child: Icon(
//                               Icons.person,
//                               size: 65,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   widget.call.getDisplayName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Opacity(
//                   opacity: 0.8,
//                   child: Text(
//                     'Incoming ${widget.call.isVideoCall ? 'video' : 'voice'} call...',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildCallActionButton(
//                         icon: Icons.call_end,
//                         backgroundColor: Colors.red,
//                         onPressed: () async {
//                           await callProvider.declineCall(widget.call);
//                           if (context.mounted) {
//                             Navigator.pop(context);
//                           }
//                         },
//                         label: 'Decline',
//                       ),
//                       _buildCallActionButton(
//                         icon: widget.call.isVideoCall ? Icons.videocam : Icons.call,
//                         backgroundColor: Colors.green,
//                         onPressed: () async {
//                           await callProvider.answerCall(widget.call);
//                           if (context.mounted) {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => OngoingCallScreen(
//                                   call: widget.call,
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         label: 'Accept',
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCallActionButton({
//     required IconData icon,
//     required Color backgroundColor,
//     required VoidCallback onPressed,
//     required String label,
//   }) {
//     return Column(
//       children: [
//         FloatingActionButton(
//           onPressed: onPressed,
//           backgroundColor: backgroundColor,
//           child: Icon(
//             icon,
//             color: Colors.white,
//             size: 30,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }
