import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

class Media {
  final String Id;
  final String MessageId;
  final String Url;
  final String Path;
  final double Size;
  final String Type;
  final DateTime CreatedAt;
  Media({
    required this.Id,
    required this.MessageId,
    required this.Url,
    required this.Path,
    required this.Type,
    required this.Size,
    required this.CreatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': Id,
      'message_id': MessageId,
      'url': Url,
      'path': Path,
      'size': Size,
      'type': Type,
      'created_at': CreatedAt.toIso8601String(),
    };
  }

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      Id: map['id'] as String,
      MessageId: map['message_id'] as String,
      Url: map['url'] as String,
      Path: map['path'] as String,
      Size: map['size'] as double,
      Type: map['type'] as String,
      CreatedAt: DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Media.fromJson(String source) =>
      Media.fromMap(json.decode(source) as Map<String, dynamic>);
}
