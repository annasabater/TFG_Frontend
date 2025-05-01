// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  bool isLoggedIn = false;
  Map<String, dynamic>? currentUser;

  static String get _baseApiUrl {
    if (kIsWeb) return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  String get _loginUrl        => '$_baseApiUrl/users/login';
  String get _signupUrl       => '$_baseApiUrl/users/signup';
  String get _updateProfileUrl=> '$_baseApiUrl/users';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(_loginUrl);
    final body = json.encode({'email': email, 'password': password});
    try {
      final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        isLoggedIn = true;
        currentUser = data;
        return data;
      } else {
        return {'error': 'Email o contraseña incorrectos'};
      }
    } catch (e) {
      return {'error': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> signup({
    required String userName,
    required String email,
    required String password,
    String role = 'Usuario',
  }) async {
    final url  = Uri.parse(_signupUrl);
    final body = json.encode({
      'userName': userName,
      'email':    email,
      'password': password,
      'role':     role,
    });
    try {
      final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return json.decode(resp.body);
      } else {
        final data = json.decode(resp.body);
        return {'error': data['message'] ?? 'Error en registro'};
      }
    } catch (e) {
      return {'error': 'Error de conexión'};
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
    final id = currentUser!['_id'];
    final url = Uri.parse('$_updateProfileUrl/$id');

    final bodyMap = {
      'userName': userName,
      'email':    email,
    };
    if (password != null && password.isNotEmpty) {
      bodyMap['password'] = password;
    }
    if (role != null) {
      bodyMap['role'] = role;
    }

    try {
      final resp = await http.put(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyMap),
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        currentUser = {...currentUser!, ...data};
        return data;
      } else {
        return {'error': 'Error al actualizar perfil'};
      }
    } catch (e) {
      return {'error': 'Error de conexión'};
    }
  }

  void logout() {
    isLoggedIn = false;
    currentUser = null;
  }
}
