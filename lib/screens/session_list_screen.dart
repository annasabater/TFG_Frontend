import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/users_provider.dart';
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
    final isCompetitor = context.read<UserProvider>().isCompetitor;
    if (!isCompetitor) {
      // no hauria d’arribar mai aquí
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Accés denegat'),
            content: const Text('No pots accedir a les sessions de competició.'),
            actions: [
              TextButton(onPressed: () => context.go('/'), child: const Text('OK')),
            ],
          ),
        );
      });
      _future = Future.value([]);
    } else {
      _future = SessionService().fetchOpenSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions Obertes')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (c, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final sessions = snap.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No hi ha sessions disponibles'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (c, i) {
              final s = sessions[i];
              final id = s['_id'] as String;
              final scenario = s['scenario'] ?? '—';
              return ListTile(
                title: Text('Escenari: $scenario'),
                subtitle: Text('Host: ${s['host']}'),
                onTap: () {
                  // 1) assignem sessionId
                  SocketService.currentSessionId = id;
                  // 2) naveguem a sala d’espera
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
