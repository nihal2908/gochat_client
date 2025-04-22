import 'package:flutter/material.dart';
import 'package:whatsapp_clone/models/message.dart';

class DeletedMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const DeletedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          minWidth: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: isMe ? Colors.green.shade200 : Colors.grey.shade300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Text(
                  'This message was deleted',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 8,
                  bottom: 2,
                ),
                child: message.Status == 'sent'
                    ? const Icon(
                        Icons.check,
                        size: 14,
                      )
                    : const Icon(
                        Icons.pending_outlined,
                        size: 14,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
