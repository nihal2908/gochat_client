import 'dart:convert';

// ignore_for_file: non_constant_identifier_names

class Message implements Comparable<Message> {
  String Id;
  String SenderId;
  String? ReceiverId;
  String? ChatId;
  String? GroupId;
  String Content;
  String? Caption;
  double? Size;
  String Type;
  String Status;
  int DeletedForEveryone;
  int Edited;
  DateTime Timestamp;
  DateTime? ServerTS;
  Message({
    required this.Id,
    required this.SenderId,
    this.ReceiverId,
    this.ChatId,
    this.GroupId,
    required this.Content,
    this.Caption,
    this.Size,
    required this.Type,
    required this.Status,
    required this.DeletedForEveryone,
    required this.Edited,
    required this.Timestamp,
    this.ServerTS,
  });

  @override
  int compareTo(Message other) {
    return Id.compareTo(other.Id);
  }

  // Override equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) || // If they are the same instance
      (other is Message && runtimeType == other.runtimeType && Id == other.Id);

  // Override hashCode
  @override
  int get hashCode => Id.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': Id,
      'sender_id': SenderId,
      'receiver_id': ReceiverId,
      'chat_id': ChatId,
      'group_id': GroupId,
      'content': Content,
      'caption': Caption,
      'size': Size,
      'type': Type,
      'status': Status,
      'deleted_for_everyone': DeletedForEveryone,
      'edited': Edited,
      'timestamp': Timestamp.toIso8601String(),
      'server_ts': ServerTS?.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      Id: map['_id'] as String,
      SenderId: map['sender_id'] as String,
      ReceiverId:
          map['receiver_id'] != null ? map['receiver_id'] as String : null,
      ChatId: map['chat_id'] != null ? map['chat_id'] as String : null,
      GroupId: map['group_id'] != null ? map['group_id'] as String : null,
      Content: map['content'] as String,
      Caption: map['caption'] != null ? map['caption'] as String : null,
      Size: map['size'] != null ? map['size'] as double : null,
      Type: map['type'] as String,
      Status: map['status'] as String,
      DeletedForEveryone: map['deleted_for_everyone'] as int,
      Edited: map['edited'] != null ? map['edited'] as int : 0,
      Timestamp: DateTime.parse(map['timestamp']),
      ServerTS: map['server_ts'] != null ? DateTime.parse(map['server_ts']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
