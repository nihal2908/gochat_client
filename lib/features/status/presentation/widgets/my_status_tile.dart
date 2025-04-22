import 'package:flutter/material.dart';

class MyStatusTile extends StatelessWidget {

  const MyStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/default_profile.jpg'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        'My Status',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Tap to add status update',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 13,
        ),
      ),
      onTap: () {},
    );
  }
}
