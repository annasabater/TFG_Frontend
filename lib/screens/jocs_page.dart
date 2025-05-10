import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/users_provider.dart';
import '../services/socket_service.dart';

class JocsPage extends StatelessWidget {
  const JocsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompetitor = context.watch<UserProvider>().isCompetitor;
    final email = context.read<UserProvider>().currentUser!.email;
    return Scaffold(
      appBar: AppBar(title: const Text('Juegos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/logo_skynet.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 32),
            _buildGameCard(
              context,
              title: 'COMPETÈNCIA',
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
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
                      ],
                    ),
                  );
                }
              },
            ),
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
            ),
          ],
        ),
      ),
    );
  }

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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              image,
              width: 350,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onTap,
          child: Text(buttonText),
        ),
      ],
    );
  }
}
