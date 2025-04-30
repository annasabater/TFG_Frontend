import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class DroneControlPage extends StatelessWidget {
  const DroneControlPage({super.key});

  void fireBullet(String type) {
    // Lógica para disparar según tipo
    print("Disparo tipo: $type");
  }

  void handleJoystickMove(String id, Offset offset) {
    // Aquí puedes enviar comandos al dron
    print("Joystick $id movido: $offset");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5), // Azul/gris/blanco claro
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Balas en horizontal
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBulletButton("assets/bullet1.png", "tipo1"),
                const SizedBox(width: 12),
                _buildBulletButton("assets/bullet2.png", "tipo2"),
                const SizedBox(width: 12),
                _buildBulletButton("assets/bullet3.png", "tipo3"),
              ],
            ),

            const Spacer(),

            // Joysticks
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildJoystick("horizontal"),
                  _buildJoystick("lateral"),
                ],
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
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}

