import 'package:flutter/material.dart';

IconData getIcon(int categoryId) {
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