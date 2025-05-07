// lib/screens/waiting_room_page.dart
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
  String _waitingMsg = 'Esperando a que el profesor inicie la partida…';

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  Future<void> _initSocket() async {
    try {
      _socket = await SocketService.initWaitingSocket();
      _socket!
        ..on('waiting', (data) {
          setState(() => _waitingMsg = data['msg']);
        })
        ..on('game_started', (data) async {
          await SocketService.initGameSocket();
          if (context.mounted) context.go('/jocs/control');
        });
    } catch (e) {
      // Si algo falla, volvemos al home con error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
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
  void dispose() {
    SocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sala de espera')),
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
