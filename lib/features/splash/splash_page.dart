import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/auth/presentation/pages/login_page.dart';
import 'package:whatsapp_clone/features/home/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    final delay = Future.delayed(const Duration(seconds: 2));

    final futurePage = _checkNextPage();

    final results = await Future.wait([delay, futurePage]);
    final nextPage = results[1] as String;

    if (nextPage == 'home_page') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  Future<String> _checkNextPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('USERNAME');
    String? userid = prefs.getString('USERID');
    String? phone = prefs.getString('PHONE');

    if (username != null && phone != null && userid != null) {
      CurrentUser.userId = userid;
      return 'home_page';
    } else {
      return 'login_page';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          height: MediaQuery.of(context).size.width * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
    );
  }
}
