// lib/screens/waiting_room_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/services/socket_service.dart';

class WaitingRoomPage extends StatefulWidget {
  const WaitingRoomPage({Key? key}) : super(key: key);

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  String _waitingMsg = 'Esperando a que el profesor inicie la partida…';

  @override
  void initState() {
    super.initState();

    // 1) Validar que el usuario está autorizado como competidor
    try {
      final email = context.read<UserProvider>().currentUser!.email;
      SocketService.setCompetitionUserEmail(email);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Acceso denegado'),
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

    // 2) Registrar callback ANTES de conectar
    SocketService.registerOnGameStarted(() {
      if (context.mounted) {
        context.go('/jocs/control');
      }
    });

    // 3) Conectar y suscribirnos sólo a 'waiting'
    _initSocket();
  }

  Future<void> _initSocket() async {
    try {
      final socket = await SocketService.initWaitingSocket();
      socket.on('waiting', (data) {
        if (data is Map<String, dynamic> && data.containsKey('msg')) {
          setState(() => _waitingMsg = data['msg'] as String);
        }
      });

      // ahora escuchamos 'disconnect' así:
      socket.on('disconnect', (_) {
        print('🔌 Desconectado del namespace /jocs');
      });
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
  void dispose() {
    SocketService.socketInstance
      ?..off('waiting')
      ..off('disconnect');
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
