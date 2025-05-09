// lib/screens/drone_control_page.dart
/*import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class DroneControlPage extends StatelessWidget {
  const DroneControlPage({super.key});

  void fireBullet(String type) {
    print("Disparo tipo: $type");
  }

  void handleJoystickMove(String id, Offset offset) {
    if (id == 'horizontal') {
      final roll  = offset.dx.clamp(-1.0, 1.0); //Inclinación hacia la derecha o la izquierda.
      final pitch = (-offset.dy).clamp(-1.0, 1.0); //Inclinación hacia adelante o hacia atrás.
      print('MOVE roll=$roll pitch=$pitch');
    } else {
      final yaw = offset.dx.clamp(-1.0, 1.0); //Rotación hacia la izquierda o la derecha.
      final throttle = (-offset.dy).clamp(-1.0, 1.0); //Aceleración hacia arriba o hacia abajo.
      print('MOVE yaw=$yaw throttle=$throttle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: SafeArea(
        child: Stack(
          children: [
            // Botones de bala
            Positioned(
              top: 30,
              right: 16,
              child: Column(
                children: [
                  _buildBulletButton("lib/assets/bullet1.png", "tipo1"),
                  const SizedBox(height: 12),
                  _buildBulletButton("lib/assets/bullet2.png", "tipo2"),
                  const SizedBox(height: 12),
                  _buildBulletButton("lib/assets/bullet3.png", "tipo3"),
                ],
              ),
            ),

            // Joysticks abajo
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildJoystick("horizontal"),
                    _buildJoystick("lateral"),
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
      listener: (details) => handleJoystickMove(id, Offset(details.x, details.y)),
      mode: JoystickMode.all,
      base: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF2F3B4C),
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

  Widget _buildBulletButton(String imagePath, String type) {
    return GestureDetector(
      onTap: () => fireBullet(type),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
*/

// lib/screens/drone_control_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:go_router/go_router.dart';
import '../services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DroneControlPage extends StatefulWidget {
  const DroneControlPage({Key? key}) : super(key: key);

  @override
  State<DroneControlPage> createState() => _DroneControlPageState();
}

class _DroneControlPageState extends State<DroneControlPage> {
  IO.Socket? _socket;
  Map<String, dynamic>? _gameState;

  @override
  void initState() {
    super.initState();
    // Reutilizamos el socket ya abierto en WaitingRoomPage
    _socket = SocketService.socketInstance;

    _socket
      ?..on('start_game_from_professor', (_) {
        // Cuando Python emita el evento, navegamos a la página de control
        context.go('/jocs/control');
      })
      ..on('state_update', (data) {
        setState(() => _gameState = Map<String, dynamic>.from(data));
      })
      ..on('disconnect', (_) {
        print('🔌 Desconectado del juego');
      });
  }

  @override
  void dispose() {
    // Limpiamos solo los listeners de este page
    _socket
      ?..off('start_game_from_professor')
      ..off('state_update')
      ..off('disconnect');
    super.dispose();
  }

  void _onJoystickMove(String stickId, Offset offset) {
    SocketService.sendCommand('move', {
      'stick': stickId,
      'dx': offset.dx,
      'dy': offset.dy,
    });
  }

  void _fireBullet(String type) {
    SocketService.sendCommand('fire', {'type': type});
  }

  @override
  Widget build(BuildContext context) {
    final status = _gameState?['status']?.toString() ?? 'Waiting...';
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: SafeArea(
        child: Stack(
          children: [
            // Estado en la esquina superior izquierda
            Positioned(
              top: 16,
              left: 16,
              child: Text('Estado: $status', style: const TextStyle(fontSize: 16)),
            ),

            // Botones de disparo en la esquina superior derecha
            Positioned(
              top: 30,
              right: 16,
              child: Column(
                children: [
                  _buildBulletButton("lib/assets/bullet1.png", "small_fast"),
                  const SizedBox(height: 12),
                  _buildBulletButton("lib/assets/bullet2.png", "medium"),
                  const SizedBox(height: 12),
                  _buildBulletButton("lib/assets/bullet3.png", "large_slow"),
                ],
              ),
            ),

            // Joysticks en la parte inferior
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
