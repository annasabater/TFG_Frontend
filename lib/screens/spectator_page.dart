// lib/screens/spectator_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/socket_service.dart';

class SpectatorPage extends StatefulWidget {
  final String sessionId;
  const SpectatorPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<SpectatorPage> createState() => _SpectatorPageState();
}

class _SpectatorPageState extends State<SpectatorPage> {
  IO.Socket? _socket;
  final MapController _mapCtrl = MapController();
  double _zoom = 19;
  bool _showMap = false;

  final Map<String, Marker> _droneMarkers   = {};
  final Map<String, Polygon> _fencePolygons = {};
  final Map<String, Polygon> _obstaclePolys = {};

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    // Conectar como espectador (saltando auth de competidor)
    _socket = IO.io('${SocketService.serverUrl}/jocs', {
      'transports': ['websocket'],
      'query': {
        'sessionId': widget.sessionId,
        'spectator': 'true',
      },
      'autoConnect': false,
    })..connect();

    _socket!
      ..on('connect', (_) {
        _socket!.emit('join', {'sessionId': widget.sessionId});
      })
      // Arrancar visualización cuando la partida comience
      ..on('game_started', (_) {
        setState(() {
          _showMap = true;
        });
      })
      ..on('state_update', _onUpdate)
      ..on('disconnect', (_) => debugPrint('Spectator disconnected'));
  }

  void _onUpdate(dynamic data) {
    final action = data['action'] as String? ?? '';
    final drone  = data['drone']  as String? ?? '';
    final payload = data['payload'] as Map<String, dynamic>? ?? {};

    setState(() {
      switch (action) {
        case 'telemetry':
          final lat = payload['lat'] as double;
          final lon = payload['lon'] as double;
          _droneMarkers[drone] = Marker(
            point: LatLng(lat, lon), width: 30, height: 30,
            child: const Icon(Icons.airplanemode_active, size: 30),
          );
          break;

        case 'fence_add':
          final geo = payload['geometry'] as List;
          final pts = geo.map((pt) => LatLng(pt['lat'], pt['lon'])).toList();
          _fencePolygons[drone] = Polygon(
            points: pts,
            color: Colors.blue.withOpacity(0.2),
            borderColor: Colors.blue,
            borderStrokeWidth: 2,
          );
          break;

        case 'obstacle_add':
          final geo = payload['geometry'] as List;
          final pts = geo.map((pt) => LatLng(pt['lat'], pt['lon'])).toList();
          final id = geo.map((pt) => '${pt['lat']}_${pt['lon']}').join('_');
          _obstaclePolys[id] = Polygon(
            points: pts,
            color: Colors.black26,
            borderColor: Colors.grey,
            borderStrokeWidth: 1,
          );
          break;

        case 'fence_remove':
          _fencePolygons.clear();
          break;

        case 'obstacle_remove':
          final geo = payload['geometry'] as List;
          final id = geo.map((pt) => '${pt['lat']}_${pt['lon']}').join('_');
          _obstaclePolys.remove(id);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo espectador')),
      body: _showMap
        ? FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(center: LatLng(41.276, 1.988), zoom: _zoom),
            children: [
              TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
              if (_fencePolygons.isNotEmpty)
                PolygonLayer(polygons: _fencePolygons.values.toList()),
              if (_obstaclePolys.isNotEmpty)
                PolygonLayer(polygons: _obstaclePolys.values.toList()),
              MarkerLayer(markers: _droneMarkers.values.toList()),
            ],
          )
        : const Center(child: Text('Esperando a que empiece la partida…')),
      floatingActionButton: _showMap
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                onPressed: () => setState(() => _zoom++),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                onPressed: () => setState(() => _zoom--),
                child: const Icon(Icons.remove),
              ),
            ],
          )
        : null,
    );
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }
}
