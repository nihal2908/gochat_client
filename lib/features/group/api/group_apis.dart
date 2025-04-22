import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whatsapp_clone/secrets/secrets.dart';

class GroupApis {
  static String baseUrl =
      '${Secrets.serverUrl}/groups';
  static String mediaUrl =
      '${Secrets.serverUrl}/media';

  static Future<http.Response> createGroup({
    required String title,
    required String? description,
    required String? groupIcon,
    required String createdBy,
    required int disappearingMsg,
    required bool memEdit,
    required bool memSend,
    required bool memAdd,
    required bool adminApprove,
    required List<Map<String, dynamic>> members,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/create-group'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": title,
        "description": description,
        "group_icon": groupIcon,
        "created_by": createdBy,
        "member_can_edit": memEdit,
        "member_can_send": memSend,
        "member_can_add": memAdd,
        "admin_approve": adminApprove,
        "disappearing_msg": disappearingMsg,
        "members": members,
      }),
    );
  }

  static Future<http.Response> deleteGroup(
      String groupId, String userId) async {
    return await http.delete(
      Uri.parse('$baseUrl/delete-group?group_id=$groupId&user_id=$userId'),
    );
  }

  static Future<http.Response> joinGroup(String groupId, String userId) async {
    return await http.post(
      Uri.parse('$baseUrl/join-group/$groupId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"user_id": userId}),
    );
  }

  static Future<http.Response> leaveGroup(String groupId, String userId) async {
    return await http.delete(
      Uri.parse('$baseUrl/leave-group?group_id=$groupId&user_id=$userId'),
    );
  }

  static Future<http.Response> updateGroup(
      String groupId, Map<String, dynamic> updates) async {
    return await http.put(
      Uri.parse('$baseUrl/update-group/$groupId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
  }

  static Future<http.Response> getGroupData(String groupId) async {
    return await http.get(
      Uri.parse('$baseUrl/get-group-data/$groupId'),
    );
  }

  static Future<http.Response> uploadImage(String imagePath) async {
    var request =
        http.MultipartRequest("POST", Uri.parse('$mediaUrl/upload-image'));
    request.files.add(await http.MultipartFile.fromPath("image", imagePath));
    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  static Future<http.Response> getImage(String imageId) async {
    return await http.get(
      Uri.parse('$mediaUrl/image/$imageId'),
    );
  }
}
