// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool isLoggedIn = false;
  Map<String, dynamic>? currentUser;

  static String get _baseApiUrl {
    if (kIsWeb) return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  String get _loginUrl          => '$_baseApiUrl/users/login';
  String get _signupUrl         => '$_baseApiUrl/users/signup';
  String get _getUserByIdUrl    => '$_baseApiUrl/users';
  String get _updateProfileUrl  => '$_baseApiUrl/users';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url  = Uri.parse(_loginUrl);
    final body = json.encode({'email': email, 'password': password});
    try {
      final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        isLoggedIn   = true;
        currentUser  = data;
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('token')) {
          await prefs.setString('jwtToken', data['token']);
        }
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('token')) {
          await prefs.setString('jwtToken', data['token']);
        }
        return data;
      } else {
        final data = json.decode(resp.body);
        return {'error': data['message'] ?? 'Error en registro'};
      }
    } catch (e) {
      return {'error': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final url = Uri.parse('$_getUserByIdUrl/$id');
    try {
      final resp = await http.get(url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        currentUser = data;
        return data;
      } else {
        return {'error': 'No se pudo cargar el usuario'};
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
    final id  = currentUser!['_id'];
    final url = Uri.parse('$_updateProfileUrl/$id');
    final bodyMap = {
      'userName': userName,
      'email':    email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (role != null) 'role': role,
    };
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

  void logout() async {
    isLoggedIn  = false;
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
  }
}
