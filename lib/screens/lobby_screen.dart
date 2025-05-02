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
    // Cogemos el email del usuario logueado
    final userProvider = context.read<UserProvider>();
    final email = userProvider.currentUser?.email;
    if (email == null) {
      // No hay usuario, redirigimos al login
      if (context.mounted) context.go('/login');
      return;
    }

    // Lo registramos en el SocketService (por si no lo hiciste en el login)
    SocketService.setUserEmail(email);

    // Inicializamos la sala d'espera
    try {
      _socket = SocketService.initWaitingSocket();
    } catch (e) {
      // Si no es competitor (no está en la lista autorizada), mostramos un error
      WidgetsBinding.instance!.addPostFrameCallback((_) {
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
      return;
    }

    // Escuchamos los eventos
    _socket!
      ..on('waiting', (data) {
        setState(() {
          _waitingMsg = data['msg'] as String;
        });
      })
      ..on('game_started', (data) {
        final sid = data['sessionId'] as String?;
        if (sid != null) {
          SocketService.currentSessionId = sid;
        }
        // Navegamos a la pantalla de control del dron
        if (context.mounted) context.go('/jocs/lobby/control');
      })
      ..on('connect_error', (err) {
        // Ojo a errores de auth, token, etc.
        print('Connect error: $err');
      });
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
