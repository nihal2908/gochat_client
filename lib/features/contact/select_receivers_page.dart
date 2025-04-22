import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/models/contact.dart';
import 'package:whatsapp_clone/models/sending_contact.dart';
import 'package:whatsapp_clone/models/user.dart';

class SelectReceivers extends StatefulWidget {
  final List<User> selectedContacts;
  const SelectReceivers({super.key, required this.selectedContacts});

  @override
  State<SelectReceivers> createState() => _SelectReceiversState();
}

class _SelectReceiversState extends State<SelectReceivers> {
  bool search = false;
  TextInputType keyBoardType = TextInputType.text;
  final List<User> selectedContacts = [];
  late final DBHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = DBHelper();
    selectedContacts.addAll(widget.selectedContacts);
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
                title: const Text('New Group'),
                subtitle: selectedContacts.isEmpty
                    ? const Text('Add members')
                    : Text("${selectedContacts.length} contacts selected"),
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
                  return InkWell(
                    onTap: () => setState(() {
                      selectedContacts.removeAt(index);
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 70,
                      height: 70,
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                child: Text(contact.Name[0]),
                              ),
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                            ],
                          ),
                          Text(
                            contact.Name,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
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
                              : selectedContacts.add(contact.ContactUser);
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
          Navigator.pop(context, selectedContacts);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
