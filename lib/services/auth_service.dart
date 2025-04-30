import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  bool isLoggedIn = false; // Estado de autenticación

  static String get _baseApiUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api';
    } else {
      return 'http://localhost:9000/api';
    }
  }

  // Endpoints concretos
  String get _loginUrl  => '$_baseApiUrl/users/login';
  String get _signupUrl => '$_baseApiUrl/users/signup';

  /// Inicia sesión con email y contraseña
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url  = Uri.parse(_loginUrl);
    final body = json.encode({'email': email, 'password': password});

    try {
      print('Enviando POST a $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Respuesta status: ${response.statusCode}');

      if (response.statusCode == 200) {
        isLoggedIn = true;
        return json.decode(response.body);
      } else {
        return {'error': 'Email o contraseña incorrectos'};
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
      return {'error': 'Error de conexión'};
    }
  }

  /// Registra un nuevo usuario
  Future<Map<String, dynamic>> signup({
    required String userName,
    required String email,
    required String password,
    required String role,
  }) async {
    final url  = Uri.parse(_signupUrl);
    final body = json.encode({
      'userName': userName,
      'email': email,
      'password': password,
      'role': role,
    });

    try {
      print('Enviando POST a $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Respuesta status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        return {'error': data['message'] ?? 'Error en registro'};
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
      return {'error': 'Error de conexión'};
    }
  }

  /// Cierra la sesión localmente
  void logout() {
    isLoggedIn = false;
    print('Sesión cerrada');
  }
}
