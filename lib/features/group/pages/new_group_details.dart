import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/group/api/group_apis.dart';
import 'package:whatsapp_clone/features/group/pages/group_permissions_page.dart';
import 'package:whatsapp_clone/models/contact.dart';

class NewGroupDetails extends StatefulWidget {
  const NewGroupDetails({super.key, required this.members});
  final List<Contact> members;

  @override
  State<NewGroupDetails> createState() => _NewGroupDetailsState();
}

class _NewGroupDetailsState extends State<NewGroupDetails> {
  final TextEditingController groupName = TextEditingController();
  final TextEditingController groupDescription = TextEditingController();
  List<String> disappMsg = ['24 hours', '7 days', '30 days', '90 days', 'Off'];
  String disappMsgSelection = 'Off';
  bool memEdit = true, memAdd = true, memSend = true, adminApprove = false;
  File? _imageFile;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool uploadingImage = false;
  final DBHelper _dbHelper = DBHelper();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Call upload function
      await _uploadImage(_imageFile!);
    }
  }

  // Function to upload the selected image (Dummy function)
  Future<void> _uploadImage(File image) async {
    setState(() {
      uploadingImage = true;
    });
    // Simulating an image upload by setting a dummy URL
    final response = await GroupApis.uploadImage(image.path);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        uploadingImage = false;
        _uploadedImageUrl = body["image_url"];
      });
    } else {
      setState(() {
        uploadingImage = false;
      });
      _showSnackbar("Error uploading image...");
    }
  }

  // Function to create a new group
  Future<void> _createGroup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Creating group..."),
            ],
          ),
        );
      },
    );

    try {
      final response = await GroupApis.createGroup(
        title: groupName.text.trim(),
        description: groupDescription.text.trim(),
        groupIcon: _uploadedImageUrl,
        adminApprove: adminApprove,
        createdBy: CurrentUser().UserId!,
        disappearingMsg: 0,
        memAdd: memAdd,
        memEdit: memEdit,
        memSend: memSend,
        members: widget.members
            .map((contact) => {
                  "user_id": contact.UserId,
                  "is_admin": false,
                })
            .toList(),
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 201) {
        print(response.body);
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        _dbHelper.addGroup(body['group']);
      } else {
        _showSnackbar("Failed to create group. Please try again later.");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnackbar("An error occurred: ${e.toString()}");
    }
  }

  // Function to show a snackbar message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New group'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _uploadedImageUrl != null
                    ? NetworkImage(_uploadedImageUrl!)
                    : uploadingImage
                        ? null
                        : const AssetImage('assets/images/default_profile.jpg'),
                child:
                    uploadingImage ? const CircularProgressIndicator() : null,
              ),
            ),
            title: Column(
              children: [
                TextField(
                  controller: groupName,
                  decoration:
                      const InputDecoration(hintText: 'Enter group name'),
                ),
                TextField(
                  controller: groupDescription,
                  decoration: const InputDecoration(
                      hintText: 'Enter group description'),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 10,
            color: Colors.grey.shade300,
          ),
          ListTile(
            trailing: const Icon(Icons.timelapse),
            title: const Text('Disappearing messages'),
            subtitle: Text(disappMsgSelection),
            onTap: () {
              showDisappMsgOptions(context);
            },
          ),
          ListTile(
            trailing: const Icon(Icons.settings),
            title: const Text('Group permissions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupPermissionsPage(
                    permissions: [memEdit, memSend, memAdd, adminApprove],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: const Icon(Icons.check),
      ),
    );
  }

  void showDisappMsgOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Disappearing messages'),
          content: StatefulBuilder(builder: (context, refresh) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'All new messages in the chat will disappear after the selected duration.',
                ),
                ...disappMsg.map(
                  (option) => RadioListTile<String>(
                    value: option,
                    groupValue: disappMsgSelection,
                    onChanged: (value) {
                      setState(() {
                        disappMsgSelection = value!;
                      });
                      refresh(() {});
                    },
                    title: Text(option),
                  ),
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
