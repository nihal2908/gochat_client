import 'package:flutter/material.dart';

import '../../../../common/theme.dart';
import '../widgets/settings_tile.dart';

class ChatSettingsPage extends StatelessWidget {
  const ChatSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Display',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.wallpaper,
            iconColor: Colors.purple,
            title: 'Wallpaper',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.format_size,
            iconColor: Colors.blue,
            title: 'Chat size',
            subtitle: 'Medium',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Chat settings',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.archive,
            iconColor: Colors.teal,
            title: 'Chat backup',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.history,
            iconColor: Colors.amber,
            title: 'Chat history',
            onTap: () {},
          ),
          const Divider(),
          SettingsTile(
            icon: Icons.auto_awesome,
            iconColor: Colors.green,
            title: 'Enter is send',
            subtitle: 'Enter key will send your message',
            onTap: () {},
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: WhatsAppTheme.lightGreen,
            ),
          ),
          SettingsTile(
            icon: Icons.text_fields,
            iconColor: Colors.indigo,
            title: 'Media visibility',
            subtitle: 'Show newly downloaded media in your device\'s gallery',
            onTap: () {},
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: WhatsAppTheme.lightGreen,
            ),
          ),
          SettingsTile(
            icon: Icons.font_download,
            iconColor: Colors.red,
            title: 'Font size',
            subtitle: 'Medium',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
