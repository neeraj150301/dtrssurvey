import 'dart:math';
import 'package:flutter/material.dart';

class StatusStamp extends StatelessWidget {
  final String text;
  final Color statusColor;

  const StatusStamp({
    super.key,
    this.text = "",
    this.statusColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -10 * pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),

          border: Border.all(color: statusColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: statusColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
