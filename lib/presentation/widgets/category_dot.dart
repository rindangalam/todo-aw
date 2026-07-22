import 'package:flutter/material.dart';

class CategoryDot extends StatelessWidget {
  final Color? color;
  final double size;

  const CategoryDot({
    super.key,
    this.color,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF9CA3AF),
        shape: BoxShape.circle,
      ),
    );
  }
}
