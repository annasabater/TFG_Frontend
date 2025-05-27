// lib/screens/jocs_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../provider/users_provider.dart';
import '../services/socket_service.dart';
import '../data/game_texts.dart';

/// Botón decorado que reutilizamos para "Descripción" y "Manual".
class _FancyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FancyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff42A5F5), Color(0xff1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class JocsPage extends StatelessWidget {
  const JocsPage({Key? key}) : super(key: key);

  void _showTextDialog(BuildContext ctx, String title, String content) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompetitor = context.watch<UserProvider>().isCompetitor;
    final email        = context.read<UserProvider>().currentUser!.email;
    return Scaffold(
      appBar: AppBar(title: const Text('Juegos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/logo_skynet.png', width: 100),
            const SizedBox(height: 32),

            // —— Botones Descripción y Manual ——  
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FancyButton(
                  label: 'Descripción',
                  onTap: () => _showTextDialog(context, 'Descripción del juego', kGameDescription),
                ),
                const SizedBox(width: 16),
                _FancyButton(
                  label: 'Manual',
                  onTap: () => _showTextDialog(context, 'Manual del juego', kGameManual),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // —— Carta de COMBATE ——  
            _buildGameCard(
              context,
              title: 'COMBATE',
              image: 'assets/competencia.png',
              buttonText: 'Entrar',
              onTap: () async {
                if (isCompetitor) {
                  SocketService.setCompetitionUserEmail(email);
                  await SocketService.initWaitingSocket();
                  final sid = SocketService.currentSessionId!;
                  context.go('/jocs/open/$sid');
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Acceso denegado'),
                      content: const Text('No estás autorizado para jugar a la competencia.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))
                      ],
                    ),
                  );
                }
              },
            ),
            /*
            const SizedBox(height: 24),
            _buildGameCard(
              context,
              title: 'CURSES',
              image: 'assets/curses.png',
              buttonText: 'Entrar',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildGameCard(
              context,
              title: 'OBSTACLES',
              image: 'assets/obstacles.png',
              buttonText: 'Entrar',
              onTap: () {},
            ),*/
          ],
        ),
      ),
    );
  }

  // --- El resto se mantiene simple como la versión original ---
  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String image,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(image, width: 350, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: onTap, child: Text(buttonText)),
      ],
    );
  }
}
