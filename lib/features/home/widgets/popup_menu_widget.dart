import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/group/pages/select_contact_for_group.dart';
import 'package:whatsapp_clone/features/home/pages/home_page.dart';
import 'package:whatsapp_clone/features/settings/presentation/pages/settings_page.dart';

class CustomPopupMenuButton extends StatelessWidget {
  CustomPopupMenuButton({super.key});

  final List<String> items = [
    'New group',
    'New broadcast',
    'Starred messages',
    'Settings',
  ];
  final Map<String, Widget> pages = {
    'New group': const SelectContactForGroup(),
    'New broadcast': const HomePage(),
    'Starred messages': const HomePage(),
    'Settings': const SettingsPage(),
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return items
            .map(
              (item) => PopupMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList();
      },
      onSelected: (value) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => pages[value]!,
          ),
        );
      },
    );
  }
}
