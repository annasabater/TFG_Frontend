// lib/screens/lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../services/socket_service.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  Socket? _socket;
  List<dynamic> _participants = [];

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  void _connect() async {
    final sid = SocketService.currentSessionId!;
    final socket = await SocketService.initLobbySocket();
    _socket = socket;

    socket.on('connect', (_) {
      socket.emit('join_lobby', {'sessionId': sid});
    });

    socket.on('lobby_update', (data) {
      final list = data['participants'];
      if (list is List) setState(() => _participants = List.from(list));
    });

    socket.on('game_start', (data) {
      context.go('/jocs/lobby/control');
    });
  }

  @override
  Widget build(BuildContext context) {
    final sid = SocketService.currentSessionId ?? '—';
    return Scaffold(
      appBar: AppBar(title: Text('Lobby: $sid')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Jugadores conectados:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, i) {
                final user = _participants[i]['user'] ?? {};
                final name = user['userName']?.toString() ?? '';
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(name),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Esperando al profesor…',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
