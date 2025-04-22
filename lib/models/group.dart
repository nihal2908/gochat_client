// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:whatsapp_clone/models/message.dart';

class Group {
  String Id;
  String? IconUrl;
  String Title;
  int UnreadCount;
  Message? LastMessage;
  String? LastSenderTitle;

  Group({
    required this.Id,
    this.IconUrl,
    required this.Title,
    required this.UnreadCount,
    this.LastMessage,
    this.LastSenderTitle,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': Id,
      'group_icon': IconUrl,
      'title': Title,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      Id: map['id'] as String,
      IconUrl: map['group_icon'] != null ? map['group_icon'] as String : null,
      Title: map['title'] as String,
      UnreadCount: int.parse(map['unread_count'] ?? '0'),
      LastMessage: map['_id'] != null ? Message.fromMap(map) : null,
      LastSenderTitle: map['last_sender_title'] != null
          ? map['last_sender_title'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Group.fromJson(String source) =>
      Group.fromMap(json.decode(source) as Map<String, dynamic>);
}
