import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/features/auth/api/auth_api.dart';
import 'package:whatsapp_clone/features/auth/presentation/pages/login_page.dart';
import 'package:whatsapp_clone/features/auth/presentation/widgets/auth_button.dart';
import 'package:whatsapp_clone/features/auth/presentation/widgets/text_input_field.dart';
import 'package:whatsapp_clone/features/splash/splash_page.dart';
import 'package:whatsapp_clone/utils/utils.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signup() async {
    showLoadingMessage(message: "Loading...", context: context);

    final response = await AuthApi.register(
      password: _passwordController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      countryCode: '+91',
    );
    if (response.success) {
      print(response.message);
      final data = jsonDecode(response.message);
      final username = data['user']['name'];
      final phone = data['user']['phone'];
      final userId = data['user']['_id'];
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("USERNAME", username.toString());
      prefs.setString("PHONE", phone.toString());
      prefs.setString("USERID", userId.toString());
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
      showTextSnackBar(context: context, text: response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextInputField(
              controller: _nameController,
              hintText: 'Display name',
            ),
            const SizedBox(height: 20),
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
              text: 'Sign Up',
              onPressed: _signup,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
