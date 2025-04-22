import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/contact/contacts_page.dart';
import 'package:whatsapp_clone/features/group/pages/group_chat_room_page.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/models/group.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({
    super.key,
  });

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late final DBHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: _dbHelper.updateStream,
          builder: (context, snapshot) {
            return FutureBuilder<List<Group>>(
              future: _dbHelper.getGroupChats(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final groups = snapshot.data ?? [];

                if (groups.isEmpty) {
                  return const Center(child: Text('No chats available.'));
                }

                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return ListTile(
                      leading: CircleAvatar(
                        foregroundImage: group.IconUrl != null
                            ? CachedNetworkImageProvider(
                                group.IconUrl!,
                              )
                            : const AssetImage(
                                'assets/images/default_profile.jpg',
                              ),
                        child: InkWell(
                          onTap: () {
                            showGroupIcon(context, group);
                          },
                        ),
                      ),
                      title: Text(group.Title.toString()),
                      subtitle: group.LastMessage != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                group.LastMessage?.SenderId ==
                                        CurrentUser.userId
                                    ? group.LastMessage!.Status == 'sent'
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                          )
                                        : group.LastMessage!.Status == 'read'
                                            ? const Icon(
                                                Icons.done_all,
                                                color: Colors.red,
                                                size: 14,
                                              )
                                            : group.LastMessage!.Status ==
                                                    'delivered'
                                                ? const Icon(
                                                    Icons.done_all,
                                                    size: 14,
                                                  )
                                                : const Icon(
                                                    Icons.pending_outlined,
                                                    size: 14,
                                                  )
                                    : Text(
                                        group.LastSenderTitle!,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Flexible(
                                  child: Text(
                                    group.LastMessage != null
                                        ? group.LastMessage!.Content
                                        : '',
                                    style: const TextStyle(color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : null,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            height: 9,
                          ),
                          Text(
                            group.LastMessage != null
                                ? formatTimestamp(group.LastMessage!.Timestamp)
                                : '',
                            style: const TextStyle(color: Colors.green),
                          ),
                          if (group.UnreadCount != 0)
                            Container(
                              height: 23,
                              width: 23,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: Center(
                                child: Text(
                                  group.UnreadCount.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupChatRoomPage(
                              groupId: group.Id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green.shade500,
          ),
          child: const Icon(
            Icons.message,
            size: 30,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContactsPage(),
            ),
          );
        },
      ),
    );
  }

  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day); // Start of today
    final yesterdayStart =
        todayStart.subtract(const Duration(days: 1)); // Start of yesterday

    if (timestamp.isAfter(todayStart)) {
      // Format for today's messages (e.g., "11:34 AM")
      return DateFormat('hh:mm a').format(timestamp);
    } else if (timestamp.isAfter(yesterdayStart)) {
      // Format for yesterday's messages
      return 'Yesterday';
    } else {
      // Format for messages older than yesterday (e.g., "Monday", "January 10")
      return DateFormat('EEEE').format(timestamp); // Day of the week
    }
  }

  void showGroupIcon(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(group.Title),
          content: group.IconUrl != null
              ? CachedNetworkImage(
                  imageUrl: group.IconUrl!,
                )
              : Image.asset(
                  'assets/images/default_profile.jpg',
                ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.info_outline),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.message_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.videocam_outlined),
            ),
          ],
        );
      },
    );
  }
}
