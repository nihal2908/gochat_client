import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/app/life_cycle_aware_app.dart';
import 'package:whatsapp_clone/features/chat/provider/chat_provider.dart';
import 'package:whatsapp_clone/providers/contact_provider.dart';
import 'package:whatsapp_clone/providers/media_state_provider.dart';
import 'package:whatsapp_clone/providers/websocket_provider.dart';

class WhatsAppCloneApp extends StatelessWidget {
  const WhatsAppCloneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ContactProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WebSocketProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatState(),
        ),
        ChangeNotifierProvider(
          create: (_) => MediaController(),
        ),
      ],
      child: MaterialApp(
        title: 'WhatsApp Clone',
        // theme: AppTheme.lightTheme,
        theme: ThemeData(primarySwatch: Colors.green),
        home: LifecycleAwareApp(),
        // home: SplashPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
