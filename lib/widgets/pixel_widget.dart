import 'package:flutter/material.dart';

class PixelWidget extends StatelessWidget {
  final Color? color;
  final String child;

  const PixelWidget({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color,
      ),
      child: Center(
        child: Text(
          child,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
