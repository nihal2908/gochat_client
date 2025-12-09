// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:whatsapp_clone/models/message.dart';

class Chat {
  String Id;
  String UserId;
  String Title;
  String? ProfilePictureUrl;
  int UnreadCount;
  Message? LastMessage;
  Chat({
    required this.Id,
    required this.UserId,
    required this.Title,
    required this.UnreadCount,
    this.ProfilePictureUrl,
    this.LastMessage,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      Id: map['id'] as String,
      UserId: map['user_id'] as String,
      UnreadCount: map['unread_count'] as int,
      Title: map['title'] as String,
      ProfilePictureUrl:
          map['profile_picture_url'] != null ? map['profile_picture_url'] as String : null,
      LastMessage: map['sender_id'] != null
          ? Message(
              Id: map['_id'],
              Content: map['content'],
              DeletedForEveryone: map['deleted_for_everyone'],
              Edited: map['edited'] != null ? map['edited'] as int : 0,
              SenderId: map['sender_id'] as String,
              ReceiverId: map['receiver_id'] as String?,
              Status: map['status'] as String,
              Timestamp: DateTime.parse(map['timestamp'] as String),
              Type: map['type'] as String,
              ChatId: map['chat_id'] as String?,
              GroupId: map['group_id'] as String?,
            )
          : null,
    );
  }

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);
}
