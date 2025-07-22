import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showLoadingMessage({
  required String message,
  required BuildContext context,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: CircularProgressIndicator()),
              const SizedBox(width: 10),
              Text(message),
            ],
          ),
        ],
      ),
    ),
  );
}

showTextSnackBar({
  required BuildContext context,
  required String text,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
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
