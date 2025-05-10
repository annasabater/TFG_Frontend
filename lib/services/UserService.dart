// lib/services/UserService.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import 'auth_service.dart';

class UserService {
  static String get baseUrl {
    final api = AuthService().baseApiUrl; 
    return '$api/users';
  }

  /// Obtiene la lista de usuarios, enviando el JWT 
  static Future<List<User>> getUsers() async {
    final token = await AuthService().token;
    final resp = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Error fetching users: ${resp.statusCode}');
  }

  /// Crea un usuario, incluyendo el JWT
  static Future<User> createUser(User user) async {
    final token = await AuthService().token;
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Error creating user: ${resp.statusCode}');
  }

  /// Obtiene un usuario por ID
  static Future<User> getUserById(String id) async {
    final token = await AuthService().token;
    final resp = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Error fetching user $id: ${resp.statusCode}');
  }

  /// Actualiza un usuario
  static Future<User> updateUser(String id, User user) async {
    final token = await AuthService().token;
    final resp = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );
    if (resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Error updating user $id: ${resp.statusCode}');
  }

  /// Elimina un usuario por ID
  static Future<bool> deleteUser(String id) async {
    final token = await AuthService().token;
    final resp = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      return true;
    }
    if (resp.statusCode == 404) {
      return false;
    }
    throw Exception('Error deleting user $id: ${resp.statusCode}');
  }
}
