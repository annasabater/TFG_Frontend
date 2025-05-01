// lib/screens/drone_control_page.dart
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
        child: Stack(
          children: [
            // Botones de bala en columna vertical a la derecha
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

            // Joysticks alineados en la parte inferior
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
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}