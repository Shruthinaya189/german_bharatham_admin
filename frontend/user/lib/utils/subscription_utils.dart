import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';
import '../user_session.dart';

/// Utility to check if the user's subscription is expired.
/// Returns true if expired, false if active, null if unknown.
Future<bool?> isSubscriptionExpired() async {
  final session = UserSession.instance;
  final token = session.token;
  if (token == null) return null;
  try {
    final statusRes = await http.get(
      Uri.parse(ApiConfig.subscriptionStatusEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (statusRes.statusCode != 200) return null;
    final statusJson = jsonDecode(statusRes.body);
    final user = statusJson['user'];
    if (user is Map && user['subscriptionExpiresAt'] != null) {
      final expiresAt = DateTime.tryParse(user['subscriptionExpiresAt'].toString());
      if (expiresAt == null) return null;
      return DateTime.now().isAfter(expiresAt);
    }
    return null;
  } catch (_) {
    return null;
  }
}
