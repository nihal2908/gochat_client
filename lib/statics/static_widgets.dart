import 'package:flutter/material.dart';

class Statics {
  static Map<String, Icon> statusIcon = {
    'sent': const Icon(Icons.check, size: 14),
    'delivered': const Icon(Icons.done_all, size: 14),
    'read': const Icon(Icons.done_all, color: Colors.blue, size: 14),
    'pending': const Icon(Icons.pending_outlined, size: 14),
    'uploading': const Icon(Icons.pending_outlined, size: 14),
  };

  static Map<String, Icon> messageTypeIcon = {
    'text': const Icon(Icons.text_fields, size: 14),
    'image': const Icon(Icons.image, size: 14),
    'video': const Icon(Icons.video_call, size: 14),
    'audio': const Icon(Icons.audiotrack, size: 14),
    'document': const Icon(Icons.insert_drive_file, size: 14),
    'location': const Icon(Icons.location_on, size: 14),
    'contact': const Icon(Icons.contact_phone, size: 14),
    'sticker': const Icon(Icons.emoji_emotions, size: 14),
  };

  static const String defaultProfileImage = 'assets/images/default_profile.jpg';
}
