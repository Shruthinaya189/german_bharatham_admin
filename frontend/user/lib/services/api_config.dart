class ApiConfig {
  // Override at build/run time:
  //   flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_IPV4>:5000
  //
  // Defaults:
  // - Android emulator can reach your PC via 10.0.2.2
  // - Physical phone must use your PC's LAN IP (same Wi‑Fi) OR use `adb reverse`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.166.137.12:5000',
  );
  
  // API endpoints
  static const String loginEndpoint = '$baseUrl/api/user/login';
  static const String registerEndpoint = '$baseUrl/api/user/register';
  static const String jobsEndpoint = '$baseUrl/api/jobs/user';
  static const String accommodationEndpoint = '$baseUrl/api/accommodation/user';
  static const String foodEndpoint = '$baseUrl/api/user/foodgrocery';
  
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