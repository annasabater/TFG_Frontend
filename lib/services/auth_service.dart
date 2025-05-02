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

  String get _baseApiUrl {
    if (kIsWeb) return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  String get _loginUrl  => '$_baseApiUrl/users/login';
  String get _signupUrl => '$_baseApiUrl/users/signup';
  String get _userUrl   => '$_baseApiUrl/users';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse(_loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      currentUser = data['user'] as Map<String, dynamic>?;
      isLoggedIn = true;
      return {'user': currentUser};
    } else {
      final err = jsonDecode(resp.body);
      return {'error': err['message'] ?? 'Email o contraseña incorrectos'};
    }
  }

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
      final data = jsonDecode(resp.body);
      currentUser = data['user'] as Map<String, dynamic>?;
      isLoggedIn = true;
      return {'user': currentUser};
    } else {
      final err = jsonDecode(resp.body);
      return {'error': err['message'] ?? 'Error en registro'};
    }
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    final resp = await http.get(
      Uri.parse('$_userUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      currentUser = data;
      return data;
    } else {
      return {'error': 'No se pudo cargar el usuario'};
    }
  }

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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      currentUser = {...currentUser!, ...data};
      return data;
    } else {
      return {'error': 'Error al actualizar perfil'};
    }
  }

  void logout() {
    isLoggedIn = false;
    currentUser = null;
  }
}
