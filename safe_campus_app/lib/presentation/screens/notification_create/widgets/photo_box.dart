import 'package:flutter/material.dart';
import 'package:safe_campus_app/core/constants/sizes/sizes.dart';

class PhotoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // Tıklama fonksiyonu

  const PhotoBox({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
      clipBehavior: Clip.hardEdge, // BU ÇOK ÖNEMLİ: Efektin dışa taşmasını engeller
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey, size: Sizes.iconSm),
              const SizedBox(height: Sizes.sm),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: Sizes.fontSizeSm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}