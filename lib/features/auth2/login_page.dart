import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginPage2 extends StatefulWidget {
  const LoginPage2({super.key});

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Enter your phone number'),
        titleTextStyle: TextStyle(
          color: Colors.teal,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          wordSpacing: 1,
        ),
        elevation: 0,
        actions: [
          Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text(
              'WhatsApp will send an SMS message to verify your number',
              style: TextStyle(
                fontSize: 13.5,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "What's my number?",
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 12.8,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: IntlPhoneField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                languageCode: "en",
                showCountryFlag: false,
                pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: Colors.white,
                  listTilePadding: EdgeInsets.all(0),
                  countryNameStyle: TextStyle(),
                ),
                dropdownIconPosition: IconPosition.trailing,
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  print(phone.completeNumber);
                },
                onCountryChanged: (country) {
                  print('Country changed to: ' + country.name);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget countryCard() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width / 1.5,
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.teal,
            width: 1.8,
          ),
        ),
      ),
      child: Row(
        children: [
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            languageCode: "en",
            onChanged: (phone) {
              print(phone.completeNumber);
            },
            onCountryChanged: (country) {
              print('Country changed to: ' + country.name);
            },
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.teal,
            size: 28,
          ),
        ],
      ),
    );
  }
}
