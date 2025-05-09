import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/drone.dart';
import '../models/drone_query.dart';
import 'auth_service.dart';

class DroneService {
  /* ------------ configuració bàsica ------------ */

  static String get _base {
    if (kIsWeb)             return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  static Uri _dronesUri([DroneQuery? q]) =>
      Uri.parse('$_base/drones').replace(queryParameters: q?.toQueryParams());

  /* ------------ operacions principals ---------- */

  /// ✔️ ara és estàtic
  static Future<List<Drone>> getDrones([DroneQuery? q]) async {
    final resp = await http.get(_dronesUri(q));
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    final data = jsonDecode(resp.body) as List;
    return data.map((e) => Drone.fromJson(e)).toList();
  }

  static Future<Drone> getDroneById(String id) async {
    final resp = await http.get(Uri.parse('$_base/drones/$id'));
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    return Drone.fromJson(jsonDecode(resp.body));
  }

  static Future<Drone> createDrone(Drone d) async {
    final jwt  = await AuthService().token;
    final resp = await http.post(
      _dronesUri(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(d.toJson()),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Error ${resp.statusCode}');
    }
    return Drone.fromJson(jsonDecode(resp.body));
  }

  static Future<bool> deleteDrone(String id) async {
    final jwt = await AuthService().token;
    final resp = await http.delete(
      Uri.parse('$_base/drones/$id'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    return resp.statusCode == 200;
  }

  /* ------------------- reviews ------------------ */

  static Future<Drone> addReview({
    required String droneId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    final jwt = await AuthService().token;
    final resp = await http.post(
      Uri.parse('$_base/drones/$droneId/review'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'userId': userId, 'rating': rating, 'comment': comment}),
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    return Drone.fromJson(jsonDecode(resp.body));
  }

  /* -------------- favorits / meus -------------- */

  static Future<List<Drone>> getFavorites(String userId) async {
    final jwt = await AuthService().token;
    final resp = await http.get(
      Uri.parse('$_base/users/$userId/favourites'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    final data = jsonDecode(resp.body) as List;
    return data.map((e) => Drone.fromJson(e)).toList();
  }

  static Future<void> addFavorite(String userId, String droneId) async {
    final jwt = await AuthService().token;
    final resp = await http.post(
      Uri.parse('$_base/users/$userId/favourites/$droneId'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
  }

  static Future<void> removeFavorite(String userId, String droneId) async {
    final jwt = await AuthService().token;
    final resp = await http.delete(
      Uri.parse('$_base/users/$userId/favourites/$droneId'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
  }

  static Future<List<Drone>> getMyDrones(String userId, {String? status}) async {
    final jwt = await AuthService().token;
    final uri = Uri.parse('$_base/users/$userId/my-drones')
        .replace(queryParameters: {if (status != null) 'status': status});
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $jwt'});
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    final data = jsonDecode(resp.body) as List;
    return data.map((e) => Drone.fromJson(e)).toList();
  }
}
