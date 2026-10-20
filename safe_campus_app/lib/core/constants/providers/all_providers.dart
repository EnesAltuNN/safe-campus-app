import 'package:flutter_riverpod/legacy.dart';

class AppProviders {
  static final StateProvider<int> notificationFilterProvider =
      StateProvider<int>((ref) => 0);
}
