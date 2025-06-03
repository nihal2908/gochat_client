import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/auth/presentation/pages/user_profile_page.dart';
import 'package:whatsapp_clone/features/calls/webrtc_handler.dart';
import 'package:whatsapp_clone/features/camera/camera_screen.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/deleted_message_bubble.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/media_bubble.dart';
import 'package:whatsapp_clone/features/chat/provider/chat_provider.dart';
import 'package:whatsapp_clone/features/chat/websocket/websocket_service.dart';
import 'package:whatsapp_clone/features/contact/select_contacts_to_send.dart';
import 'package:whatsapp_clone/features/media/media_preview_page.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/sending_contact.dart';
import 'package:whatsapp_clone/models/user.dart';
import 'package:whatsapp_clone/providers/websocket_provider.dart';
import '../widgets/message_bubble.dart';

class ChatRoomPage extends StatefulWidget {
  final String chatId;
  final String userId;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.userId,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late final DBHelper _dbHelper;
  late final ChatState chatState;
  late final WebSocketService _webSocketService;
  late final WebRTCHandler _webrtcHandler;
  // final ScrollController _scrollController = ScrollController();
  final Set<Message> selectedMessages = <Message>{};
  bool hasSentMessages = false;
  bool hasReceivedMessages = false;
  bool hasDeletedMessage = false;
  double? previousPosition;
  late final User user;
  bool showEmojiPicker = false;
  bool showFileAttachment = false;
  final FocusNode focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showEmojiPicker = false;
        });
      }
    });
    _dbHelper = DBHelper();
    getUser();
    _webSocketService =
        Provider.of<WebSocketProvider>(context, listen: false).webSocketService;
    _webrtcHandler = WebRTCHandler();
    chatState = Provider.of<ChatState>(context, listen: false);
    chatState.openChat(widget.chatId);
    _markAllMessagesAsRead();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
  }

  void getUser() async {
    final result = await _dbHelper.getUserById(widget.userId);
    user = User.fromMap(result!);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (showEmojiPicker) {
          setState(() {
            showEmojiPicker = false;
          });
        } else if (selectedMessages.isNotEmpty) {
          setState(() {
            clearSelections();
          });
        } else {
          chatState.closeChat();
          // Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          Image.asset(
            'assets/images/chat_bg.png',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leadingWidth: 65,
              backgroundColor: Colors.white,
              title: selectedMessages.isEmpty
                  ? InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                      child: Text('Chat with ${widget.userId}'),
                    )
                  : Text('${selectedMessages.length} selected'),
              leading: selectedMessages.isEmpty
                  ? InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chevron_left,
                            opticalSize: 30,
                          ),
                          CircleAvatar(
                            child: Text(
                              widget.chatId.toString()[0],
                            ),
                          ),
                        ],
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          clearSelections();
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
              actions: selectedMessages.isEmpty
                  ? showNormalActions()
                  : showSelectedActions(),
            ),
            body: Column(
              children: [
                messageList(),
                customTextfield(),
                showEmojiPicker ? selectEmoji() : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void _scrollToBottom() {
  //   if (_scrollController.hasClients) {
  //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   }
  // }

  void _markAllMessagesAsRead() {
    _webSocketService.sendReadAcknowledement(
      chatId: widget.chatId,
      senderId: widget.userId,
      receiverId: CurrentUser.userId!,
    );
  }

  void _sendMessage(String content) {
    final message = {
      '_id': const Uuid().v4(),
      'sender_id': CurrentUser.userId,
      'receiver_id': widget.userId,
      'content': content,
      'size': 0,
      'chat_id': widget.chatId,
      'type': 'text',
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
      'deleted_for_everyone': 0,
    };
    _webSocketService.sendMessage(message);
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   duration: Duration(milliseconds: 500),
    //   curve: Curves.easeOut,
    // );
  }

  void _onTyping(bool isTyping) {
    // widget.webSocketService.sendTypingEvent(widget.chatId, 1);
  }

  void updateSelectionTypes() {
    hasSentMessages = selectedMessages.any((message) {
      return message.SenderId == CurrentUser.userId;
    });

    hasReceivedMessages = selectedMessages.any((message) {
      return message.ReceiverId == CurrentUser.userId;
    });

    hasDeletedMessage = selectedMessages.any((message) {
      return message.DeletedForEveryone == 1;
    });
  }

  void showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Chat?'),
          content:
              const Text('This will delete all the messages for everyone!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                _dbHelper.clearChat(widget.chatId);
                Navigator.pop(context);
              },
              child:
                  const Text('Clear Chat', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void copySelectedMessages() {
    final selectedText = selectedMessages.map((message) {
      if (message.SenderId == CurrentUser.userId) {
        return message.Type == 'text'
            ? 'Me: ${message.Content}'
            : 'Me: ${message.Type}';
      } else {
        return message.Type == 'text'
            ? '${user.Title}: ${message.Content}'
            : '${user.Title}: ${message.Type}';
      }
    }).join('\n');

    Clipboard.setData(ClipboardData(text: selectedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Messages copied to clipboard')),
    );
    setState(() {
      clearSelections();
    });
  }

  void deleteSelectedMessages(bool forEveryone) {
    if (forEveryone) {
      for (final message in selectedMessages) {
        _webSocketService.sendDeleteMessage(message.toMap());
      }
    } else {
      _dbHelper.deleteMultipleMessages(
        selectedMessages.map((message) => message.Id).toList(),
      );
    }
    setState(() {
      selectedMessages.clear();
    });
  }

  void showDeleteMessageALert(bool showDeleteForEveryone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete messages'),
        content: Text(
          'The selected messages will be deleted. This cannot be undone.',
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  deleteSelectedMessages(false);
                  Navigator.pop(context);
                },
                child: Text('Delete for me'),
              ),
              if (showDeleteForEveryone)
                ElevatedButton(
                  onPressed: () {
                    deleteSelectedMessages(true);
                    Navigator.pop(context);
                  },
                  child: Text('Delete for everyone'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void editSelectedMessage({
    required Function() onEdit,
  }) {
    final message = selectedMessages.first;
    if (message.Type != 'text') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only text messages can be edited')),
      );
      return;
    }
    String currentMessage = message.Content;

    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController editController =
            TextEditingController(text: currentMessage);
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: editController,
            minLines: 1,
            maxLines: 5,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Message...'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.trim().isNotEmpty) {
                  message.Content = editController.text.trim();
                  _webSocketService.sendEditMessage(message.toMap());
                  Navigator.pop(context);
                  onEdit();
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _handleInputChange(String text) {
    if (text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      _onTyping(true);
    } else if (text.isEmpty && _isTyping) {
      setState(() {
        _isTyping = false;
      });
      _onTyping(false);
    }
  }

  Widget selectEmoji() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        if (_controller.text.isEmpty) {
          setState(() {
            _isTyping = true;
          });
        }
        _controller.text = _controller.text + emoji.emoji;
      },
    );
  }

  buildFileAttachments() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => SizedBox(
        height: 278,
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  attachmentTile(
                    Icons.image,
                    'Gallery',
                    Colors.blue,
                    onTap: pickImage,
                  ),
                  attachmentTile(
                    Icons.camera_alt,
                    'Camera',
                    Colors.green,
                    onTap: getMediaFromCamera,
                  ),
                  attachmentTile(
                    Icons.insert_drive_file,
                    'Document',
                    Colors.orange,
                    onTap: () => pickFile(FileType.any),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  attachmentTile(
                    Icons.contacts,
                    'Contact',
                    Colors.purple,
                    onTap: selectContacts,
                  ),
                  attachmentTile(
                    Icons.location_on,
                    'Location',
                    Colors.red,
                  ),
                  attachmentTile(
                    Icons.music_note,
                    'Audio',
                    Colors.pink,
                    onTap: () => pickFile(FileType.audio),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget attachmentTile(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(
                icon,
                size: 29,
              ),
            ),
            SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }

  void pickImage() async {
    List<XFile> xfiles = await _picker.pickMultiImage(
      limit: 10,
    );
    if (xfiles.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaPreviewPage(
            files: xfiles.map((file) => File(file.path)).toList(),
          ),
        ),
      );
    }
  }

  void pickFile(FileType fileType) async {
    FilePickerResult? result = await _filePicker.pickFiles(type: fileType);
    if (result != null) {
      File file = File(result.files.single.path!);
      print(file.path);
    }
  }

  void getMediaFromCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          sentToUsers: [user],
          caption: _controller.text,
        ),
      ),
    ).then((result) async {
      if (result == null) {
        return;
      } else {
        //pahle content me local path dal do bad me upload ke bad jo url return ho wo dal denge fir send message
        final message = {
          '_id': const Uuid().v4(),
          'sender_id': CurrentUser.userId,
          'receiver_id': widget.userId,
          'chat_id': widget.chatId,
          'content': result['path'],
          'caption': result['caption'],
          'size': result['size'],
          'type': 'image',
          'status': 'uploading',
          'timestamp': DateTime.now().toIso8601String(),
          'deleted_for_everyone': 0,
        };

        _controller.clear();

        await _dbHelper.insertMediaMessage(
          message,
          result['path'],
        );

        // final String? url = await _uploadMedia(result['path'], result['type']);
        // if (url != null) {
        //   message['content'] = url;
        //   message['status'] = 'pending';
        //   await _dbHelper.updateMediaMessage(
        //     Message.fromMap(message),
        //     result['path'],
        //   );
        //   _webSocketService.sendMessage(message);
        // } else {
        //   return;
        // }
      }
    });
  }

  void selectContacts() async {
    List<SendingContact> contacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectContactsToSend(),
      ),
    );
    print(contacts.toString());
  }

  Widget customTextfield() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              margin: EdgeInsets.only(left: 2, right: 2, bottom: 4),
              child: TextField(
                focusNode: focusNode,
                controller: _controller,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  contentPadding: EdgeInsets.all(5),
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    icon: Icon(
                      showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                    ),
                    onPressed: () {
                      if (showEmojiPicker) {
                        focusNode.requestFocus();
                      } else {
                        focusNode.unfocus();
                        focusNode.canRequestFocus = false;
                      }
                      setState(() {
                        showEmojiPicker = !showEmojiPicker;
                      });
                    },
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // setState(() {
                          //   showFileAttachment =
                          //       !showFileAttachment;
                          // });
                          buildFileAttachments();
                        },
                        icon: Icon(
                          Icons.attach_file,
                        ),
                      ),
                      _isTyping
                          ? Container()
                          : IconButton(
                              onPressed: () {
                                getMediaFromCamera();
                              },
                              icon: Icon(
                                Icons.camera_alt,
                              ),
                            ),
                    ],
                  ),
                ),
                onChanged: _handleInputChange,
              ),
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal,
            child: IconButton(
              icon: Icon(
                _isTyping ? Icons.send : Icons.mic,
                color: Colors.white,
              ),
              onPressed: () {
                if (_isTyping) {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    _sendMessage(text);
                    _controller.clear();
                    _handleInputChange('');
                  }
                } else {
                  print('mic clicked');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget messageList() {
    return Expanded(
      child: StreamBuilder(
        stream: _dbHelper.updateStream,
        builder: (context, snapshot) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _dbHelper.getMessagesByChatId(widget.chatId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return const Center(child: Text('No messages available.'));
              }

              if (messages.last['receiver_id'] == CurrentUser.userId &&
                  messages.last['status'] != 'read') {
                _markAllMessagesAsRead();
              }

              return ListView.builder(
                reverse: true,
                // controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final Message message = Message.fromMap(messages[index]);
                  final bool isSelected = selectedMessages.contains(message);
                  final bool isMe = message.SenderId == CurrentUser.userId;
                  final bool isDeleted = message.DeletedForEveryone == 1;
                  final bool isText = message.Type == 'text';

                  return InkWell(
                    onTap: () {
                      if (selectedMessages.isNotEmpty) {
                        setState(() {
                          if (isSelected) {
                            selectedMessages.remove(message);
                          } else {
                            selectedMessages.add(message);
                          }
                          updateSelectionTypes();
                          // previousPosition = _scrollController.offset;
                        });
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        if (isSelected) {
                          selectedMessages.remove(message);
                        } else {
                          selectedMessages.add(message);
                        }
                        updateSelectionTypes();
                        // previousPosition = _scrollController.offset;
                      });
                    },
                    child: Container(
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.3)
                          : null,
                      child: isDeleted
                          ? DeletedMessageBubble(
                              message: message,
                              isMe: isMe,
                            )
                          : isText
                              ? MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                )
                              : MediaBubble(
                                  message: message,
                                  isMe: isMe,
                                  dbHelper: _dbHelper,
                                  webSocketService: _webSocketService,
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
  }

  List<Widget> showNormalActions() {
    return [
      IconButton(
        onPressed: () {
          _webrtcHandler.startCall(widget.userId);
        },
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
              showClearChatDialog(context);
          }
        },
      )
    ];
  }

  List<Widget> showSelectedActions() {
    return [
      IconButton(
        onPressed: () {
          showDeleteMessageALert(!hasReceivedMessages && !hasDeletedMessage);
        },
        icon: const Icon(
          Icons.delete,
        ),
      ),
      if (!hasDeletedMessage)
        IconButton(
          onPressed: () {
            copySelectedMessages();
          },
          icon: const Icon(
            Icons.copy,
          ),
        ),
      if (!hasReceivedMessages && selectedMessages.length == 1)
        IconButton(
          onPressed: () {
            editSelectedMessage(
              onEdit: () {
                setState(() {
                  clearSelections();
                });
              },
            );
          },
          icon: const Icon(
            Icons.edit,
          ),
        ),
    ];
  }

  void clearSelections() {
    selectedMessages.clear();
    hasSentMessages = false;
    hasReceivedMessages = false;
    hasDeletedMessage = false;
  }
}
