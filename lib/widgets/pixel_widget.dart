import 'package:flutter/material.dart';

class PixelWidget extends StatelessWidget {
  final Color? color;

  const PixelWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color,
      ),
    );
  }
}
