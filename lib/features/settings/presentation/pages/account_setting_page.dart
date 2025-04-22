import 'package:flutter/material.dart';
import '../widgets/settings_tile.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.security,
            iconColor: Colors.blue,
            title: 'Security',
            subtitle: 'Show security notifications',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.verified_user,
            iconColor: Colors.green,
            title: 'Two-step verification',
            subtitle: 'Add additional security to your account',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.phonelink_setup,
            iconColor: Colors.amber,
            title: 'Change number',
            subtitle: 'Transfer your account to a new phone number',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.request_page,
            iconColor: Colors.indigo,
            title: 'Request account info',
            subtitle: 'Request a report of your account information',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            title: 'Delete my account',
            subtitle: 'Change number or delete account permanently',
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Deleting your account will remove you from all WhatsApp groups, delete your message history, and remove all backups.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
