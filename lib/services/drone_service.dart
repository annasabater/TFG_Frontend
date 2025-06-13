// lib/screens/drone_service.dart

import 'dart:convert';
import 'dart:io' show Platform, File;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/shipping_info.dart';
import '../models/drone.dart';
import '../models/drone_query.dart';
import 'auth_service.dart';

class DroneService {
  static String get _base {
    if (kIsWeb) return 'http://localhost:9000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:9000/api';
    return 'http://localhost:9000/api';
  }

  static Uri _dronesUri([DroneQuery? q]) =>
      Uri.parse('$_base/drones').replace(queryParameters: q?.toQueryParams());

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

  static Future<Drone> getDroneByIdWithCurrency(
    String id,
    String currency,
  ) async {
    final resp = await http.get(
      Uri.parse('$_base/drones/$id?currency=$currency'),
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    return Drone.fromJson(jsonDecode(resp.body));
  }

  // Método createDrone adaptado para enviar imágenes con multipart/form-data
  static Future<Drone> createDrone(
    Drone d, {
    List<File>? images, // lista opcional de imágenes para subir
    List<XFile>? imagesWeb, // lista opcional de imágenes para web
  }) async {
    final jwt = await AuthService().token;
    final uri = _dronesUri();
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $jwt';

    // Añadir campos del drone al formulario
    final droneJson = d.toJson();
    droneJson.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    // Adjuntar imágenes
    if (images != null && images.isNotEmpty) {
      for (var imgFile in images) {
        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          imgFile.path,
          filename: basename(imgFile.path),
        );
        request.files.add(multipartFile);
      }
    } else if (imagesWeb != null && imagesWeb.isNotEmpty) {
      for (var xfile in imagesWeb) {
        final bytes = await xfile.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'images',
          bytes,
          filename: basename(xfile.name),
        );
        request.files.add(multipartFile);
      }
    }

    // Enviar petición
    final streamedResponse = await request.send();

    final respStr = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200 &&
        streamedResponse.statusCode != 201) {
      throw Exception('Error ${streamedResponse.statusCode}: $respStr');
    }

    final json = jsonDecode(respStr);
    return Drone.fromJson(json);
  }

  static Future<bool> deleteDrone(String id) async {
    final jwt = await AuthService().token;
    final resp = await http.delete(
      Uri.parse('$_base/drones/$id'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    return resp.statusCode == 200;
  }

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
      body: jsonEncode({
        'userId': userId,
        'rating': rating,
        'comment': comment,
      }),
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    return Drone.fromJson(jsonDecode(resp.body));
  }

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

  static Future<List<Drone>> getMyDrones(
    String userId, {
    String? status,
  }) async {
    final jwt = await AuthService().token;
    final uri = Uri.parse(
      '$_base/users/$userId/my-drones',
    ).replace(queryParameters: {if (status != null) 'status': status});
    final resp = await http.get(uri, headers: {'Authorization': 'Bearer $jwt'});
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    final data = jsonDecode(resp.body) as List;
    return data.map((e) => Drone.fromJson(e)).toList();
  }

  static Future<Drone> purchaseDrone(String id, ShippingInfo info) async {
    final jwt = await AuthService().token;
    final resp = await http.post(
      Uri.parse('$_base/drones/$id/purchase'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode(info.toJson()),
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    return Drone.fromJson(jsonDecode(resp.body));
  }

  static Future<Drone> markSold(String id) async {
    final jwt = await AuthService().token;
    final resp = await http.put(
      Uri.parse('$_base/drones/$id/sold'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
    return Drone.fromJson(jsonDecode(resp.body));
  }

  static Future<Drone> updateDrone(
    String id,
    Drone d, {
    List<File>? images,
    List<XFile>? imagesWeb,
  }) async {
    final jwt = await AuthService().token;
    // Si hay imágenes nuevas, usa multipart/form-data
    if ((images != null && images.isNotEmpty) ||
        (imagesWeb != null && imagesWeb.isNotEmpty)) {
      final uri = Uri.parse('$_base/drones/$id');
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $jwt';

      final droneJson = d.toJson();
      droneJson.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      if (images != null && images.isNotEmpty) {
        for (var imgFile in images) {
          final multipartFile = await http.MultipartFile.fromPath(
            'images',
            imgFile.path,
            filename: basename(imgFile.path),
          );
          request.files.add(multipartFile);
        }
      } else if (imagesWeb != null && imagesWeb.isNotEmpty) {
        for (var xfile in imagesWeb) {
          final bytes = await xfile.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: basename(xfile.name),
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode != 200 &&
          streamedResponse.statusCode != 201) {
        throw Exception('Error ${streamedResponse.statusCode}: $respStr');
      }

      final json = jsonDecode(respStr);
      return Drone.fromJson(json);
    } else {
      // Si no hay imágenes nuevas, usa JSON normal
      final resp = await http.put(
        Uri.parse('$_base/drones/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode(d.toJson()),
      );
      if (resp.statusCode != 200) throw Exception('Error ${resp.statusCode}');
      return Drone.fromJson(jsonDecode(resp.body));
    }
  }

  static Future<bool> purchaseMultiple({
    required String userId,
    required String payWithCurrency,
    required List<Map<String, dynamic>> items,
  }) async {
    final serverUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost:9000';
    final url = Uri.parse('$serverUrl/api/drones/purchase-multiple');
    final jwt = await AuthService().token;
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({
        'userId': userId,
        'payWithCurrency': payWithCurrency,
        'items': items,
      }),
    );
    if (resp.statusCode == 200) return true;
    throw Exception('Error en la compra: ${resp.statusCode}');
  }
}
