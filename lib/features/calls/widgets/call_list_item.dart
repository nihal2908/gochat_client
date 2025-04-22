// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../models/call_model.dart';
// import '../screens/call_screens/outgoing_call_screen.dart';

// class CallListItem extends StatelessWidget {
//   final CallModel call;
//   final VoidCallback onTap;

//   const CallListItem({
//     super.key,
//     required this.call,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final displayName = call.getDisplayName;
//     final displayAvatar = call.getDisplayAvatar;

//     return ListTile(
//       leading: CircleAvatar(
//         radius: 24,
//         backgroundColor: Colors.grey.shade200,
//         backgroundImage: displayAvatar != null
//             ? NetworkImage(displayAvatar)
//             : null,
//         child: displayAvatar == null
//             ? const Icon(Icons.person, color: Colors.grey)
//             : null,
//       ),
//       title: Text(displayName),
//       subtitle: Row(
//         children: [
//           Icon(
//             call.isOutgoing
//                 ? call.isMissed ? Icons.call_missed_outgoing : Icons.call_made
//                 : call.isMissed ? Icons.call_missed : Icons.call_received,
//             size: 16,
//             color: call.isMissed ? Colors.red : const Color(0xFF25D366),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             _formatDate(call.timestamp),
//             style: TextStyle(
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//       trailing: IconButton(
//         icon: Icon(
//           call.isVideoCall ? Icons.videocam : Icons.call,
//           color: const Color(0xFF075E54),
//         ),
//         onPressed: () {
//           // Start a new call of the same type
//           _startNewCall(context, call.isVideoCall);
//         },
//       ),
//       onTap: onTap,
//     );
//   }

//   void _startNewCall(BuildContext context, bool isVideoCall) {
//     // Start a new call with the same contact
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => OutgoingCallScreen(
//           callerId: 'current_user_id',
//           callerName: 'Current User', // Should be the actual user name
//           receiverId: call.isOutgoing ? call.receiverId : call.callerId,
//           receiverName: call.getDisplayName,
//           receiverAvatar: call.getDisplayAvatar,
//           isVideoCall: isVideoCall,
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final callDate = DateTime(date.year, date.month, date.day);

//     if (callDate == today) {
//       return DateFormat('HH:mm').format(date);
//     } else if (callDate == yesterday) {
//       return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
//     } else {
//       return DateFormat('MMM d, HH:mm').format(date);
//     }
//   }
// }
