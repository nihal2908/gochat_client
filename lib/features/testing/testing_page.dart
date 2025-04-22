import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/testing/testing_file_upload.dart';

class TestFunctionPage extends StatefulWidget {
  @override
  _TestFunctionPageState createState() => _TestFunctionPageState();
}

class _TestFunctionPageState extends State<TestFunctionPage> {
  Future<void> fetchCallLogData() async {
    // Replace with your database query logic
    final db = await DBHelper().database;
    final queryResult = await db.rawQuery("""
      SELECT 
        CallLog.*, 
        COALESCE(Contact.name, Caller.name) AS caller_name, 
        Caller.phone AS caller_phone, 
        Caller.country_code AS caller_country_code, 
        Caller.profile_picture_url AS caller_profile_picture_url, 
        Caller.status_message AS caller_status_message, 
        Caller.last_seen AS caller_last_seen, 
        Caller.is_online AS caller_is_online, 
        Caller.created_at AS caller_created_at, 
        Caller.updated_at AS caller_updated_at 
      FROM CallLog 
      LEFT JOIN User AS Caller ON CallLog.caller_id = Caller._id 
      LEFT JOIN Contact ON Contact.user_id = Caller._id
      ORDER BY CallLog.start_time DESC;
      """);
    print(queryResult);

    if (queryResult.isNotEmpty) {
      final callLogs = queryResult.map((callLog) {
        return {
          "id": callLog['id'],
          "caller": {
            "name": callLog['caller_name'],
            "phone": callLog['caller_phone'],
            "country_code": callLog['caller_country_code'],
            "profile_picture_url": callLog['caller_profile_picture_url'],
            "status_message": callLog['caller_status_message'],
            "last_seen": callLog['caller_last_seen'],
            "is_online": callLog['caller_is_online'],
            "created_at": callLog['caller_created_at'],
            "updated_at": callLog['caller_updated_at']
          },
          "receiver_id": callLog['receiver_id'],
          "call_type": callLog['call_type'],
          "start_time": callLog['start_time'],
          "end_time": callLog['end_time'],
          "status": callLog['status']
        };
      }).toList();
      // print(callLogs);
    } else {
      throw Exception("No data found");
    }
  }

  Future<void> func() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Function Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  func();
                },
                child: const Text('Fetch Call Log Data'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // final db = await DBHelper().database;
                  // final result = await DBHelper().fetchChats();
                  // print(result);
                  await fetchCallLogData();
                },
                child: const Text('Fetch Call Log Data'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final res = await DBHelper().getCalls();
                  res.forEach((call) {
                    print(call.toMap());
                  });
                },
                child: const Text('Fetch Call Log Data'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final res = await DBHelper().getChats();
                  // res.forEach((call) {
                  //   print(call.toMap());
                  // });
                },
                child: const Text('Fetch Chats Data'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = await DBHelper().database;
                  await db.delete(
                    'Groups',
                  );
                  await db.delete(
                    'GroupMember',
                  );
                },
                child: const Text('Delete all groups data'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = await DBHelper().database;
                  await db.delete(
                    'Chat',
                  );
                  await db.delete(
                    'Message',
                  );
                },
                child: const Text('Delete all chats and msgs'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = await DBHelper().database;
                  print(await db.query(
                    'Groups',
                  ));
                },
                child: const Text('Print all the group table data'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = DBHelper();
                  final result = await db.getGroupChats();
                  result.forEach((value) => print(value.toMap()));
                },
                child: const Text('Print the query result of group list page'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadScreen(),
                    ),
                  );
                },
                child: const Text('Upload image'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final db = await DBHelper().database;
                  await db.delete(
                    'User',
                  );
                  await db.delete(
                    'Contact',
                  );
                },
                child: const Text('Delete all contacts and users data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
