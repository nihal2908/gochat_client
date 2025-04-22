import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About Us"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text("Contact Support"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.policy),
            title: Text("Privacy Policy"),
          ),
        ],
      ),
    );
  }
}
