// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:whatsapp_clone/models/contact.dart';

class SendingContact {
  final String Id;
  final String Name;
  final String Phone;
  SendingContact({
    required this.Id,
    required this.Name,
    required this.Phone,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': Id,
      'name': Name,
      'phone': Phone,
    };
  }

  factory SendingContact.fromMap(Map<String, dynamic> map) {
    return SendingContact(
      Id: map['id'] as String,
      Name: map['name'] as String,
      Phone: map['phone'] as String,
    );
  }

  factory SendingContact.fromContact(Contact contact) {
    return SendingContact(
      Id: contact.UserId,
      Name: contact.ContactUser.Title,
      Phone: contact.Phone,
    );
  }

  String toJson() => json.encode(toMap());

  factory SendingContact.fromJson(String source) =>
      SendingContact.fromMap(json.decode(source) as Map<String, dynamic>);
}
