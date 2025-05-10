// lib/screens/waiting_room_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/socket_service.dart';

class WaitingRoomPage extends StatefulWidget {
  final String sessionId;
  const WaitingRoomPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  String _waitingMsg = 'Esperando a que el profesor inicie la partida…';
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _setupSocket();
  }

  Future<void> _setupSocket() async {
    _socket = await SocketService.initWaitingSocket();
    _socket!
      ..on('waiting', (data) {
        if (data is Map && data.containsKey('msg')) {
          setState(() => _waitingMsg = data['msg']);
        }
      })
      ..on('game_started', (_) {
        if (context.mounted) {
          context.go('/jocs/control/${widget.sessionId}');
        }
      });
  }

  @override
  void dispose() {
    _socket
      ?..off('waiting')
      ..off('game_started');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sala de espera')),
      body: Center(
        child: Text(
          _waitingMsg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
