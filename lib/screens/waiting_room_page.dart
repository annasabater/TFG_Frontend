//lib/screens/waiting_room_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WaitingRoomPage extends StatefulWidget {
  const WaitingRoomPage({Key? key}) : super(key: key);
  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  IO.Socket? _socket;
  String _waitingMsg = 'Esperando a que el profesor inicie la partida…';

  @override
  void initState() {
    super.initState();

    // Validar email para competición (lanza excepción si no autorizado)
    try {
      final email = context.read<UserProvider>().currentUser!.email;
      SocketService.setCompetitionUserEmail(email);
    } catch (e) {
      // Mostrar error y volver al home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      });
      return;
    }

    // Registrar callback para game_started
    SocketService.registerOnGameStarted(() async {
      await SocketService.initGameSocket();
      if (context.mounted) context.go('/jocs/control');
    });

    // Conectar al socket de sala de espera
    _initSocket();
  }

  Future<void> _initSocket() async {
    try {
      _socket = await SocketService.initWaitingSocket();
      _socket!
        ..on('waiting', (data) {
          if (data is Map<String, dynamic> && data.containsKey('msg')) {
            setState(() => _waitingMsg = data['msg'] as String);
          }
        });
      // El event 'game_started' lo manejará el callback de arriba.
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error de conexión'),
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
