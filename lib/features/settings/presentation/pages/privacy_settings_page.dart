import 'package:flutter/material.dart';

import '../../../../common/theme.dart';
import '../widgets/settings_tile.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Who can see my personal info',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.access_time,
            iconColor: Colors.blue,
            title: 'Last seen and online',
            subtitle: 'Everyone',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.photo,
            iconColor: Colors.purple,
            title: 'Profile photo',
            subtitle: 'Everyone',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.info_outline,
            iconColor: Colors.teal,
            title: 'About',
            subtitle: 'Everyone',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.circle,
            iconColor: Colors.red,
            title: 'Status',
            subtitle: 'My contacts',
            onTap: () {},
          ),
          const Divider(),
          SettingsTile(
            icon: Icons.read_more,
            iconColor: Colors.blue,
            title: 'Read receipts',
            subtitle: 'When turned off, you won\'t send or receive read receipts',
            onTap: () {},
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: WhatsAppTheme.lightGreen,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Read receipts are always sent for group chats',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          SettingsTile(
            icon: Icons.block,
            iconColor: Colors.red,
            title: 'Blocked contacts',
            subtitle: '3 contacts',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.lock_clock,
            iconColor: Colors.amber,
            title: 'Disappearing messages',
            subtitle: 'Off',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.fingerprint,
            iconColor: Colors.blue,
            title: 'Fingerprint lock',
            subtitle: 'Off',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
