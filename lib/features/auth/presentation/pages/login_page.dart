import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/api/auth_api.dart';
import 'package:whatsapp_clone/features/auth/presentation/pages/siginup_page.dart';
import 'package:whatsapp_clone/features/auth/presentation/widgets/auth_button.dart';
import 'package:whatsapp_clone/features/auth/presentation/widgets/text_input_field.dart';
import 'package:whatsapp_clone/features/splash/splash_page.dart';
import 'package:whatsapp_clone/statics/static_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  void _login() async {
    Statics.showLoadingMessage(message: 'Loading...', context: context);

    final response = await AuthApi.login(
      phone: _phoneController.text,
      countryCode: '+91',
      password: _passwordController.text,
    );

    if (response.success) {
      print(response.message);
      final data = jsonDecode(response.message) as Map<String, dynamic>;
      final username = data['user']['name'];
      final phone = data['user']['phone'];
      final userId = data['user']['_id'];
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("USERNAME", username.toString());
      prefs.setString("PHONE", phone.toString());
      prefs.setString("USERID", userId.toString());

      _dbHelper.saveCurrentUser(data);
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SplashPage(),
        ),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
      Statics.showTextSnackBar(context: context, text: response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntlPhoneField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'IN',
              controller: _phoneController,
            ),
            const SizedBox(height: 16),
            TextInputField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            AuthButton(
              text: 'Login',
              onPressed: _login,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupPage(),
                  ),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
