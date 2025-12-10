import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_clone/models/sending_contact.dart';

class ViewSharedContactsPage extends StatelessWidget {
  final List<SendingContact> contacts;

  const ViewSharedContactsPage({
    Key? key,
    required this.contacts,
  }) : super(key: key);

  String _avatarLetter(String name) {
    if (name.trim().isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }

  void _copyNumber(BuildContext context, String number) async {
    await Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Number copied to clipboard'),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View contacts'),
      ),
      body: contacts.isEmpty
          ? const Center(
              child: Text('No contacts shared.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = contacts[index];
                final letter = _avatarLetter(c.Name);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.Name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Number with long-press to copy
                              GestureDetector(
                                onLongPress: () => _copyNumber(context, c.Phone),
                                child: Text(
                                  c.Phone,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // optional icon to hint copy action
                        IconButton(
                          onPressed: () => _copyNumber(context, c.Phone),
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy number',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
