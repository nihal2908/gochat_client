import 'package:flutter/material.dart';

class AppLifecycleHandler with WidgetsBindingObserver {
  static bool isAppInBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isAppInBackground = false;
    } else if (state == AppLifecycleState.paused) {
      isAppInBackground = true;
    }
  }
}
