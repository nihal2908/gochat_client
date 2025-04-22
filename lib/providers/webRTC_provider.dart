import 'package:flutter/material.dart';

class WebrtcProvider with ChangeNotifier {
  bool isInOngoingCall = false;
  bool isMute = false;
  bool isSpeaker = false;
  bool isIncomingCall = false;
  bool get isInCall => isInOngoingCall;

  void handleIncomingCall() {
    isIncomingCall = true;
    notifyListeners();
  }

  void handleOutgoingCall() {
    isIncomingCall = false;
    notifyListeners();
  }

  void endCall() {
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

  void acceptCall() {
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
