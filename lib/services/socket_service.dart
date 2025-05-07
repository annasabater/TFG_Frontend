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

  // mapeo de email a sessionId
  static const _emailToSessionId = {
    'dron_azul1@upc.edu'    : 'azul',
    'dron_verde1@upc.edu'   : 'verde',
    'dron_rojo1@upc.edu'    : 'rojo',
    'dron_amarillo1@upc.edu': 'amarillo',
  };

  /// Tras login, guarda email y le asigna sessionId fija
  static void setUserEmail(String email) {
    final e = email.trim().toLowerCase();
    if (!_competitorEmails.contains(e))
      throw Exception('Usuario no autorizado para competir');
    currentUserEmail = e;
    currentSessionId = _emailToSessionId[e];
  }

  static Future<String> _getJwt() async => await AuthService().token;

  static IO.Socket? get socketInstance => _socket;

  static Future<IO.Socket> _connectAndJoin() async {
    final token = await _getJwt();
    final sid = currentSessionId;
    if (sid == null) throw Exception('No sessionId definido');
    _socket = IO.io(
      'http://localhost:9000/jocs',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .disableAutoConnect()
        .build(),
    );
    _socket!
      ..onConnect((_) {
        print('⚡ Connected to /jocs');
        _socket!.emit('join', {'sessionId': sid});
      })
      ..onConnectError((err) => print('Connect error: $err'))
      ..onError((err) => print('Socket error: $err'));
    _socket!.connect();
    return _socket!;
  }

  /// Sala de espera
  static Future<IO.Socket> initWaitingSocket() async {
    // setUserEmail ya lanzó si no estaba autorizado
    if (_socket != null && _socket!.connected) return _socket!;
    return await _connectAndJoin();
  }

  /// Socket de juego
  static Future<IO.Socket> initGameSocket() async {
    _socket?.disconnect();
    return await _connectAndJoin();
  }

  static void sendCommand(String action, Map<String, dynamic> payload) {
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Socket no conectado');
      return;
    }
    _socket!.emit('control', {
      'sessionId': currentSessionId,
      'action':    action,
      'payload':   payload,
    });
  }

  static void dispose() {
    _socket?.disconnect();
    _socket = null;
    currentSessionId = null;
  }
}
