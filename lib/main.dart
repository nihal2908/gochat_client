import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/camera/camera_screen.dart';
import 'package:whatsapp_clone/services/notification_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  await CameraScreen.fetchCameras();
  runApp(const WhatsAppCloneApp());
}
