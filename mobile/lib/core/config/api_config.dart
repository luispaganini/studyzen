import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _fromEnvironment = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnvironment.isNotEmpty) return _fromEnvironment;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }
}
