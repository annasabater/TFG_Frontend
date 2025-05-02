// lib/screens/salaespera_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WaitingRoomPage extends StatefulWidget {
  const WaitingRoomPage({Key? key}) : super(key: key);
  @override
  _WaitingRoomPageState createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  IO.Socket? _socket;
  String _waitingMsg = 'Esperant a que s\'uneixin altres jugadors…';

  @override
  void initState() {
    super.initState();
    // 1) Hem de tenir ja SocketService.currentUserEmail assignat al login
    try {
      _socket = SocketService.initWaitingSocket();
    } catch (e) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Accés denegat'),
            content: Text(e.toString()),
            actions: [ TextButton(onPressed: () => context.go('/'), child: const Text('OK')) ],
          ),
        );
      });
      return;
    }

    _socket!
      ..on('waiting', (data) {
        setState(() => _waitingMsg = data['msg'] as String);
      })
      ..on('game_started', (data) {
        // guardem sessionId (si ens arriba)
        if (data['sessionId'] != null) {
          SocketService.currentSessionId = data['sessionId'] as String;
        }
        // Reciclem i inicialitzem el “game socket”
        SocketService.initGameSocket();
        // Naveguem a control de dron
        context.go('/jocs/lobby/control');
      });
  }

  @override
  void dispose() {
    SocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sala d’espera')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _waitingMsg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
