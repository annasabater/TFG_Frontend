// lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  static final _base = dotenv.env['SERVER_URL'] ?? 'http://localhost:9000/api';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService().token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Recupera les últimes 30 notificacions
  static Future<List<NotificationItem>> getNotifications() async {
    final res = await http.get(
      Uri.parse('$_base/notifications'),
      headers: await _headers(),
    );
    if (res.statusCode >= 400) throw Exception('Error ${res.statusCode}');
    final List body = jsonDecode(res.body);
    return body.map((j) => NotificationItem.fromJson(j)).toList();
  }

  /// Marca una notificació com a llegida
  static Future<void> markAsRead(String id) async {
    final res = await http.patch(
      Uri.parse('$_base/notifications/$id/read'),
      headers: await _headers(),
    );
    if (res.statusCode >= 400) throw Exception('Error ${res.statusCode}');
  }
}
