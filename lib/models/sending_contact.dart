// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

class SendingContact {
  final String Id;
  final String Name;
  final String Phone;
  final String CountryCode;
  SendingContact({
    required this.Id,
    required this.Name,
    required this.Phone,
    required this.CountryCode,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': Id,
      'name': Name,
      'phone': Phone,
      'country_code': CountryCode,
    };
  }

  factory SendingContact.fromMap(Map<String, dynamic> map) {
    return SendingContact(
      Id: map['id'] as String,
      Name: map['name'] as String,
      Phone: map['phone'] as String,
      CountryCode: map['country_code'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SendingContact.fromJson(String source) => SendingContact.fromMap(json.decode(source) as Map<String, dynamic>);
}
