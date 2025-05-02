// lib/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:SkyNet/services/auth_service.dart';

class SocketService {
  static String? currentUserEmail;
  static String? currentSessionId;
  static IO.Socket? _socket;

  static const _competitorEmails = {
    'dron_azul1@upc.edu',
    'dron_verde1@upc.edu',
    'dron_rojo1@upc.edu',
    'dron_amarillo1@upc.edu',
  };

  /// Debe llamarse justo después de que login() sea exitoso
  static void setUserEmail(String email) {
    currentUserEmail = email.trim().toLowerCase();
  }

  /// Obtiene el JWT actual o lanza si no hay
  static String _getJwt() {
    return AuthService().token;
  }

  /// Inicializa la sala de espera (namespace `/jocs`)
  static IO.Socket initWaitingSocket() {
    final email = currentUserEmail;
    if (email == null || !_competitorEmails.contains(email)) {
      throw Exception('Usuari $email no autoritzat per competir');
    }
    if (_socket != null && _socket!.connected) return _socket!;

    _socket = IO.io(
      'http://localhost:9000/jocs',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': _getJwt()})
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        print('Connectat a /jocs (waiting room)');
        _socket!.emit('join', {'email': email});
      });

    return _socket!;
  }

  /// Tras recibir `game_started`, inicializa el socket de juego
  static IO.Socket initGameSocket() {
    final sid = currentSessionId;
    if (sid == null) throw Exception('Falta sessionId. Espera game_started.');
    _socket!.disconnect();

    _socket = IO.io(
      'http://localhost:9000/jocs',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': _getJwt()})
          .setQuery({'sessionId': sid})
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) =>
          print('🎮 Connectat a /jocs (game, session=$sid)'));

    return _socket!;
  }

  /// Envía una orden al servidor
  static void sendCommand(String action, Map<String, dynamic> payload) {
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Socket no connectat');
      return;
    }
    _socket!.emit('control', {
      'sessionId': currentSessionId,
      'action': action,
      'payload': payload,
    });
  }

  /// Desconecta y limpia estado
  static void dispose() {
    _socket?.disconnect();
    _socket = null;
    currentSessionId = null;
  }
}
