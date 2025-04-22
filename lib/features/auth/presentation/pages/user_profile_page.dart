import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/models/user.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final dbHelper = DBHelper();
    final user = await dbHelper.getUserById(widget.userId);
    setState(() {
      _user = user != null ? User.fromMap(user) : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !_isLoading
          ? AppBar(
              title: _user != null ? Text(_user!.Title) : null,
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(child: Text('No user profile found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _user!.ProfilePictureUrl != null
                            ? CachedNetworkImageProvider(
                                _user!.ProfilePictureUrl!)
                            : AssetImage('assets/images/default_profile.jpg'),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _user!.Title,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _user!.StatusMessage,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Phone: ${_user!.Phone}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
