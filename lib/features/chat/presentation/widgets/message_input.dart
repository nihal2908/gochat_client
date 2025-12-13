import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendClicked;
  final Function(bool)? onTyping;
  final Function() onMicClicked;
  final Function() getMediaFromCamera;
  final Function() buildFileAttachments;
  final FocusNode focusNode;
  final ValueNotifier showEmojiPicker;

  const MessageInput({
    Key? key,
    required this.onSendClicked,
    required this.controller,
    required this.onTyping,
    required this.onMicClicked,
    required this.getMediaFromCamera,
    required this.buildFileAttachments,
    required this.focusNode,
    required this.showEmojiPicker,
  }) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isTyping = false;

  void _handleInputChange(String text) {
    if (text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      widget.onTyping ?? (true);
    } else if (text.isEmpty && _isTyping) {
      setState(() {
        _isTyping = false;
      });
      widget.onTyping ?? (false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                focusNode: widget.focusNode,
                controller: widget.controller,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  contentPadding: EdgeInsets.all(5),
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    icon: Icon(
                      widget.showEmojiPicker.value
                          ? Icons.keyboard
                          : Icons.emoji_emotions,
                    ),
                    onPressed: () {
                      if (widget.showEmojiPicker.value) {
                        widget.focusNode.requestFocus();
                      } else {
                        widget.focusNode.unfocus();
                        widget.focusNode.canRequestFocus = false;
                      }
                      setState(() {
                        widget.showEmojiPicker.value =
                            !widget.showEmojiPicker.value;
                      });
                    },
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.buildFileAttachments();
                        },
                        icon: Icon(
                          Icons.attach_file,
                        ),
                      ),
                      _isTyping
                          ? Container()
                          : IconButton(
                              onPressed: () {
                                widget.getMediaFromCamera();
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
                  widget.onSendClicked(widget.controller.text.trim());
                  _handleInputChange('');
                } else {
                  widget.onMicClicked();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
