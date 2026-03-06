import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // You can override this at build/run time:
  // flutter run --dart-define=API_BASE_URL=http://<YOUR_IP>:5000
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    // Local development (web/desktop)
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:5000';
    }

    // Mobile defaults to device localhost (best when using `adb reverse tcp:5000 tcp:5000`).
    // For Android emulator use:
    //   --dart-define=API_BASE_URL=http://10.0.2.2:5000
    return 'http://127.0.0.1:5000';
  }

  // API endpoints
  static String get loginEndpoint => '${baseUrl}/api/user/login';
  static String get registerEndpoint => '${baseUrl}/api/user/register';
  static String get jobsEndpoint => '${baseUrl}/api/jobs/user';
  static String get accommodationEndpoint => '${baseUrl}/api/accommodation/user';
  static String get foodEndpoint => '${baseUrl}/api/user/foodgrocery';
  
  /// Get full image URL from relative path
  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    
    // If already a full URL, return as is
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    
    // Handle paths starting with /uploads
    if (relativePath.startsWith('/uploads')) {
      return '$baseUrl$relativePath';
    }
    
    // Handle paths starting with uploads (without leading slash)
    if (relativePath.startsWith('uploads')) {
      return '$baseUrl/$relativePath';
    }
    
    // Default: assume it's a relative path
    return '$baseUrl/uploads/$relativePath';
  }
}
