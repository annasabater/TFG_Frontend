// lib/screens/spectate_sessions_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../services/session_service.dart';
import '../services/socket_service.dart';

class SpectateSessionsPage extends StatefulWidget {
  const SpectateSessionsPage({Key? key}) : super(key: key);

  @override
  State<SpectateSessionsPage> createState() => _SpectateSessionsPageState();
}

class _SpectateSessionsPageState extends State<SpectateSessionsPage> {
  late Future<List<dynamic>> _sessionsFut;
  IO.Socket? _socket;
  final List<String> _joined = [];

  @override
  void initState() {
    super.initState();
    _sessionsFut = SessionService()
        .fetchOpenSessions()
        .catchError((_) => <dynamic>[]);
    _setupSocket();
    _loadSessions();
  }

  Future<void> _setupSocket() async {
    _socket = IO.io('${SocketService.serverUrl}/jocs', {
      'transports': ['websocket'],
      'query': {'spectator': 'true'},
      'autoConnect': false,
    })..connect();

    // Usamos cascada (..) para todos los on
    _socket!
      ..on('connect', (_) {
        debugPrint('Spectate connected (or reconnected)');
        for (final id in _joined) {
          if (_socket!.connected) {
            _socket!.emit('join', {'sessionId': id});
          }
        }
      })
      ..on('waiting', (_) => _loadSessions())
      ..on('game_started', (data) {
        final sid = (data as Map)['sessionId'] as String? ?? '';
        if (sid.isNotEmpty && mounted) {
          context.go('/jocs/spectate/$sid');
        }
      })
      ..on('disconnect', (_) => debugPrint('Spectate disconnected'));
  }

  Future<void> _loadSessions() async {
    setState(() {
      _sessionsFut = SessionService()
          .fetchOpenSessions()
          .catchError((_) => <dynamic>[]);
    });

    try {
      final sessions = await _sessionsFut;
      for (final s in sessions) {
        final id = (s['_id'] ?? s['id']) as String;
        if (!_joined.contains(id) && _socket != null && _socket!.connected) {
          _socket!.emit('join', {'sessionId': id});
          _joined.add(id);
        }
      }
    } catch (_) {
      // ignoramos errores
    }
  }

  @override
  void dispose() {
    _socket
      ?..off('connect')
      ..off('waiting')
      ..off('game_started')
      ..off('disconnect');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ver partida en directo')),
      body: FutureBuilder<List<dynamic>>(
        future: _sessionsFut,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snap.data ?? [];
          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                'No hay ninguna partida inicializada',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (ctx, i) {
              final s    = sessions[i];
              final id   = (s['_id'] ?? s['id']) as String;
              final name = (s['name'] as String?) ?? 'Partida $id';
              return ListTile(
                title: Text(name),
                subtitle: Text('ID: $id'),
                trailing: const Icon(Icons.play_circle_outline),
                onTap: () {
                  SocketService.currentSessionId = id;
                  context.go('/jocs/spectate/$id');
                },
              );
            },
          );
        },
      ),
    );
  }
}
