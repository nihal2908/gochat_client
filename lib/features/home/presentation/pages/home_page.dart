import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/database/db_helper.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/features/calls/webrtc_handler.dart';
import 'package:whatsapp_clone/features/camera/camera_page.dart';
import 'package:whatsapp_clone/features/chat/presentation/pages/chat_list_page.dart';
import 'package:whatsapp_clone/features/group/pages/group_list_page.dart';
import 'package:whatsapp_clone/features/home/presentation/widgets/popup_menu_widget.dart';
import 'package:whatsapp_clone/features/splash/landing_page.dart';
import 'package:whatsapp_clone/features/status/presentation/pages/status_page.dart';
import 'package:whatsapp_clone/features/testing/testing_page.dart';
import 'package:whatsapp_clone/providers/websocket_provider.dart';
import 'package:whatsapp_clone/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = [
    const ChatListPage(),
    const GroupListPage(),
    TestFunctionPage(),
    CameraPage(),
    StatusPage(),
    LandingPage(),
  ];
  final PageController pageController = PageController(initialPage: 0);
  final ValueNotifier<int> currentPageIndex = ValueNotifier<int>(0);
  late final DBHelper _dbHelper;
  final _webrtcHandler = WebRTCHandler();

  @override
  void initState() {
    super.initState();
    final webSocketProvider =
        Provider.of<WebSocketProvider>(context, listen: false);
    webSocketProvider.initialize(CurrentUser.userId!);
    _dbHelper = DBHelper();
    _webrtcHandler.init(
      context,
      self: CurrentUser().UserId!,
      websocket: webSocketProvider.webSocketService,
      dbHelper: _dbHelper,
    );
    webSocketProvider.webSocketService.setWebRTCHandler(_webrtcHandler);
    NotificationService.instance.initialize();
  }

  @override
  void dispose() {
    _dbHelper.updateStream.drain();
    currentPageIndex.dispose();
    super.dispose();
  }

  void onNavigationTap(int value) {
    pageController.jumpToPage(value);
  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<bool>(
      valueListenable: _webrtcHandler.isInCall,
      builder: (
        context,
        inInCall,
        Widget? child,
      ) =>
          Scaffold(
        appBar: inInCall
            ? AppBar(
                centerTitle: true,
                title: Text(
                  "${_webrtcHandler.isCaller ? _webrtcHandler.receiver!.Title : _webrtcHandler.caller!.Title} - ${_webrtcHandler.isCallAccepted.value ? _webrtcHandler.callDuration.value.toString() : _webrtcHandler.callStatus.value}",
                  // style: TextStyle(color: Colors.white),
                ),
                // backgroundColor: Colors.black,
                leading: IconButton(
                  icon: Icon(
                      _webrtcHandler.isMuted.value ? Icons.mic_off : Icons.mic),
                  onPressed: () {
                    _webrtcHandler.toggleMuteAudio();
                  },
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _webrtcHandler.isMuted.value
                          ? Icons.volume_off
                          : Icons.volume_up,
                    ),
                    onPressed: () {
                      _webrtcHandler.toggleSpeaker();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end),
                    onPressed: () {
                      _webrtcHandler.hangUp();
                    },
                  ),
                ],
              )
            : null,
        body: Scaffold(
          appBar: AppBar(
            title: const Text("Whatsapp"),
            actions: [CustomPopupMenuButton()],
          ),
          body: PageView(
            controller: pageController,
            children: pages,
            onPageChanged: (value) {
              currentPageIndex.value = value;
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<int>(
            valueListenable: currentPageIndex,
            builder: (context, index, _) {
              return BottomNavigationBar(
                onTap: onNavigationTap,
                currentIndex: index,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.blue,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined),
                    activeIcon: Icon(Icons.message),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.groups_outlined),
                    activeIcon: Icon(Icons.groups),
                    label: 'Groups',
                  ),
                  // BottomNavigationBarItem(
                  //   icon: Icon(Icons.phone_outlined),
                  //   activeIcon: Icon(Icons.phone),
                  //   label: 'Calls',
                  // ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Testing',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera_alt_outlined),
                    activeIcon: Icon(Icons.camera_alt),
                    label: 'Camera',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.image_outlined),
                    activeIcon: Icon(Icons.image),
                    label: 'Status',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera_alt_outlined),
                    activeIcon: Icon(Icons.camera_alt),
                    label: 'Landing',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
