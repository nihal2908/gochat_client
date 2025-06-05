import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/chat/presentation/pages/chat_room_page.dart';
import 'package:whatsapp_clone/features/contact/contacts_page.dart';
import 'package:whatsapp_clone/models/chat.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/statics/static_widgets.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
  });

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
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
            return FutureBuilder<List<Chat>>(
              future: _dbHelper.getChats(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return const Center(child: Text('No chats available.'));
                }

                return chatList(chats: chats);
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

  void showProfileImage(BuildContext context, Chat chat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(chat.ChatUser.Title),
          content: chat.ChatUser.ProfilePictureUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: chat.ChatUser.ProfilePictureUrl!,
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

  Widget chatList({required List<Chat> chats}) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return chatListItem(chat: chat);
      },
    );
  }

  Widget chatListItem({required Chat chat}) {
    Message? lastMessage = chat.LastMessage;
    return ListTile(
      leading: CircleAvatar(
        foregroundImage: chat.ChatUser.ProfilePictureUrl!.isNotEmpty
            ? CachedNetworkImageProvider(
                chat.ChatUser.ProfilePictureUrl!,
              )
            : const AssetImage(
                Statics.defaultProfileImage,
              ),
        child: InkWell(
          onTap: () {
            showProfileImage(context, chat);
          },
        ),
      ),
      title: Text(
        chat.ChatUser.Title.toString(),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: lastMessage != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (lastMessage.SenderId == CurrentUser.userId)
                  Statics.statusIcon[lastMessage.Status]!,
                const SizedBox(
                  width: 3,
                ),
                Flexible(
                  child: lastMessage.Type == 'text'
                      ? Text(
                          lastMessage.Content,
                          style: TextStyle(color: Colors.grey.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Row(
                          children: [
                            Statics.messageTypeIcon[lastMessage.Type]!,
                            const SizedBox(width: 5),
                            Text(
                              lastMessage.Caption ?? '',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                ),
              ],
            )
          : null,
      trailing: lastMessage != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  height: 9,
                ),
                Text(
                  formatTimestamp(lastMessage.Timestamp),
                  style: const TextStyle(color: Colors.green),
                ),
                if (chat.UnreadCount != 0)
                  Container(
                    height: 23,
                    width: 23,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Center(
                      child: Text(
                        chat.UnreadCount.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
              ],
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              chatId: chat.Id,
              userId: chat.UserId,
            ),
          ),
        );
      },
      // onLongPress: () {},
    );
  }
}
