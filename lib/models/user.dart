// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class User {
  final String Id;
  final String Title;
  final String Name;
  final String Phone;
  final String CountryCode;
  final String? ProfilePictureUrl;
  final String StatusMessage;
  final int IsOnline;
  final DateTime? LastSeen;
  final DateTime? CreatedAt;
  final DateTime? UpdatedAt;
  User({
    required this.Id,
    required this.Name,
    required this.Phone,
    required this.Title,
    required this.CountryCode,
    this.ProfilePictureUrl,
    required this.StatusMessage,
    required this.IsOnline,
    this.LastSeen,
    required this.CreatedAt,
    this.UpdatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': Id,
      'name': Name,
      'phone': Phone,
      'title': Title,
      'country_code': CountryCode,
      'profile_picture_url': ProfilePictureUrl,
      'status_message': StatusMessage,
      'is_online': IsOnline,
      'last_seen': LastSeen?.toUtc().toIso8601String(),
      'created_at': CreatedAt?.toUtc().toIso8601String(),
      'updated_at': UpdatedAt?.toUtc().toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      Id: map['_id'] as String,
      Name: map['name'] as String,
      Phone: map['phone'] as String,
      Title: map['title'] != null
          ? map['title'] as String
          : map['phone'] as String,
      CountryCode: map['country_code'] as String,
      ProfilePictureUrl: map['profile_picture_url'] != null
          ? map['profile_picture_url'] as String
          : null,
      StatusMessage: map['status_message'] as String,
      IsOnline: map['is_online'] as int,
      LastSeen:
          map['last_seen'] != null && map['last_seen'].toString().isNotEmpty
              ? DateTime.parse(map['last_seen'] as String)
              : null,
      CreatedAt:
          map['created_at'] != null && map['created_at'].toString().isNotEmpty
              ? DateTime.parse(map['created_at'] as String)
              : null,
      UpdatedAt:
          map['updated_at'] != null && map['updated_at'].toString().isNotEmpty
              ? DateTime.parse(map['updated_at'] as String)
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
