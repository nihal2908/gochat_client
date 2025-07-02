import 'package:flutter/material.dart';
import 'package:whatsapp_clone/app/app_life_handler.dart';
import 'package:whatsapp_clone/features/splash/splash_page.dart';

class LifecycleAwareApp extends StatefulWidget {
  const LifecycleAwareApp({super.key});

  @override
  _LifecycleAwareAppState createState() => _LifecycleAwareAppState();
}

class _LifecycleAwareAppState extends State<LifecycleAwareApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(AppLifecycleHandler());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(AppLifecycleHandler());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashPage();
  }
}