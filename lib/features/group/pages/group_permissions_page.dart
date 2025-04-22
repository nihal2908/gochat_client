import 'package:flutter/material.dart';

class GroupPermissionsPage extends StatefulWidget {
  final List<bool> permissions;
  const GroupPermissionsPage({super.key, required this.permissions});

  @override
  State<GroupPermissionsPage> createState() => _GroupPermissionsPageState();
}

class _GroupPermissionsPageState extends State<GroupPermissionsPage> {
  late final List<bool> isSelected;

  @override
  void initState() {
    isSelected = widget.permissions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group permissions'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 15,
              top: 20,
            ),
            child: Text(
              'Members can:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit group settings'),
            subtitle: const Text(
              'This includes the name, icon, description, disappearing message timer, and the ability to pin, keep or unkeep messages.',
            ),
            trailing: MySwitch(index: 0, isSelected: isSelected),
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Send messages'),
            trailing: MySwitch(index: 1, isSelected: isSelected),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Add other members'),
            trailing: MySwitch(index: 2, isSelected: isSelected),
          ),
          Divider(
            color: Colors.grey.shade200,
            height: 2,
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 15,
              top: 20,
            ),
            child: Text(
              'Admins can:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: const Text('Approve new members'),
            subtitle: const Text(
              'When turned on, admins must approve anyone who wants to join the group.',
            ),
            trailing: MySwitch(index: 3, isSelected: isSelected),
          ),
        ],
      ),
    );
  }

  Widget MySwitch({
    required List<bool> isSelected,
    required int index,
  }) {
    return Switch(
      value: isSelected[index],
      onChanged: (value) {
        setState(() {
          isSelected[index] = value;
        });
      },
    );
  }
}
