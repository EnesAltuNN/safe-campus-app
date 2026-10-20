import 'package:flutter/material.dart';

class HelperFunctions {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF162620), // Input arka planı
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00E676), width: 1),
      ),
    );
  }

  static Color getColorWithStatus(String status) {
    switch (status) {
      case "Açık":
        return Colors.red;
      case "İnceleniyor":
        return Colors.yellow;
      case "Çözüldü":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static IconData getIconStatus(String status) {
    switch (status) {
      case "Açık":
        return Icons.lock_open;
      case "İnceleniyor":
        return Icons.hourglass_empty;
      case "Çözüldü":
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  static IconData getIconWithCategoryID(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.warning_amber_rounded;
      case 2:
        return Icons.security_rounded;
      case 3:
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }
}
