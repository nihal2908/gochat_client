import 'package:flutter/material.dart';

class Statics {
  static void showLoadingMessage({
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
                Text(message),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static showTextSnackBar({
    required BuildContext context,
    required String text,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
