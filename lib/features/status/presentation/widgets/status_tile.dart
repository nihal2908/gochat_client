// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';

class StatusTile extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final String time;
  final int seenCount;
  final int totalCount;

  const StatusTile({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.time,
    required this.totalCount,
    required this.seenCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomPaint(
        painter: StatusPainter(
          seenCount: seenCount,
          totalCount: totalCount,
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/default_profile.jpg'),
        ),
      ),
      title: Text(
        userName,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        time,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 14,
        ),
      ),
      onTap: () {},
    );
  }
}

class StatusPainter extends CustomPainter {
  int totalCount;
  int seenCount;
  StatusPainter({
    required this.totalCount,
    required this.seenCount,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Paint seenPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 6.0
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    final Paint unSeenPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 6.0
      ..color = Colors.green
      ..style = PaintingStyle.stroke;

    drawArc(
      canvas,
      size,
      seenPaint,
      unSeenPaint,
      totalCount,
      seenCount,
    );
  }

  void drawArc(
    Canvas canvas,
    Size size,
    Paint seenPaint,
    Paint unSeenPaint,
    int totalCount,
    int seenCount,
  ) {
    if (totalCount == 1) {
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        degreeToRadian(0),
        degreeToRadian(360),
        false,
        seenCount == 1 ? seenPaint : unSeenPaint,
      );
      return;
    }
    int i = 0;
    double baseAngle = -90;
    double arcAngle = 360 / totalCount;
    for (; i < seenCount; i++) {
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        degreeToRadian(baseAngle + 5 + i * arcAngle),
        degreeToRadian(arcAngle - 5),
        false,
        seenPaint,
      );
    }
    for (; i < totalCount; i++) {
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        degreeToRadian(baseAngle + 5 + i * arcAngle),
        degreeToRadian(arcAngle - 5),
        false,
        unSeenPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadian(double degree) {
    return degree * pi / 180;
  }
}
