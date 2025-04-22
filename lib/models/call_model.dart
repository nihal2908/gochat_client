// import 'package:uuid/uuid.dart';
// import 'package:whatsapp_clone/models/user.dart';

// enum CallStatus {
//   idle,
//   ringing,
//   connecting,
//   connected,
//   ended,
//   declined,
//   busy,
//   timedOut,
// }

// class CallModel {
//   final String id;
//   final String callerId;
//   final User caller;
//   final String receiverId;
//   final User receiver;
//   final DateTime timestamp;
//   final bool isOutgoing;
//   final bool isVideoCall;
//   final bool isMissed;
//   final int? duration;
//   final CallStatus status;
//   final String? sessionId; // WebRTC session ID
//   final Map<String, dynamic>? rtcSessionData; // WebRTC session data

//   const CallModel({
//     required this.id,
//     required this.callerId,
//     required this.caller,
//     required this.receiver,
//     required this.receiverId,
//     required this.timestamp,
//     required this.isOutgoing,
//     required this.isVideoCall,
//     this.isMissed = false,
//     this.duration,
//     this.status = CallStatus.idle,
//     this.sessionId,
//     this.rtcSessionData,
//   });

//   factory CallModel.newCall({
//     required String callerId,
//     required String receiverId,
//     required bool isVideoCall,
//     required User caller,
//     required User receiver,
//   }) {
//     final uuid = const Uuid().v4();
//     return CallModel(
//       id: uuid,
//       callerId: callerId,
//       caller: caller,
//       receiverId: receiverId,
//       receiver: receiver,
//       timestamp: DateTime.now(),
//       isOutgoing: true,
//       isVideoCall: isVideoCall,
//       status: CallStatus.idle,
//     );
//   }

//   factory CallModel.fromJson(Map<String, dynamic> json) {
//     return CallModel(
//       id: json['id'] ?? const Uuid().v4(),
//       caller: User.fromMap(json),
//       receiver: User.fromMap(json),
//       callerId: json['caller_id'] ?? '',
//       receiverId: json['receiver_id'] ?? '',
//       timestamp: json['timestamp'] != null
//           ? DateTime.parse(json['timestamp'])
//           : DateTime.now(),
//       isOutgoing: json['is_outgoing'] ?? false,
//       isVideoCall: json['is_video_call'] ?? false,
//       isMissed: json['is_missed'] ?? false,
//       duration: json['duration'],
//       status: json['status'] != null
//           ? CallStatus.values[json['status']]
//           : CallStatus.idle,
//       sessionId: json['session_id'],
//       rtcSessionData: json['rtc_session_data'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'callerId': callerId,
//       'receiverId': receiverId,
//       'timestamp': timestamp.toIso8601String(),
//       'isOutgoing': isOutgoing,
//       'isVideoCall': isVideoCall,
//       'isMissed': isMissed,
//       'duration': duration,
//       'status': status.index,
//       'sessionId': sessionId,
//       'rtcSessionData': rtcSessionData,
//     };
//   }

//   CallModel copyWith({
//     String? id,
//     String? callerId,
//     String? receiverId,
//     DateTime? timestamp,
//     bool? isOutgoing,
//     bool? isVideoCall,
//     bool? isMissed,
//     int? duration,
//     CallStatus? status,
//     String? sessionId,
//     Map<String, dynamic>? rtcSessionData,
//     required User caller,
//     required User receiver,
//   }) {
//     return CallModel(
//       id: id ?? this.id,
//       callerId: callerId ?? this.callerId,
//       receiverId: receiverId ?? this.receiverId,
//       timestamp: timestamp ?? this.timestamp,
//       isOutgoing: isOutgoing ?? this.isOutgoing,
//       isVideoCall: isVideoCall ?? this.isVideoCall,
//       isMissed: isMissed ?? this.isMissed,
//       duration: duration ?? this.duration,
//       status: status ?? this.status,
//       sessionId: sessionId ?? this.sessionId,
//       rtcSessionData: rtcSessionData ?? this.rtcSessionData,
//     );
//   }

//   String get getDisplayName => isOutgoing ? receiverName : callerName;
//   String? get getDisplayAvatar => isOutgoing ? receiverAvatar : callerAvatar;
//   String get getStatusText {
//     switch (status) {
//       case CallStatus.ringing:
//         return 'Ringing...';
//       case CallStatus.connecting:
//         return 'Connecting...';
//       case CallStatus.connected:
//         return 'Connected';
//       case CallStatus.ended:
//         return 'Call ended';
//       case CallStatus.declined:
//         return 'Call declined';
//       case CallStatus.busy:
//         return 'Busy';
//       case CallStatus.timedOut:
//         return 'Call not answered';
//       default:
//         return '';
//     }
//   }
// }
