import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/view_shared_contacts.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/sending_contact.dart';

class ContactMessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ContactMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    List<dynamic> jsons = jsonDecode(message.Content);
    List<SendingContact> sharedContacts = jsons.map((json) {
      return SendingContact.fromJson(json);
    }).toList();

    int count = sharedContacts.length;

    return Container(
      child: Column(
        children: [
          Text(count == 1 ? 'Contact' : 'Contacts'),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CircleAvatar(
                child: Text(sharedContacts.first.Name[0].toUpperCase()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewSharedContactsPage(
                        contacts: sharedContacts,
                      ),
                    ),
                  );
                },
                child: count == 1
                    ? Text(sharedContacts.first.Name)
                    : Text(
                        "${sharedContacts.first.Name} and ${count - 1} more"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
