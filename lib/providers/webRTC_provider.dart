import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/calls/incoming_call_page.dart';
import 'package:whatsapp_clone/models/user.dart';

class WebrtcProvider with ChangeNotifier {
  bool isInOngoingCall = false;
  bool isMute = false;
  bool isSpeaker = false;
  bool isIncomingCall = false;
  bool videoCall = false;
  User? callerUser;
  User? receiverUser;

  late final BuildContext context;

  bool get isInCall => isInOngoingCall;
  bool get isVideoCall => videoCall;
  bool get caller => callerUser != null;
  bool get receiver => receiverUser != null;

  void initialize(BuildContext context) {
    context = context;
  }

  void handleIncomingCall(Map<String, dynamic> call, User caller) {
    callerUser = caller;
    isIncomingCall = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingCallPage(
          incomingCall: call,
          caller: caller,
        ),
      ),
    );
    isIncomingCall = true;
    notifyListeners();
  }

  void handleOutgoingCall() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const OutgoingCallPage(),
    //   ),
    // );
    isIncomingCall = false;
    notifyListeners();
  }

  Future<void> endCall() async {
    isInOngoingCall = false;
    notifyListeners();
  }

  void startCall() {
    isInOngoingCall = true;
    notifyListeners();
  }

  void toggleMute() {
    isMute = !isMute;
    notifyListeners();
  }

  void toggleSpeaker() {
    isSpeaker = !isSpeaker;
    notifyListeners();
  }

  Future<void> acceptCall() async {
    isIncomingCall = false;
    isInOngoingCall = true;
    notifyListeners();
  }

  void rejectCall() {
    isIncomingCall = false;
    notifyListeners();
  }

  void callAnswered() {
    isInOngoingCall = true;
    notifyListeners();
  }

  void callEnded() {
    isInOngoingCall = false;
    notifyListeners();
  }

  void callMissed() {
    isIncomingCall = false;
    notifyListeners();
  }
}
