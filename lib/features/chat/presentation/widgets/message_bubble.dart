import 'package:flutter/material.dart';
import 'package:whatsapp_clone/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
            minWidth: MediaQuery.of(context).size.width * 0.2,
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.green.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    message.Content,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.Edited == 1)
                        Text(
                          'Edited',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      if (message.Edited == 1)
                        const SizedBox(
                          width: 4,
                        ),
                      Text(
                        message.Timestamp.toString().substring(11, 16),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      message.Status == 'sent'
                          ? const Icon(
                              Icons.check,
                              size: 14,
                            )
                          : message.Status == 'read'
                              ? Icon(
                                  Icons.done_all,
                                  color: Colors.blue.shade700,
                                  size: 14,
                                )
                              : message.Status == 'delivered'
                                  ? const Icon(
                                      Icons.done_all,
                                      size: 14,
                                    )
                                  : const Icon(
                                      Icons.pending_outlined,
                                      size: 14,
                                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
            minHeight: MediaQuery.of(context).size.width * 0.2,
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.grey.shade300,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 30,
                    top: 5,
                    bottom: 20,
                  ),
                  child: Text(
                    textAlign: TextAlign.left,
                    message.Content,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.Edited == 1)
                        Text(
                          'Edited',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      Text(
                        message.Timestamp.toString().substring(11, 16),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
