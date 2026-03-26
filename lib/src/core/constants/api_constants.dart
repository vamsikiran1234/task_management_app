import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const Duration requestTimeout = Duration(seconds: 10);

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    // Android emulator maps host loopback to 10.0.2.2.
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  const ApiConstants._();
}
