import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../services/socket_service.dart';

class DroneControlPage extends StatefulWidget {
  final String sessionId;
  const DroneControlPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<DroneControlPage> createState() => _DroneControlPageState();
}

class _DroneControlPageState extends State<DroneControlPage> {
  // ─────────────────────────────  SOCKET  ──────────────────────────────
  IO.Socket? _socket;

  // ─────────────────────────────  MAPA  ────────────────────────────────
  final MapController _mapController = MapController();
  bool   _showMap      = false;

  // Drones / balas / fences / obstáculos
  final Map<String, Marker>  _droneMarkers    = {};
  final Map<String, Marker>  _bulletMarkers   = {};
  final Map<String, Polygon> _fencePolygons   = {};
  final Map<String, Polygon> _obstaclePolys   = {};

  int _bulletUid = 0;

  // Última telemetría de “mi” dron (solo para texto informativo)
  Map<String, dynamic>? _myTelemetry;

  // ─────────────────────────────  JOYSTICK  ────────────────────────────
  Timer? _throttleTimer;
  static const double    _deadZone        = 0.05;
  static const double    _maxSpeed        = 1.0;
  static const Duration  _throttlePeriod  = Duration(milliseconds: 100);

  // ─────────────────────────────  INIT / SOCKET  ───────────────────────
  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    final token = SocketService.jwt;
    _socket = IO.io(
      '${SocketService.serverUrl}/jocs',
      {
        'transports': ['websocket'],
        'auth': {'token': token},
        'autoConnect': false,
      },
    )..connect();

