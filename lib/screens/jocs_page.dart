//jocs_page.dart
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

/*
// lib/screens/jocs_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JocsPage extends StatelessWidget {
  const JocsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Juegos')),
      body: Center(
        child: ElevatedButton(
          // Navega directamente al path /jocs/open
          onPressed: () => context.go('/jocs/open'),
          child: const Text('Competencia'),
        ),
      ),
    );
  }
}
*/

