import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whatsapp_clone/secrets/secrets.dart';

class AuthApi {
  static Future<AuthResponse> login({
    required String password,
    required String phone,
    required String countryCode,
  }) async {
    final response = await http.post(
      Uri.parse('${Secrets.serverUrl}/login'),
      body: jsonEncode({
        'phone': phone,
        'country_code': countryCode,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse(success: true, message: response.body);
    } else {
      return AuthResponse(success: false, message: response.body);
    }
  }

  static Future<AuthResponse> send_otp(
      {required String phone, required String countryCode}) async {
    final response = await http.post(
      Uri.parse('${Secrets.serverUrl}/send_otp'),
      body: jsonEncode({
        'phone': phone,
        'country_code': countryCode,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse(success: true, message: response.body);
    } else {
      return AuthResponse(success: false, message: response.body);
    }
  }

  static Future<AuthResponse> verify_otp(
      {required String otp,
      required String phone,
      required String countryCode}) async {
    final response = await http.post(
      Uri.parse('${Secrets.serverUrl}/verify_otp'),
      body: jsonEncode({
        'phone': phone,
        'country_code': countryCode,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse(success: true, message: response.body);
    } else {
      return AuthResponse(success: false, message: response.body);
    }
  }

  static Future<AuthResponse> register({
    required String name,
    required String phone,
    required String countryCode,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${Secrets.serverUrl}/register'),
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'country_code': countryCode,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse(success: true);
    } else {
      return AuthResponse(success: false, message: response.body);
    }
  }

  static Future<AuthResponse> logout({
    required String phone,
    required String id,
    required String countryCode,
  }) async {
    final response = await http.post(
      Uri.parse('${Secrets.serverUrl}/logout'),
      body: jsonEncode({
        'phone': phone,
        '_id': id,
        'country_code': countryCode,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse(success: true);
    } else {
      return AuthResponse(success: false, message: response.body);
    }
  }
}

class AuthResponse {
  final bool success;
  final String message;

  AuthResponse({required this.success, this.message = ''});
}
