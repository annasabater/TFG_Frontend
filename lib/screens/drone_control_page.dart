//lib/screens/drone_control_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/socket_service.dart';

class DroneControlPage extends StatefulWidget {
  final String sessionId;
  const DroneControlPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<DroneControlPage> createState() => _DroneControlPageState();
}

class _DroneControlPageState extends State<DroneControlPage> {
  IO.Socket? _socket;
  String _status = 'Waiting...';
  Map<String, dynamic>? _gameState;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    final token = SocketService.jwt;
    _socket = IO.io(
      '${SocketService.serverUrl}/jocs',
      <String, dynamic>{
        'transports': ['websocket'],
        'auth': {'token': token},
        'autoConnect': false,
      },
    );
    _socket!.connect();

    _socket!
      ..on('connect', (_) {
        debugPrint('🔌 Reconectado a /jocs');
        _socket!.emit('join', {'sessionId': widget.sessionId});
      })
      ..on('game_started', (_) {
        setState(() => _status = 'Started');
      })
      ..on('state_update', (data) {
        setState(() => _gameState = Map<String, dynamic>.from(data));
      })
      ..on('disconnect', (_) {
        debugPrint('🔌 Desconectado del juego');
      });
  }

  @override
  void dispose() {
    _socket
      ?..off('connect')
      ..off('game_started')
      ..off('state_update')
      ..off('disconnect');
    super.dispose();
  }

  void _onJoystickMove(String stickId, Offset offset) {
    _socket!.emit('control', {
      'sessionId': widget.sessionId,
      'drone': SocketService.currentUserEmail,
      'action': 'move',
      'payload': {'stick': stickId, 'dx': offset.dx, 'dy': offset.dy},
    });
  }

  void _fireBullet(String type) {
    _socket!.emit('control', {
      'sessionId': widget.sessionId,
      'drone': SocketService.currentUserEmail,
      'action': 'fire',
      'payload': {'type': type},
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: SafeArea(
        child: Stack(
          children: [
          /*  Positioned(
              top: 16,
              left: 16,
              child: Text('Estado: $_status', style: const TextStyle(fontSize: 16)),
            ),*/
            Positioned(
              top: 30,
              right: 16,
              child: Column(
                children: [
                  _buildBulletButton("assets/bullet1.png", "small_fast"),
                  const SizedBox(height: 12),
                  _buildBulletButton("assets/bullet2.png", "medium"),
                  const SizedBox(height: 12),
                  _buildBulletButton("assets/bullet3.png", "large_slow"),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildJoystick("left"),
                    _buildJoystick("right"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoystick(String id) {
    return Joystick(
      listener: (det) => _onJoystickMove(id, Offset(det.x, det.y)),
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
  }

  Widget _buildBulletButton(String asset, String type) {
    return GestureDetector(
      onTap: () => _fireBullet(type),
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
  }
}
