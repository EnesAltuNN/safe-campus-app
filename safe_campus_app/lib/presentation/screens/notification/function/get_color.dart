import 'package:flutter/material.dart';

Color getColor(String status) {
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