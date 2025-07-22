import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/database/current.dart';
import 'package:whatsapp_clone/features/auth/api/auth_api.dart';
import 'package:whatsapp_clone/features/settings/presentation/pages/account_setting_page.dart';
import 'package:whatsapp_clone/features/settings/presentation/pages/chat_setting_page.dart';
import 'package:whatsapp_clone/features/settings/presentation/pages/help_page.dart';
import 'package:whatsapp_clone/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:whatsapp_clone/features/settings/presentation/pages/privacy_settings_page.dart';
import 'package:whatsapp_clone/features/settings/presentation/pages/storage_setting_page.dart';
import 'package:whatsapp_clone/features/splash/splash_page.dart';
import 'package:whatsapp_clone/utils/utils.dart';

import '../../../../common/theme.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: WhatsAppTheme.lightGrey,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: WhatsAppTheme.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Name',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status message',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: WhatsAppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.qr_code,
                    color: WhatsAppTheme.lightGreen,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(),
          SettingsTile(
            icon: Icons.key,
            iconColor: Colors.blue,
            title: 'Account',
            subtitle: 'Security notifications, change number',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => AccountSettingsPage())),
          ),
          SettingsTile(
            icon: Icons.lock,
            iconColor: Colors.teal,
            title: 'Privacy',
            subtitle: 'Block contacts, disappearing messages',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => PrivacySettingsPage())),
          ),
          SettingsTile(
            icon: Icons.chat_bubble,
            iconColor: WhatsAppTheme.lightGreen,
            title: 'Chats',
            subtitle: 'Theme, wallpapers, chat history',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatSettingsPage())),
          ),
          SettingsTile(
            icon: Icons.notifications,
            iconColor: Colors.red,
            title: 'Notifications',
            subtitle: 'Message, group & call tones',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationSettingsPage())),
          ),
          SettingsTile(
            icon: Icons.data_usage,
            iconColor: Colors.green,
            title: 'Storage and data',
            subtitle: 'Network usage, auto-download',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => StorageSettingPage())),
          ),
          SettingsTile(
            icon: Icons.language,
            iconColor: Colors.purple,
            title: 'App language',
            subtitle: 'English (device)',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.help_outline,
            iconColor: Colors.cyan,
            title: 'Help',
            subtitle: 'Help center, contact us, privacy policy',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => HelpPage())),
          ),
          SettingsTile(
            icon: Icons.group,
            iconColor: Colors.orange,
            title: 'Invite a friend',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    showLoadingMessage(
      message: 'Signing you out...',
      context: context,
    );

    final response = await AuthApi.logout(phone: '', id: '', countryCode: '');
    if (response.success) {
      final prefs = await SharedPreferences.getInstance();
      if (await prefs.clear()) {
        Current.signOut();
      }

      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
      showTextSnackBar(context: context, text: response.message);
    }
  }
}
