import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: Sizes.fontSizeXsm,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}