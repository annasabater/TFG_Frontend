// lib/screens/lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';
import '../services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  IO.Socket? _socket;
  String _waitingMsg = 'Esperant que el professor iniciï la partida…';

  @override
  void initState() {
    super.initState();
    _connectWaitingRoom();
  }

  @override
  void dispose() {
    SocketService.dispose();
    super.dispose();
  }

  Future<void> _connectWaitingRoom() async {
    final userProvider = context.read<UserProvider>();
    final email = userProvider.currentUser?.email;
    if (email == null) {
      if (context.mounted) context.go('/login');
      return;
    }
    SocketService.setUserEmail(email);

    try {
      final socket = await SocketService.initWaitingSocket();
      setState(() => _socket = socket);
      socket
        ..on('waiting', (data) {
          setState(() => _waitingMsg = data['msg'] as String);
        })
        ..on('game_started', (data) {
          final sid = data['sessionId'] as String?;
          if (sid != null) {
            SocketService.currentSessionId = sid;
          }
          if (context.mounted) context.go('/jocs/lobby/control');
        })
        ..on('connect_error', (err) {
          print('Connect error: $err');
        });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Accés denegat'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sala d’espera')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Text(
            _waitingMsg,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}