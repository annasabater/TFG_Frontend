// lib/services/UserService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';

class UserService {
  static String get baseUrl {
    final api = AuthService().baseApiUrl;
    return '$api/users';
  }

  /// Devuelve *todos* los usuarios de la BBDD,
  /// recibiendo por páginas (`page`, `limit`).
  static Future<List<User>> getUsers({int pageSize = 100}) async {
    final token = await AuthService().token;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final allUsers = <User>[];
    var page = 1;

    while (true) {
      // Si tu API usa otros nombres (offset/skip), ajústalo aquí
      final uri = Uri.parse('$baseUrl?page=$page&limit=$pageSize');
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) {
        throw Exception('Error fetching users (página $page): ${resp.statusCode}');
      }

      final List data = jsonDecode(resp.body);
      if (data.isEmpty) break;

      allUsers.addAll(data.map((j) => User.fromJson(j)));
      if (data.length < pageSize) break;
      page++;
    }

    return allUsers;
  }

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

  static Future<bool> deleteUser(String id) async {
    final token = await AuthService().token;
    final resp = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) return true;
    if (resp.statusCode == 404) return false;
    throw Exception('Error deleting user $id: ${resp.statusCode}');
  }

  static Future<Map<String, dynamic>> getUserBalance(String userId) async {
    final token = await AuthService().token;
    final api = AuthService().baseApiUrl;
    final url = Uri.parse('$api/users/$userId/balance');
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Error fetching balance: ${resp.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getPurchaseHistory(String userId) async {
    final token = await AuthService().token;
    final api = AuthService().baseApiUrl;
    final url = Uri.parse('$api/users/$userId/purchase-history');
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error fetching purchase history: ${resp.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getSalesHistory(String userId) async {
    final token = await AuthService().token;
    final api = AuthService().baseApiUrl;
    final url = Uri.parse('$api/users/$userId/sales-history');
    final resp = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error fetching sales history: ${resp.statusCode}');
  }
}
