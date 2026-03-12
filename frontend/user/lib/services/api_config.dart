import 'package:flutter/foundation.dart' show kReleaseMode;

class ApiConfig {
  // Production backend (Render)
  static const String _prodBaseUrl = 'https://german-bharatham-backend.onrender.com';

  // Local backend for debug (physical device LAN IP)
  // To use local backend in debug: just run `flutter run` (no flag needed)
  // To override: flutter run --dart-define=API_BASE_URL=http://<IP>:5000
  static const String _devDefaultBaseUrl = 'http://10.142.60.147:5000';

  /// Base URL selection:
  /// - If --dart-define=API_BASE_URL=... is provided, that wins
  /// - Debug builds use local LAN backend
  /// - Release builds use Render production backend
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
  static String get settingsPublicEndpoint => '$baseUrl/api/admin/settings/public';
  static String get profileEndpoint => '$baseUrl/api/user/profile';
  
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