import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  String? _profilePictureUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8080/uploadProfilePicture'),
    );
    request.fields['username'] = widget.userId;
    request.files.add(await http.MultipartFile.fromPath('picture', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);
      setState(() {
        _profilePictureUrl = responseData['url'];
      });
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _profilePictureUrl != null
                ? NetworkImage('http://localhost:8080$_profilePictureUrl')
                : null,
            child: _profilePictureUrl == null
                ? Icon(Icons.person, size: 50)
                : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Change Profile Picture'),
          ),
        ],
      ),
    );
  }
}
