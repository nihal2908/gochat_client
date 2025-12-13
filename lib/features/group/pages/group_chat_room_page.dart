import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/message_bubble.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/message_input.dart';
import 'package:whatsapp_clone/features/chat/provider/chat_provider.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/providers/websocket_provider.dart';

class GroupChatRoomPage extends StatefulWidget {
  final String groupId;

  const GroupChatRoomPage({
    super.key,
    required this.groupId,
  });

  @override
  _GroupChatRoomPageState createState() => _GroupChatRoomPageState();
}

class _GroupChatRoomPageState extends State<GroupChatRoomPage> {
  bool isTyping = false;
  late final DBHelper _dbHelper;
  late final ChatState chatState;
  late final WebSocketService _webSocketService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ValueNotifier<bool> showEmojiPicker = ValueNotifier(false);
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _webSocketService =
        Provider.of<WebSocketProvider>(context, listen: false).webSocketService;
    _dbHelper = DBHelper();
    // chatState = Provider.of<ChatState>(context, listen: false);
    // chatState.openChat(widget.chatId);
    // _markAllMessagesAsRead();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
  }

  // void _markAllMessagesAsRead() {
  //   _webSocketService.sendReadAcknowledement(
  //     chatId: widget.groupId,
  //     receiverId: CurrentUser.userId!,
  //   );
  // }

  void _sendMessage(String content) {
    final message = {
      '_id': const Uuid().v4(),
      'sender_id': CurrentUser.userId,
      'content': content,
      'group_id': widget.groupId,
      'type': 'text',
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
      'deleted_for_everyone': 0,
    };
    _webSocketService.sendMessage(message);
  }

  void _onTyping(bool isTyping) {
    // widget.webSocketService.sendTypingEvent(widget.chatId, 1);
  }

  @override
  Widget build(BuildContext context) {
    return
        // PopScope(
        //   onPopInvoked: (didPop) {
        //     chatState.closeChat();
        //   },
        //   child:
        Scaffold(
      appBar: AppBar(
        leadingWidth: 65,
        title: Text('Group chat ${widget.groupId}'),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const Icon(
                Icons.chevron_left,
                opticalSize: 30,
              ),
              CircleAvatar(
                child: Text(
                  widget.groupId.toString()[0],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.videocam_outlined,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call_outlined,
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'clear_chat',
                  child: Text('Clear chat'),
                )
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'clear_chat':
                  _dbHelper.clearChat(widget.groupId);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: _dbHelper.updateStream,
                builder: (context, snapshot) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: _dbHelper.getMessagesByChatId(widget.groupId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return const Center(
                            child: Text('No messages available.'));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final Message message =
                              Message.fromMap(messages[index]);
                          return MessageBubble(
                            message: message,
                            isMe: message.SenderId == CurrentUser.userId,
                          );
                        },
                      );
                    },
                  );
                }),
          ),
          MessageInput(
            onSendClicked: _sendMessage,
            onTyping: _onTyping,
            controller: _messageController,
            buildFileAttachments: () {},
            focusNode: focusNode,
            getMediaFromCamera: () {},
            onMicClicked: () {
              print('Mic clicked');
            },
            showEmojiPicker: showEmojiPicker,
          ),
        ],
      ),
    );
    //   ,
    // );
  }
}
