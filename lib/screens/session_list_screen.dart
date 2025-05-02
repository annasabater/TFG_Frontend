// lib/screens/session_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/session_service.dart';
import '../services/socket_service.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({Key? key}) : super(key: key);

  @override
  _SessionListScreenState createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = SessionService().fetchOpenSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sesiones abiertas')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final sessions = snap.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No hay sesiones disponibles'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];
              final id = s['_id']?.toString() ?? '';
              final scenario = s['scenario']?.toString() ?? '---';
              final host = s['host']?.toString() ?? '---';
              return ListTile(
                title: Text("Escenario: $scenario"),
                subtitle: Text("Host: $host"),
                onTap: () {
                  // Guarda globalmente y navega sin params
                  SocketService.currentSessionId = id;
                  context.go('/jocs/lobby');
                },
              );
            },
          );
        },
      ),
    );
  }
}
