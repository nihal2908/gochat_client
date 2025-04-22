// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:whatsapp_clone/models/user.dart';

class Call {
  String Id;
  User Caller;
  String ReceiverId;
  String CallType;
  int Incoming;
  DateTime StartTime;
  DateTime? EndTime;
  String Status;
  Call({
    required this.Id,
    required this.Caller,
    required this.ReceiverId,
    required this.CallType,
    required this.Incoming,
    required this.StartTime,
    this.EndTime,
    required this.Status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': Id,
      'caller': Caller,
      'receiver_id': ReceiverId,
      'call_type': CallType,
      'incoming': Incoming,
      'start_time': StartTime.toUtc().toIso8601String(),
      'end_time': EndTime?.toUtc().toIso8601String(),
      'status': Status,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      Id: map['id'] as String,
      Caller: User.fromMap(map['caller'] as Map<String, dynamic>),
      ReceiverId: map['receiver_id'] as String,
      CallType: map['call_type'] as String,
      Incoming: map['incoming'] as int,
      StartTime: DateTime.parse(map['start_time'] as String),
      EndTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      Status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Call.fromJson(String source) =>
      Call.fromMap(json.decode(source) as Map<String, dynamic>);
}
