//jocs_page.dart
/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JocsPage extends StatelessWidget {
  const JocsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jocs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.sports_esports),
            title: const Text('Competencia'),
            onTap: () {
              context.go('/jocs/competencia');
            },
          ),
        ],
      ),
    );
  }
}
*/

// lib/screens/jocs_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/users_provider.dart';

class JocsPage extends StatelessWidget {
  const JocsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompetitor = context.watch<UserProvider>().isCompetitor;
    return Scaffold(
      appBar: AppBar(title: const Text('Juegos')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (isCompetitor) {
              context.go('/jocs/open');
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
          child: const Text('Competencia'),
        ),
      ),
    );
  }
}

