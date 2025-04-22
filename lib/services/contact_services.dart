import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/secrets/secrets.dart';

class ContactServices extends ChangeNotifier {
  static Future<void> fetchAndSendContacts() async {
    // Check if the user has granted permission to access contacts
    if (await FlutterContacts.requestPermission(readonly: true)) {
      // Retrieve the contacts
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);

      // Extract phone numbers and prepare them for the backend
      List<String> phoneNumbers = [];
      Map<String, String> numberToNameMap = {};

      for (Contact contact in contacts) {
        for (Phone phone in contact.phones) {
          String num = phone.number.replaceAll(RegExp(r'\D'), '');
          int len = num.length;
          if (len >= 10) {
            String phoneWithoutCode = num.substring(len - 10, len);
            phoneNumbers.add(phoneWithoutCode);
            numberToNameMap[phoneWithoutCode] = contact.displayName;
          }
        }
      }

      // Send phone numbers to backend
      var url = Uri.parse(
          '${Secrets.serverUrl}/match-contacts'); // Replace with your backend URL
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contacts': phoneNumbers}),
      );

      phoneNumbers.clear();

      if (response.statusCode == 200) {
        print(response.body);
        final List<dynamic> matchedUsers =
            jsonDecode(response.body)['matched_users'];

        final List<Map<String, dynamic>> users = matchedUsers.map(
          (user) {
            Map<String, dynamic> userWithTitle = user as Map<String, dynamic>;
            userWithTitle.update(
              'title',
              (value) => 'Title',
              ifAbsent: () => numberToNameMap[user['phone']] ?? user['phone'],
            );
            return userWithTitle;
          },
        ).toList();

        final List<Map<String, dynamic>> contacts = matchedUsers
            .map(
              (user) => {
                "name": numberToNameMap[user['phone']],
                "user_id": user['_id'],
                "phone": user['phone'],
              },
            )
            .toList();

        DBHelper().insertUsers(users);
        DBHelper().insertContacts(contacts);
      } else {
        print('Error: ${response.body}');
      }
    } else {
      print('Contacts permission denied');
    }
  }
}
