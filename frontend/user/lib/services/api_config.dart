import 'package:flutter/foundation.dart' show kReleaseMode;

class ApiConfig {
  // Production backend (Render)
  static const String _prodBaseUrl = 'https://german-bharatham-backend.onrender.com';

  // Local backend (use Android emulator loopback by default in debug)
  // - Android emulator: http://10.0.2.2:5000
  // - iOS simulator: http://127.0.0.1:5000
  // - Physical device: http://<YOUR_PC_LAN_IP>:5000
  static const String _devDefaultBaseUrl = 'http://10.0.2.2:5000';

  /// Base URL selection:
  /// - If provided: `--dart-define=API_BASE_URL=...` wins
  /// - Else: release uses Render; debug uses local dev default
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.trim().isNotEmpty) return override.trim();
    return kReleaseMode ? _prodBaseUrl : _devDefaultBaseUrl;
  }
  
  // API endpoints
  static String get loginEndpoint => '$baseUrl/api/user/login';
  static String get registerEndpoint => '$baseUrl/api/user/register';
  static String get jobsEndpoint => '$baseUrl/api/jobs/user';
  static String get accommodationEndpoint => '$baseUrl/api/accommodation/user';
  static String get foodEndpoint => '$baseUrl/api/user/foodgrocery';
  
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