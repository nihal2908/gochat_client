// import 'package:flutter/material.dart';
// import '../screens/call_screens/outgoing_call_screen.dart';
// import '../screens/call_screens/incoming_call_screen.dart';
// import '../../../models/call_model.dart';

// class CallsScreen extends StatelessWidget {
//   const CallsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // This is just a routing screen that checks call data passed from routes
//     final args = ModalRoute.of(context)?.settings.arguments;

//     if (args is Map<String, dynamic>) {
//       // Handle creating a call from arguments
//       return OutgoingCallScreen(
//         callerId: args['callerId'] ?? '',
//         callerName: args['callerName'] ?? '',
//         callerAvatar: args['callerAvatar'],
//         receiverId: args['receiverId'] ?? '',
//         receiverName: args['receiverName'] ?? '',
//         receiverAvatar: args['receiverAvatar'],
//         isVideoCall: args['isVideoCall'] ?? false,
//       );
//     } else if (args is CallModel) {
//       // Handle incoming call
//       return IncomingCallScreen(call: args);
//     } else {
//       // Error state or no arguments
//       return Scaffold(
//         appBar: AppBar(title: const Text('Call Error')),
//         body: const Center(
//           child: Text('Invalid call data. Please try again.'),
//         ),
//       );
//     }
//   }
// }
