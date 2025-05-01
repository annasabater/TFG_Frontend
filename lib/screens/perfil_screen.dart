// lib/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Layout.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutWrapper(
      title: 'Perfil',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blue, // ahora azul
                    child: Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Exemple',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'demo@exemple.com',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  // ... tus Cards de datos ...
                  const SizedBox(height: 32),
                  // Botón Editar Perfil
                  ListTile(
                    leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                    title: const Text('Editar Perfil'),
                    subtitle: const Text('Actualitza la teva informació personal'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navega a /profile/edit
                      context.go('/profile/edit');
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      AuthService().logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('TANCAR SESSIÓ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
