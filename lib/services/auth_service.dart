// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _loadToken();
  }

  bool isLoggedIn = false;
  Map<String, dynamic>? currentUser;
  String? _jwt;

  /// Guarda el token en SharedPreferences y en memoria.
  Future<bool> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', token);
      _jwt = token;
      isLoggedIn = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Carga el token si no está en memoria.
  Future<void> _loadToken() async {
    if (_jwt != null) return;
    final prefs = await SharedPreferences.getInstance();
    _jwt = prefs.getString('jwt');
    isLoggedIn = _jwt != null;
  }

  /// Devuelve el JWT o lanza si no existe.
  Future<String> get token async {
    await _loadToken();
    if (_jwt == null || _jwt!.isEmpty) {
      throw Exception('JWT no disponible. Haz login primero.');
    }
    return _jwt!;
  }

  /// URL base REST (incluye '/api').
  String get baseApiUrl {
    if (kIsWeb) return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  /// URL base para WebSockets (sin '/api').
  String get webSocketBaseUrl => baseApiUrl.replaceAll('/api', '');

  String get _loginUrl => '$baseApiUrl/auth/login';
  String get _signupUrl => '$baseApiUrl/auth/register';
  String get _userUrl => '$baseApiUrl/users';

  /// Login: guarda currentUser + JWT.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode != 200) {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Email o contraseña incorrectos'};
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final tokenStr = body['accesstoken'] as String?;
    if (tokenStr == null) return {'error': 'No se recibió token del servidor'};
    final userData = (body['user'] as Map<String, dynamic>?) ?? {};
    currentUser = userData;
    final ok = await _saveToken(tokenStr);
    if (!ok) return {'error': 'No se pudo guardar el token localmente'};
    return {'user': userData};
  }

  /// Registro: devuelve user (sin token).
  Future<Map<String, dynamic>> signup({
    required String userName,
    required String email,
    required String password,
    String role = 'Usuario',
  }) async {
    final resp = await http.post(
      Uri.parse(_signupUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': userName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Error en registro'};
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final userData = (body['user'] as Map<String, dynamic>?) ?? {};
    currentUser = userData;
    return {'user': userData};
  }

  /// Obtener usuario por ID.
  Future<Map<String, dynamic>> getUserById(String id) async {
    final jwt = await token;
    final resp = await http.get(
      Uri.parse('$_userUrl/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $jwt'},
    );
    if (resp.statusCode != 200) return {'error': 'No se pudo cargar el usuario'};
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final userData = (body['user'] as Map<String, dynamic>?) ?? body;
    currentUser = userData;
    return userData;
  }

  /// Actualizar perfil.
  Future<Map<String, dynamic>> updateProfile({
    required String userName,
    required String email,
    String? password,
    String? role,
  }) async {
    if (currentUser?['_id'] == null) return {'error': 'No hay usuario autenticado'};
    final id = currentUser!['_id'] as String;
    final jwt = await token;
    final bodyData = {
      'userName': userName,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (role != null) 'role': role,
    };
    final resp = await http.put(
      Uri.parse('$_userUrl/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $jwt'},
      body: jsonEncode(bodyData),
    );
    if (resp.statusCode != 200) return {'error': 'Error al actualizar perfil'};
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final updated = (body['user'] as Map<String, dynamic>?) ?? body;
    currentUser = {...?currentUser, ...updated};
    return updated;
  }

  /// Eliminar usuario.
  Future<Map<String, dynamic>> deleteUserById(String id) async {
    final jwt = await token;
    final resp = await http.delete(
      Uri.parse('$_userUrl/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $jwt'},
    );
    if (resp.statusCode != 200) {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Error al eliminar usuario'};
    }
    return {'success': true};
  }

  /// Logout local.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    isLoggedIn = false;
    currentUser = null;
    _jwt = null;
  }
}