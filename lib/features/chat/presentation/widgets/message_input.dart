import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final Function(bool) onTyping;

  const MessageInput({Key? key, required this.onSend, required this.onTyping})
      : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  void _handleInputChange(String text) {
    if (text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      widget.onTyping(true);
    } else if (text.isEmpty && _isTyping) {
      setState(() {
        _isTyping = false;
      });
      widget.onTyping(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              margin: EdgeInsets.only(left: 2, right: 2, bottom: 8),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                textAlign: TextAlign.center,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  contentPadding: EdgeInsets.all(5),
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    icon: Icon(Icons.emoji_emotions),
                    onPressed: () {},
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.attach_file,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
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
            radius: 25,
            backgroundColor: Colors.teal,
            child: IconButton(
              icon: Icon(
                _isTyping ? Icons.send : Icons.mic,
                color: Colors.white,
              ),
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  widget.onSend(text);
                  _controller.clear();
                  _handleInputChange('');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
