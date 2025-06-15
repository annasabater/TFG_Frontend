// lib/services/session_service.dartÇ
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class SessionService {
  static const _storage = FlutterSecureStorage();

  String get _baseApiUrl {
    if (kIsWeb) return dotenv.env['SERVER_URL'] ?? 'http://localhost:9000/api';
    if (Platform.isAndroid) return dotenv.env['SERVER_URL'] ?? 'http://10.0.2.2:9000/api';
    return dotenv.env['SERVER_URL'] ?? 'http://localhost:9000/api';
  }

  Map<String,String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  /// Obtiene sesiones estado WAITING
  Future<List<dynamic>> fetchOpenSessions() async {
    final token = await _storage.read(key: 'jwtToken');
    final resp = await http.get(
      Uri.parse('$_baseApiUrl/sessions/open'),
      headers: _headers(token),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    } else {
      throw Exception('No se pudieron cargar sesiones');
    }
  }
}
