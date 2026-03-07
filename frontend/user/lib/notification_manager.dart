import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'services/api_config.dart';
import 'user_session.dart';

class NotificationManager {
  NotificationManager._();
  static final NotificationManager instance = NotificationManager._();

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<void> refresh() async {
    try {
      final token = UserSession.instance.token;
      if (token == null || token.trim().isEmpty) {
        unreadCount.value = 0;
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        // If server fails, don't show dot (avoid confusing UX)
        unreadCount.value = 0;
        return;
      }

      final decoded = jsonDecode(response.body);
      final list = decoded is List ? decoded : (decoded['data'] ?? []) as List;

      int unread = 0;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          if ((item['read'] ?? false) != true) unread++;
        }
      }

      unreadCount.value = unread;
    } catch (_) {
      unreadCount.value = 0;
    }
  }
}
