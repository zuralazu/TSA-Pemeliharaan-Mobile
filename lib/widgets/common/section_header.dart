import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final double fontSize;

  const SectionHeader({
    Key? key,
    required this.title,
    this.accentColor = AppColors.primary,
    this.fontSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
