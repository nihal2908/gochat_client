// import 'package:flutter/material.dart';
// import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
// import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
// import 'package:whatsapp_clone/providers/websocket_provider.dart';
// import '../widgets/call_list_item.dart';
// import '../../../models/call_model.dart';
// import '../providers/call_provider.dart';
// import '../screens/call_screens/outgoing_call_screen.dart';
// import 'package:provider/provider.dart';

// class CallsListScreen extends StatefulWidget {
//   const CallsListScreen({super.key});

//   @override
//   State<CallsListScreen> createState() => _CallsListScreenState();
// }

// class _CallsListScreenState extends State<CallsListScreen> {
//   late final WebSocketService _webSocketService;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the call provider if needed
//     _webSocketService = Provider.of<WebSocketProvider>(context, listen: false).webSocketService;
//     Future.microtask(() {
//       final provider = Provider.of<CallProvider>(context, listen: false);
//       // In a real app, we would initialize with the current user's ID
//       provider.initialize(_webSocketService);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final callProvider = Provider.of<CallProvider>(context);
//     final recentCalls = callProvider.recentCalls;

//     // If there's no recent calls, use mock data for demonstration
//     final calls = recentCalls.isEmpty ? _getMockCalls() : recentCalls;

//     return Scaffold(
//       body: Column(
//         children: [
//           // "Add favorite" button section
//           ListTile(
//             leading: Container(
//               width: 50,
//               height: 50,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF25D366),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.favorite,
//                 color: Colors.white,
//               ),
//             ),
//             title: const Text(
//               'Add favorite',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             onTap: () {
//               // Navigate to contacts screen to pick favorites
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) => ContactListScreen(
//               //       isSelectingFavorite: true,
//               //       onContactSelected: (contact) {
//               //         // Handle favorite contact selection
//               //         Navigator.pop(context);
//               //       },
//               //     ),
//               //   ),
//               // );
//             },
//           ),

//           const Divider(height: 1),

//           // "Recent" header
//           const Padding(
//             padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Recent',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//           ),

//           // Calls list
//           Expanded(
//             child: calls.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'No recent calls',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: calls.length,
//                     itemBuilder: (context, index) {
//                       final call = calls[index];
//                       return CallListItem(
//                         call: call,
//                         onTap: () {
//                           _showCallOptions(context, call);
//                         },
//                       );
//                     },
//                   ),
//           ),

//           // End-to-end encryption text
//           const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.lock, size: 12, color: Colors.grey),
//                 SizedBox(width: 4),
//                 Text(
//                   'Your personal calls are end-to-end encrypted',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCallOptions(BuildContext context, CallModel call) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.call),
//                 title: const Text('Voice call'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _startCall(context, call, false);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.videocam),
//                 title: const Text('Video call'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _startCall(context, call, true);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.info_outline),
//                 title: const Text('Call info'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Show call info dialog
//                   _showCallInfoDialog(context, call);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _startCall(BuildContext context, CallModel call, bool isVideoCall) {
//     // Initialize a new outgoing call
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OutgoingCallScreen(
//           callerId: 'current_user_id',
//           callerName: 'Current User', // Replace with actual user name
//           receiverId: call.isOutgoing ? call.receiverId : call.callerId,
//           receiverName: call.getDisplayName,
//           receiverAvatar: call.getDisplayAvatar,
//           isVideoCall: isVideoCall,
//         ),
//       ),
//     );
//   }

//   void _showCallInfoDialog(BuildContext context, CallModel call) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Call with ${call.getDisplayName}'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Date: ${_formatDate(call.timestamp)}'),
//               const SizedBox(height: 8),
//               Text('Time: ${_formatTime(call.timestamp)}'),
//               const SizedBox(height: 8),
//               Text(
//                   'Duration: ${call.duration != null ? _formatDuration(call.duration!) : 'N/A'}'),
//               const SizedBox(height: 8),
//               Text('Type: ${call.isVideoCall ? 'Video call' : 'Voice call'}'),
//               const SizedBox(height: 8),
//               Text('Status: ${call.isMissed ? 'Missed' : 'Completed'}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime dateTime) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(now.year, now.month, now.day - 1);
//     final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

//     if (date == today) {
//       return 'Today';
//     } else if (date == yesterday) {
//       return 'Yesterday';
//     } else {
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//     }
//   }

//   String _formatTime(DateTime dateTime) {
//     final hour = dateTime.hour.toString().padLeft(2, '0');
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }

//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remainingSeconds = seconds % 60;
//     return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   // Mock data for the calls screen
//   List<CallModel> _getMockCalls() {
//     return [
//       // CallModel(
//       //   id: '1',
//       //   callerId: 'user_1',
//       //   callerName: 'Nitin',
//       //   receiverId: 'current_user_id',
//       //   receiverName: 'Current User',
//       //   timestamp: DateTime.now().subtract(const Duration(days: 2)),
//       //   isOutgoing: true,
//       //   isVideoCall: true,
//       //   isMissed: false,
//       //   callerAvatar: null,
//       // ),
//       // CallModel(
//       //   id: '2',
//       //   callerId: 'user_1',
//       //   callerName: 'Nitin',
//       //   receiverId: 'current_user_id',
//       //   receiverName: 'Current User',
//       //   timestamp: DateTime.now().subtract(const Duration(days: 2)),
//       //   isOutgoing: false,
//       //   isVideoCall: true,
//       //   isMissed: true,
//       //   callerAvatar: null,
//       // ),
//       // CallModel(
//       //   id: '3',
//       //   callerId: 'current_user_id',
//       //   callerName: 'Current User',
//       //   receiverId: 'user_1',
//       //   receiverName: 'Nitin',
//       //   timestamp: DateTime.now().subtract(const Duration(days: 2)),
//       //   isOutgoing: true,
//       //   isVideoCall: true,
//       //   isMissed: false,
//       //   receiverAvatar: null,
//       // ),
//       // CallModel(
//       //   id: '4',
//       //   callerId: 'user_2',
//       //   callerName: 'Nishan CSE C MNNIT',
//       //   receiverId: 'current_user_id',
//       //   receiverName: 'Current User',
//       //   timestamp: DateTime.now().subtract(const Duration(days: 8)),
//       //   isOutgoing: false,
//       //   isVideoCall: false,
//       //   isMissed: false,
//       // ),
//       // CallModel(
//       //   id: '5',
//       //   callerId: 'user_2',
//       //   callerName: 'Nishan CSE C MNNIT',
//       //   receiverId: 'current_user_id',
//       //   receiverName: 'Current User',
//       //   timestamp: DateTime.now().subtract(const Duration(days: 8)),
//       //   isOutgoing: false,
//       //   isVideoCall: false,
//       //   isMissed: true,
//       // ),
//       // CallModel(
//       //   id: '6',
//       //   callerId: 'current_user_id',
//       //   callerName: 'Current User',
//       //   receiverId: 'user_2',
//       //   receiverName: 'Nishan CSE C MNNIT',
//       //   timestamp: DateTime.now().subtract(const Duration(days: 8)),
//       //   isOutgoing: true,
//       //   isVideoCall: false,
//       //   isMissed: false,
//       // ),
//     ];
//   }
// }
