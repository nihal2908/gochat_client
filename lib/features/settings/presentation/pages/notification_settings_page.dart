import 'package:flutter/material.dart';

import '../../../../common/theme.dart';
import '../widgets/settings_tile.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Message notifications',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.message,
            iconColor: Colors.blue,
            title: 'Conversation tones',
            subtitle: 'Play sounds for incoming and outgoing messages',
            onTap: () {},
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: WhatsAppTheme.lightGreen,
            ),
          ),
          SettingsTile(
            icon: Icons.notifications,
            iconColor: Colors.amber,
            title: 'Notification tone',
            subtitle: 'Default (notification_sound)',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.vibration,
            iconColor: Colors.purple,
            title: 'Vibration',
            subtitle: 'Default',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.light_mode,
            iconColor: Colors.orange,
            title: 'Notification light',
            subtitle: 'White',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Group notifications',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.notifications_active,
            iconColor: Colors.green,
            title: 'Notification tone',
            subtitle: 'Default (notification_sound)',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.vibration,
            iconColor: Colors.indigo,
            title: 'Vibration',
            subtitle: 'Default',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.light_mode,
            iconColor: Colors.red,
            title: 'Notification light',
            subtitle: 'White',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Call notifications',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.ring_volume,
            iconColor: Colors.green,
            title: 'Ringtone',
            subtitle: 'Default (ringtone_sound)',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.vibration,
            iconColor: Colors.teal,
            title: 'Vibration',
            subtitle: 'Default',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
