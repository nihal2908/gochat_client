import 'package:flutter/material.dart';
import 'package:whatsapp_clone/services/contact_services.dart';

class ContactProvider with ChangeNotifier {
  void refreshContacts() async {
    await ContactServices.fetchAndSendContacts();
    notifyListeners();
  }

  void getContacts() {
    // This is a placeholder for fetching contacts from a database or API
    // For now, we'll just return the current list of contacts
    notifyListeners();
  }
}
