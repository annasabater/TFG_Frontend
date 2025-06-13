import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:SkyNet/models/drone_zone.dart';

class DroneZonesService {
  static final String _baseUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost:3000';

  // Obtener todas las zonas de drones
  Future<List<DroneZone>> getZones() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/drone-zones'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> zonesData = json.decode(response.body);
        return zonesData.map((zoneData) => DroneZone.fromJson(zoneData)).toList();
      } else {
        throw Exception('Error al obtener zonas: ${response.statusCode}');
      }
    } catch (e) {
      // Si falla, devolvemos datos de ejemplo para desarrollo
      return _getMockZones();
    }
  }

  // Datos de ejemplo para desarrollo
  List<DroneZone> _getMockZones() {
    return [
      DroneZone(
        id: '1',
        name: 'Zona Restringida EETAC',
        description: 'No se permite volar drones en esta zona',
        coordinates: [41.2757, 1.9881, 41.2767, 1.9881, 41.2767, 1.9891, 41.2757, 1.9891],
        type: 'restricted',
        color: '#FF0000',
      ),
      DroneZone(
        id: '2',
        name: 'Zona Permitida Parque',
        description: 'Vuelo de drones permitido a baja altura',
        coordinates: [41.2857, 1.9981, 41.2867, 1.9981, 41.2867, 1.9991, 41.2857, 1.9991],
        type: 'allowed',
        color: '#00FF00',
      ),
    ];
  }
}

// NOTA: Ahora las zonas de drones se gestionan desde GeoJSON usando GeoJSONService.
// Este servicio queda obsoleto para la gestión de zonas visuales en el mapa. 