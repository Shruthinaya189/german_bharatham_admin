class ApiConfig {
  // Physical Android device over USB uses adb reverse -> localhost.
  static const String baseUrl = 'http://127.0.0.1:5000';
  
  // API endpoints
  static const String loginEndpoint = '$baseUrl/api/user/login';
  static const String registerEndpoint = '$baseUrl/api/user/register';
  static const String jobsEndpoint = '$baseUrl/api/jobs';
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
