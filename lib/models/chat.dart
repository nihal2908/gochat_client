// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/user.dart';

class Chat {
  String Id;
  String UserId;
  User ChatUser;
  int UnreadCount;
  Message? LastMessage;
  DateTime CreatedAt;
  DateTime UpdatedAt;
  int IsArchieved;
  Chat({
    required this.Id,
    required this.UserId,
    required this.UnreadCount,
    required this.ChatUser,
    required this.CreatedAt,
    required this.UpdatedAt,
    required this.IsArchieved,
    this.LastMessage,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': Id,
      'unread_count': UnreadCount,
      'user_id': UserId,
      'chat_user': ChatUser,
      'created_at': CreatedAt.toUtc().toIso8601String(),
      'updated_at': UpdatedAt.toUtc().toIso8601String(),
      'is_archieved': IsArchieved,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      Id: map['id'] as String,
      UserId: map['user_id'] as String,
      CreatedAt: map['created_at'].toString().isNotEmpty
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      UpdatedAt: map['updated_at'].toString().isNotEmpty
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      IsArchieved: map['is_archieved'] != null ? map['is_archieved'] as int : 0,
      UnreadCount: map['unread_count'] as int,
      ChatUser: User(
        Id: map['user_id'],
        Name: map['name'],
        Phone: map['phone'],
        Title: map['title'] != null ? map['title'] as String : map['phone'],
        CountryCode: map['country_code'],
        ProfilePictureUrl: map['profile_picture_url'],
        StatusMessage: map['status_message'],
        CreatedAt: map['created_at'].toString().isNotEmpty
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
        UpdatedAt: map['updated_at'].toString().isNotEmpty
            ? DateTime.parse(map['updated_at'] as String)
            : DateTime.now(),
        IsOnline: map['is_online'],
        LastSeen: map['last_seen'].toString().isNotEmpty
            ? DateTime.parse(map['last_seen'] as String)
            : DateTime.now(),
      ),
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

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);
}
