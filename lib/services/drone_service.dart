import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/drone.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DroneService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/drones';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/drones';
    } else {
      return 'http://localhost:9000/api/drones';
    }
  }

  /// GET /api/drones
  static Future<List<Drone>> getDrones() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Drone.fromJson(json)).toList();
    } else {
      throw Exception('Error cargando drones: ${response.statusCode}');
    }
  }

  /// POST /api/drones
  static Future<Drone> createDrone(Drone drone) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(drone.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Drone.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error creando drone: ${response.statusCode}');
    }
  }

  /// GET /api/drones/:id
  static Future<Drone> getDroneById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Drone.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error obteniendo drone: ${response.statusCode}');
    }
  }

  /// PUT /api/drones/:id
  static Future<Drone> updateDrone(String id, Drone drone) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(drone.toJson()),
    );

    if (response.statusCode == 200) {
      return Drone.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error actualizando drone: ${response.statusCode}');
    }
  }

  /// DELETE /api/drones/:id
  static Future<bool> deleteDrone(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error eliminando drone: ${response.statusCode}');
    }
  }
}
