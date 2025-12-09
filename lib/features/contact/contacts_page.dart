import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/chat/presentation/pages/chat_room_page.dart';
import 'package:whatsapp_clone/models/contact.dart';
import 'package:whatsapp_clone/providers/contact_provider.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({
    super.key,
  });

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late DBHelper _dbHelper;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
    refreshing = true;
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    // if (refreshing) return;
    refreshing = true;
    Provider.of<ContactProvider>(context, listen: false).refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, contactProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Contacts'),
            actions: [
              IconButton(
                onPressed: () {
                  fetchContacts();
                },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          body: FutureBuilder<List<Contact>>(
            future: _dbHelper.getContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final contacts = snapshot.data ?? [];

              if (contacts.isEmpty) {
                return const Center(child: Text('No contacts available.'));
              }

              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        contact.ContactUser.Title.toString()[0],
                      ),
                    ),
                    title: Text(contact.ContactUser.Title.toString()),
                    subtitle: Text(
                      contact.ContactUser.StatusMessage.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final List<String> ids = [
                        contact.UserId,
                        CurrentUser.userId!
                      ]..sort();
                      final chatId = ids.join('_');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            chatId: chatId,
                            userId: contact.UserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
