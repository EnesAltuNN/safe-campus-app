import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Tüm servislerin kullanacağı merkezi API adresi ve port ayarı.
/// Değerler `.env` dosyasından okunur (şablon: `.env.example`).
/// `.env` yoksa aşağıdaki varsayılanlar kullanılır.
class ApiConfig {
  static String get localIp => dotenv.env['API_HOST'] ?? '192.168.1.14';

  static int get port =>
      int.tryParse(dotenv.env['API_PORT'] ?? '') ?? 3000;

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://$localIp:$port';
}
