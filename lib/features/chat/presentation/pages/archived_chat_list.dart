import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/chat/presentation/pages/chat_room_page.dart';
import 'package:whatsapp_clone/models/chat.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/statics/static_widgets.dart';
import 'package:whatsapp_clone/utils/utils.dart';

class ArchivedChatList extends StatefulWidget {
  final DBHelper dbHelper;
  const ArchivedChatList({super.key, required this.dbHelper});

  @override
  State<ArchivedChatList> createState() => _ArchivedChatListState();
}

class _ArchivedChatListState extends State<ArchivedChatList> {
  late final DBHelper _dbHelper;
  final Set<String> _selectedChatIds = {};
  bool get isSelectionMode => _selectedChatIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
  }

  void toggleSelection(Chat chat) {
    setState(() {
      if (_selectedChatIds.contains(chat.Id)) {
        _selectedChatIds.remove(chat.Id);
      } else {
        _selectedChatIds.add(chat.Id);
      }
    });
  }

  void clearSelection() {
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _deleteChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chats'),
        content:
            const Text('Are you sure you want to delete the selected chats?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbHelper.deleteChat(_selectedChatIds.toList());
              clearSelection();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool isChatSelected(Chat chat) => _selectedChatIds.contains(chat.Id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text('${_selectedChatIds.length} selected')
            : const Text('Archived Chats'),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 23,
        ),
        centerTitle: true,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: clearSelection,
              )
            : null,
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteChat,
                ),
                IconButton(
                  icon: const Icon(Icons.unarchive),
                  onPressed: () async {
                    await _dbHelper.unarchiveChats(_selectedChatIds.toList());
                    clearSelection();
                  },
                ),
              ]
            : [],
      ),
      body: StreamBuilder(
        stream: _dbHelper.updateStream,
        builder: (context, snapshot) {
          return FutureBuilder<List<Chat>>(
            future: _dbHelper.getChats(archived: true),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final chats = snapshot.data ?? [];

              if (chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('No chats found!'),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(text: 'Tap '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(Icons.message,
                                  size: 18, color: Colors.blue),
                            ),
                            TextSpan(text: ' to start a new conversation.'),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }

              return chatList(chats: chats);
            },
          );
        },
      ),
    );
  }

  Widget chatList({required List<Chat> chats}) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final selected = isChatSelected(chat);

        return chatListItem(chat: chat, selected: selected);
      },
    );
  }

  Widget chatListItem({required Chat chat, required bool selected}) {
    Message? lastMessage = chat.LastMessage;

    return GestureDetector(
      onLongPress: () => toggleSelection(chat),
      onTap: () {
        if (isSelectionMode) {
          toggleSelection(chat);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                chatId: chat.Id,
                userId: chat.UserId,
              ),
            ),
          );
        }
      },
      child: Container(
        color: selected ? Colors.green.withOpacity(0.2) : null,
        child: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 25,
                foregroundImage: chat.ChatUser.ProfilePictureUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(
                        chat.ChatUser.ProfilePictureUrl!,
                      )
                    : const AssetImage(Statics.defaultProfileImage)
                        as ImageProvider,
              ),
              if (selected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            chat.ChatUser.Title.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: lastMessage != null
              ? Row(
                  children: [
                    if (lastMessage.SenderId == CurrentUser.userId)
                      Statics.statusIcon[lastMessage.Status]!,
                    const SizedBox(width: 3),
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
                    const SizedBox(height: 9),
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
        ),
      ),
    );
  }
}
