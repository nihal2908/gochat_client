import 'package:flutter/material.dart';

class FloatingCallWidget extends StatefulWidget {
  const FloatingCallWidget({super.key});

  @override
  State<FloatingCallWidget> createState() => _FloatingCallWidgetState();
}

class _FloatingCallWidgetState extends State<FloatingCallWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Floating Box',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