    _socket!
      ..on('connect', (_) {
        _socket!.emit('join', {'sessionId': widget.sessionId});
      })
      ..on('state_update', _handleStateUpdate);
  }

  void _handleStateUpdate(dynamic data) {
    final String action = data['action'] ?? '';
    final String drone  = data['drone']  ?? '';
    final payload       = data['payload'] as Map<String, dynamic>? ?? {};

    switch (action) {
      case 'telemetry':
        _updateDrone(drone, payload);
        break;

      case 'bullet_create':
      case 'bullet_move':
        _updateBullet(payload, create: action == 'bullet_create');
        break;

      case 'bullet_destroy':
        _bulletMarkers.remove(payload['bulletId']);
        break;

      case 'fence_add':
        _addFence(payload['geometry']);
        break;
      case 'fence_remove':
        _fencePolygons.clear();
        break;

      case 'obstacle_add':
        _addObstacle(payload['geometry']);
        break;
      case 'obstacle_remove':
        _obstaclePolys.clear();
        break;
    }

    setState(() {});      // refresca mapa-UI
  }

  // ─────────────────────────────  ACTUALIZACIONES  ─────────────────────
  void _updateDrone(String id, Map<String, dynamic> p) {
    final lat = p['lat'] as double;
    final lon = p['lon'] as double;
    final hdg = p['heading'] as num? ?? 0;

    final marker = Marker(
      point: LatLng(lat, lon),
      width: 30,
      height: 30,
      child: Transform.rotate(
        angle: hdg.toDouble() * pi / 180,
        child: const Icon(Icons.airplanemode_active, color: Colors.red, size: 30),
      ),
    );
    _droneMarkers[id] = marker;

    // Guardo mi propia telemetría (para mostrar texto)
    if (id == SocketService.currentUserEmail) _myTelemetry = p;
  }

  void _updateBullet(Map<String, dynamic> p, {required bool create}) {
    final id  = p['bulletId'] as String;
    final lat = p['lat'] as double;
    final lon = p['lon'] as double;

    _bulletMarkers[id] = Marker(
      point: LatLng(lat, lon),
      width: 12,
      height: 12,
      child: const Icon(Icons.fiber_manual_record, color: Colors.orange, size: 12),
    );

    if (!create) setState(() {});   // para repaint rápido en “move”
  }

  void _addFence(List geometry) {
    final points = geometry.map<LatLng>((pt) => LatLng(pt['lat'], pt['lon'])).toList();
    _fencePolygons['fence'] = Polygon(
      points: points,
      color: Colors.green.withOpacity(0.25),
      borderColor: Colors.green,
      borderStrokeWidth: 3,
    );
  }

  void _addObstacle(List geometry) {
    final String id = 'obs_${_obstaclePolys.length}';
    final points = geometry.map<LatLng>((pt) => LatLng(pt['lat'], pt['lon'])).toList();
    _obstaclePolys[id] = Polygon(
      points: points,
      color: Colors.black.withOpacity(0.4),
      borderColor: Colors.black,
      borderStrokeWidth: 1,
    );
  }

  // ─────────────────────────────  CONTROLES  ───────────────────────────
  void _onJoy(String stick, Offset off) {
    final mag = sqrt(off.dx * off.dx + off.dy * off.dy);
    if (mag < _deadZone) return;
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(_throttlePeriod, () {});

    final nx = off.dx / mag;
    final ny = off.dy / mag;
    final f  = ((mag - _deadZone) / (1 - _deadZone)).clamp(0.0, 1.0) * _maxSpeed;

    final payload = stick == 'left'
        ? {'dx': nx * f, 'dy': ny * f}
        : {'dz': ny * f};
    final action  = stick == 'left' ? 'move' : 'throttle';

    _socket!.emit('control', {
      'sessionId': widget.sessionId,
      'drone'    : SocketService.currentUserEmail,
      'action'   : action,
      'payload'  : payload,
    });
  }

  void _fire(String type) {
    final id = 'b${_bulletUid++}';
    _socket!.emit('control', {
      'sessionId': widget.sessionId,
      'drone'    : SocketService.currentUserEmail,
      'action'   : 'fire',
      'payload'  : {'type': type, 'bulletId': id},
    });
  }

  // ─────────────────────────────  UI  ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final telemetryLabel = _myTelemetry == null
        ? const SizedBox.shrink()
        : Positioned(
            top: 56,
            left: 16,
            child: Text(
              'Pos: ${(_myTelemetry!['lat'] as double).toStringAsFixed(5)}, '
              '${(_myTelemetry!['lon'] as double).toStringAsFixed(5)}   '
              'Hd: ${(_myTelemetry!['heading'] as num).toStringAsFixed(1)}°',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: SafeArea(
        child: Stack(
          children: [
            // ─────────── MAPA ───────────
            if (_showMap) Positioned.fill(child: _buildMap()),

            // Botón ON/OFF mapa
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(_showMap ? Icons.layers_clear : Icons.layers),
                onPressed: () => setState(() => _showMap = !_showMap),
              ),
            ),

            telemetryLabel,

            // Botones de disparo
            Positioned(
              top: 30,
              right: 16,
              child: Column(
                children: [
                  _bulletBtn('assets/bullet1.png', 'small_fast'),
                  const SizedBox(height: 12),
                  _bulletBtn('assets/bullet2.png', 'medium'),
                  const SizedBox(height: 12),
                  _bulletBtn('assets/bullet3.png', 'large_slow'),
                ],
              ),
            ),

            // Joysticks
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _joystick('left'),
                    _joystick('right'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(41.2764478, 1.9886568),
        zoom: 21,
        interactiveFlags: InteractiveFlag.none,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        if (_fencePolygons.isNotEmpty)
          PolygonLayer(polygons: _fencePolygons.values.toList()),
        if (_obstaclePolys.isNotEmpty)
          PolygonLayer(polygons: _obstaclePolys.values.toList()),
        MarkerLayer(markers: [
          ..._droneMarkers.values,
          ..._bulletMarkers.values,
        ]),
      ],
    );
  }

  // ─────────────────────────────  WIDGETS AUX.  ────────────────────────
  Widget _joystick(String id) => Joystick(
        listener: (d) => _onJoy(id, Offset(d.x, d.y)),
        mode: JoystickMode.all,
        base: Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Color(0xFF2F3B4C),
            shape: BoxShape.circle,
          ),
        ),
        stick: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
      );

  Widget _bulletBtn(String asset, String type) => GestureDetector(
        onTap: () => _fire(type),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        ),
      );

  // ─────────────────────────────  DISPOSE  ─────────────────────────────
  @override
  void dispose() {
    _socket
      ?..off('state_update')
      ..dispose();
    _throttleTimer?.cancel();
    super.dispose();
  }
}
