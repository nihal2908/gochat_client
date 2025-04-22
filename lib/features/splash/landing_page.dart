import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/auth2/login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              'Welcome to WhatsApp',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 29,
                  color: Colors.teal),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 8,
            ),
            Image.asset(
              'assets/images/bg.png',
              color: Colors.greenAccent.shade700,
              height: 340,
              width: 340,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 8.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Agree and Continue to accept the WhatsApp ',
                    ),
                    TextSpan(
                      text: 'Terms of Service ',
                      style: TextStyle(
                        color: Colors.cyan,
                      ),
                    ),
                    TextSpan(
                      text: 'and ',
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage2(),
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 110,
                height: 50,
                child: Card(
                  margin: EdgeInsets.all(0),
                  elevation: 8,
                  color: Colors.greenAccent.shade700,
                  child: Center(
                    child: Text(
                      'AGREE AND CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
