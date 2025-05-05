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
    _loadToken(); // intenta cargar token al arrancar
  }

  bool isLoggedIn = false;
  Map<String, dynamic>? currentUser;
  String? _jwt;

  /// Guarda el token en SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
  }

  /// Carga el token de SharedPreferences si no está en memoria
  Future<String?> _loadToken() async {
    if (_jwt != null) return _jwt;
    final prefs = await SharedPreferences.getInstance();
    _jwt = prefs.getString('jwt');
    isLoggedIn = _jwt != null;
    return _jwt;
  }

  /// Acceso al JWT guardado tras login/signup
  Future<String> get token async {
    final t = await _loadToken();
    if (t == null) throw Exception('JWT no disponible. Haz login primero.');
    return t;
  }

  /// Base URL de la API según la plataforma
  String get _baseApiUrl {
    if (kIsWeb) return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  /// ENDPOINTS ajustados a /api/auth para login y signup
  String get _loginUrl  => '$_baseApiUrl/auth/login';
  String get _signupUrl => '$_baseApiUrl/auth/signup';
  String get _userUrl   => '$_baseApiUrl/users';

  /// Hace login y guarda currentUser + JWT
  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final userData = body.containsKey('user')
          ? body['user'] as Map<String, dynamic>
          : body;
      currentUser = userData;
      _jwt = body['token'] as String?;
      if (_jwt != null) await _saveToken(_jwt!);
      isLoggedIn = true;
      return {'user': userData};
    } else {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Email o contraseña incorrectos'};
    }
  }

  /// Hace signup y guarda currentUser + JWT
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
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final userData = body.containsKey('user')
          ? body['user'] as Map<String, dynamic>
          : body;
      currentUser = userData;
      _jwt = body['token'] as String?;
      if (_jwt != null) await _saveToken(_jwt!);
      isLoggedIn = true;
      return {'user': userData};
    } else {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Error en registro'};
    }
  }

  /// Obtiene un usuario por ID (requiere JWT)
  Future<Map<String, dynamic>> getUserById(String id) async {
    final token = await _loadToken();
    final resp = await http.get(
      Uri.parse('$_userUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final userData = body.containsKey('user')
          ? body['user'] as Map<String, dynamic>
          : body;
      currentUser = userData;
      return userData;
    } else {
      return {'error': 'No se pudo cargar el usuario'};
    }
  }

  /// Actualiza perfil (requiere JWT)
  Future<Map<String, dynamic>> updateProfile({
    required String userName,
    required String email,
    String? password,
    String? role,
  }) async {
    if (currentUser == null || currentUser!['_id'] == null) {
      return {'error': 'No hay usuario autenticado'};
    }
    final id = currentUser!['_id'] as String;
    final token = await _loadToken();
    final bodyData = {
      'userName': userName,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (role != null) 'role': role,
    };
    final resp = await http.put(
      Uri.parse('$_userUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyData),
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final updated = body.containsKey('user')
          ? body['user'] as Map<String, dynamic>
          : body;
      currentUser = {...?currentUser, ...updated};
      return updated;
    } else {
      return {'error': 'Error al actualizar perfil'};
    }
  }

  /// Elimina cuenta (requiere JWT)
  Future<Map<String, dynamic>> deleteUserById(String id) async {
    final token = await _loadToken();
    final resp = await http.delete(
      Uri.parse('$_userUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      return {'success': true};
    } else {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Error al eliminar usuario'};
    }
  }

  /// Logout local
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    isLoggedIn = false;
    currentUser = null;
    _jwt = null;
  }
}
