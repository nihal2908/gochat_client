import 'package:flutter/material.dart';

import '../../../../common/theme.dart';
import '../widgets/settings_tile.dart';

class StorageSettingPage extends StatelessWidget {
  const StorageSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage and data'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Storage',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.manage_search,
            iconColor: Colors.amber,
            title: 'Manage storage',
            subtitle: '273.0 MB',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Network',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.network_cell,
            iconColor: Colors.green,
            title: 'Network usage',
            subtitle: '273.0 MB sent • 1.2 GB received',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Media auto-download',
              style: TextStyle(
                color: WhatsAppTheme.tealGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.wifi,
            iconColor: Colors.blue,
            title: 'When using mobile data',
            subtitle: 'Photos',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.wifi_tethering,
            iconColor: Colors.teal,
            title: 'When connected on Wi-Fi',
            subtitle: 'All media',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.web,
            iconColor: Colors.indigo,
            title: 'When roaming',
            subtitle: 'No media',
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Media upload quality',
                  style: TextStyle(
                    color: WhatsAppTheme.tealGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: WhatsAppTheme.lightGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Auto',
                    style: TextStyle(
                      color: WhatsAppTheme.tealGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Choose the quality of media files to send in chats. Higher quality media uses more data.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.high_quality,
            iconColor: Colors.purple,
            title: 'Photo upload quality',
            subtitle: 'Auto (recommended)',
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}