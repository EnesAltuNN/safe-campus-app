/// Uygulama genelinde kullanılacak UI sabitleri ve temaları
import 'package:flutter/material.dart';

class AppUI {
  // Renkler
  static const Color primaryColor = Colors.deepPurple;
  static const Color dangerColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color cardColor = Colors.white;
  static const Color textColor = Colors.black87;

  // Padding, BorderRadius, vb.
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;

  // Text stilleri
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
  );
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const TextStyle alertTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: dangerColor,
  );

  // Diğer UI sabitleri buraya eklenebilir
}
