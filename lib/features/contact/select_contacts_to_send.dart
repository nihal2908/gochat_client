import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
// import 'package:whatsapp_clone/features/group/pages/new_group_details.dart';
import 'package:whatsapp_clone/models/contact.dart';
// import 'package:whatsapp_clone/models/sending_contact.dart';
import 'package:whatsapp_clone/utils/utils.dart';

class SelectContactsToSend extends StatefulWidget {
  const SelectContactsToSend({super.key});

  @override
  State<SelectContactsToSend> createState() => _SelectContactsToSendState();
}

class _SelectContactsToSendState extends State<SelectContactsToSend> {
  bool search = false;
  TextInputType keyBoardType = TextInputType.text;
  final List<Contact> selectedContacts = [];
  late final DBHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = DBHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: search
          ? AppBar(
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              title: TextField(
                key: ValueKey(keyBoardType),
                keyboardType: keyBoardType,
                autofocus: true,
                decoration: InputDecoration(
                  prefix: IconButton(
                    onPressed: () {
                      setState(() {
                        search = false;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  suffix: IconButton(
                    onPressed: () {
                      setState(() {
                        keyBoardType = keyBoardType == TextInputType.text
                            ? TextInputType.number
                            : TextInputType.text;
                      });
                    },
                    icon: keyBoardType == TextInputType.text
                        ? const Icon(Icons.dialpad)
                        : const Icon(Icons.keyboard),
                  ),
                ),
              ),
            )
          : AppBar(
              title: ListTile(
                title: const Text('Contacts to send'),
                subtitle: Text("${selectedContacts.length} selected"),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      search = true;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
      body: Column(
        children: [
          if (selectedContacts.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                itemCount: selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = selectedContacts[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 70,
                        height: 70,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              child: Text(contact.ContactUser.Title[0]),
                            ),
                            Text(
                              contact.ContactUser.Title,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        height: 0,
                        child: IconButton(
                          style: const ButtonStyle(
                              iconSize: WidgetStatePropertyAll(15)),
                          onPressed: () {
                            setState(() {
                              selectedContacts.removeAt(index);
                            });
                          },
                          color: Colors.grey,
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  );
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Contact>>(
              future: _dbHelper.getContacts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final contacts = snapshot.data ?? [];
                if (contacts.isEmpty) {
                  return const Center(child: Text('No contacts to show.'));
                }

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final bool selected = selectedContacts.contains(contact);
                    return ListTile(
                      leading: CircleAvatar(
                        child: selected
                            ? const Icon(Icons.check)
                            : Text(
                                contact.ContactUser.Title.toString()[0],
                              ),
                      ),
                      title: Text(contact.ContactUser.Title.toString()),
                      subtitle: Text(
                        contact.ContactUser.StatusMessage.toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        setState(() {
                          selected
                              ? selectedContacts.remove(contact)
                              : selectedContacts.add(contact);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedContacts.isNotEmpty) {
            Navigator.pop(context, selectedContacts);
          } else {
            showTextSnackBar(
              context: context,
              text: 'Atleast 1 contact must be selected.',
            );
          }
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
