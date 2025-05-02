// lib/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketService {
  /// Socket del lobby (`/lobby`)
  static IO.Socket? lobbySocket;

  /// Socket del juego (`/game`)
  static IO.Socket? gameSocket;

  /// Guarda el sessionId seleccionado globalmente
  static String? currentSessionId;

  static const _storage = FlutterSecureStorage();

  /// Inicializa el socket para el namespace `/lobby`
  static Future<IO.Socket> initLobbySocket() async {
    final token = await _storage.read(key: 'jwtToken');
    lobbySocket = IO.io(
      'http://<TU_BACKEND_IP>:9000/lobby',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    return lobbySocket!;
  }

  /// Inicializa el socket para el namespace `/game`
  static Future<IO.Socket> initGameSocket() async {
    final token = await _storage.read(key: 'jwtToken');
    final sid = currentSessionId!;
    gameSocket = IO.io(
      'http://<TU_BACKEND_IP>:9000/game',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token, 'sessionId': sid})
          .build(),
    );
    return gameSocket!;
  }
}
