// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool isLoggedIn = false;
  Map<String, dynamic>? currentUser;
  String? _jwt;

  /// Acceso al JWT guardado tras login/signup
  String get token {
    if (_jwt == null) throw Exception('JWT no disponible. Haz login primero.');
    return _jwt!;
  }

  /// Base URL de la API según la plataforma
  String get _baseApiUrl {
    if (kIsWeb) return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  /// ENDPOINTS ajustados a /api/auth 
  String get _loginUrl  => '$_baseApiUrl/auth/login';
  String get _signupUrl => '$_baseApiUrl/auth/signup';
  String get _userUrl   => '$_baseApiUrl/users';  

  /// Hace login y guarda _jwt + currentUser
  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse(_loginUrl),  // antes: /users/login
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      currentUser = data['user'] as Map<String, dynamic>?;
      _jwt = data['token'] as String?;
      isLoggedIn = true;
      return {'user': currentUser!};
    } else {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Email o contraseña incorrectos'};
    }
  }

  /// Hace signup y guarda _jwt + currentUser
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
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      currentUser = data['user'] as Map<String, dynamic>?;
      _jwt = data['token'] as String?;
      isLoggedIn = true;
      return {'user': currentUser!};
    } else {
      final err = jsonDecode(resp.body) as Map<String, dynamic>;
      return {'error': err['message'] ?? 'Error en registro'};
    }
  }

  /// Obtiene un usuario por ID (requiere JWT)
  Future<Map<String, dynamic>> getUserById(String id) async {
    final resp = await http.get(
      Uri.parse('$_userUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (_jwt != null) 'Authorization': 'Bearer $_jwt',
      },
    );
    if (resp.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      currentUser = data;
      return data;
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
    final body = {
      'userName': userName,
      'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (role != null) 'role': role,
    };
    final resp = await http.put(
      Uri.parse('$_userUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwt',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(resp.body) as Map<String, dynamic>;
      currentUser = {...currentUser!, ...data};
      return data;
    } else {
      return {'error': 'Error al actualizar perfil'};
    }
  }

  /// Elimina cuenta (requiere JWT)
  Future<Map<String, dynamic>> deleteUserById(String id) async {
    final resp = await http.delete(
      Uri.parse('$_userUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (_jwt != null) 'Authorization': 'Bearer $_jwt',
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
  void logout() {
    isLoggedIn = false;
    currentUser = null;
    _jwt = null;
  }
}
