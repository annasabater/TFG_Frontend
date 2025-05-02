import 'package:socket_io_client/socket_io_client.dart' as IO;

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

  /// Ha de cridar-se just després del login
  static void setUserEmail(String email) {
    currentUserEmail = email.trim().toLowerCase();
  }

  /// Inicialitza la sala d'espera (namespace `/jocs`)
  static IO.Socket initWaitingSocket() {
    final email = currentUserEmail;
    if (email == null || !_competitorEmails.contains(email)) {
      throw Exception('Usuari $email no autoritzat per competir');
    }
    if (_socket != null && _socket!.connected) return _socket!;

    _socket = IO.io(
      'http://localhost:8000/jocs',
      IO.OptionBuilder()
          .setTransports(['websocket'])
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

  /// Un cop rebem `game_started`, cridem això per entrar a la sala amb sessionId
  static IO.Socket initGameSocket() {
    final sid = currentSessionId;
    if (sid == null) throw Exception('Falta sessionId. Espera game_started.');

    // Ens desconnectem 
  _socket!.disconnect();

    _socket = IO.io(
      'http://localhost:8000/jocs',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'sessionId': currentSessionId})
          .build(),
    ); 

    _socket!
      ..onConnect((_) => print('🎮 Connectat a /jocs (game, session=$sid)'));

    return _socket!;
  }

  /// Envia una comanda al servidor
  static void sendCommand(String action, Map<String, dynamic> payload) {
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Socket no connectat');
      return;
    }
    _socket!.emit('command', {
      'sessionId': currentSessionId,
      'action': action,
      'payload': payload,
    });
  }

  /// Desconnecta i neteja estat
  static void dispose() {
    _socket?.disconnect();
    _socket = null;
    currentSessionId = null;
  }
}
