import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/status/presentation/widgets/my_status_tile.dart';
import 'package:whatsapp_clone/features/status/presentation/widgets/status_tile.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyStatusTile(),
            SizedBox(height: 10),
            label(text: 'Recent Updates'),
            StatusTile(
              imageUrl: '',
              userName: 'Nihal Yadav',
              time: '12:30',
              seenCount: 3,
              totalCount: 20,
            ),
            StatusTile(
              imageUrl: '',
              userName: 'Nihal Yadav',
              time: '12:30',
              seenCount: 2,
              totalCount: 7,
            ),
            StatusTile(
              imageUrl: '',
              userName: 'Nihal Yadav',
              time: '12:30',
              seenCount: 9,
              totalCount: 16,
            ),
            StatusTile(
              imageUrl: '',
              userName: 'Nihal Yadav',
              time: '12:30',
              seenCount: 7,
              totalCount: 7,
            ),
            SizedBox(height: 10),
            label(text: 'Viewed Updates'),
            StatusTile(
              imageUrl: '',
              userName: 'Nihal Yadav',
              time: '12:30',
              seenCount: 1,
              totalCount: 1,
            ),
            StatusTile(
              imageUrl: '',
              userName: 'Nihal Yadav',
              time: '12:30',
              seenCount: 2,
              totalCount: 2,
            ),
            StatusTile(
              imageUrl: '',
              userName: 'Nihal Yadav',
              time: '12:30',
              seenCount: 1,
              totalCount: 1,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 48,
            child: FloatingActionButton(
              backgroundColor: Colors.blueGrey[100],
              elevation: 8,
              onPressed: () {},
              child: Icon(
                Icons.edit,
                color: Colors.blueGrey.shade900,
              ),
            ),
          ),
          SizedBox(
            height: 13,
          ),
          FloatingActionButton(
            onPressed: () {},
            elevation: 5,
            backgroundColor: Colors.blueGrey.shade100,
            child: Icon(
              Icons.camera_alt,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget label({required String text}) {
    return Container(
      height: 33,
      width: MediaQuery.of(context).size.width,
      color: Colors.grey.shade300,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
