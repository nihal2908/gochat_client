// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:whatsapp_clone/models/user.dart';

class Contact {
  String UserId;
  String Name;
  String Phone;
  User ContactUser;
  Contact({
    required this.UserId,
    required this.Name,
    required this.Phone,
    required this.ContactUser,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': UserId,
      'name': Name,
      'phone': Phone,
      'user': ContactUser,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      UserId: map['user_id'] as String,
      Name: map['name'] as String,
      Phone: map['phone'] as String,
      ContactUser: User(
        Id: map['_id'],
        Name: map['name'],
        Phone: map['phone'],
        Title: map['title'],
        CountryCode: map['country_code'],
        ProfilePictureUrl: map['profile_picture_url'],
        StatusMessage: map['status_message'],
        IsOnline: map['is_online'] as int,
        LastSeen: map['last_seen'] != ""
            ? DateTime.parse(map['last_seen'] as String)
            : null,
        CreatedAt: DateTime.parse(map['created_at'] as String),
        UpdatedAt: map['updated_at'] != ""
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Contact.fromJson(String source) =>
      Contact.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact && other.UserId == UserId);

  @override
  int get hashCode => UserId.hashCode;
}
