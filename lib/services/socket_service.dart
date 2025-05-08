// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:SkyNet/services/auth_service.dart';

class SocketService {
  // Para competiciones (/jocs)
  static String? currentUserEmail;
  static String? currentSessionId;
  static IO.Socket? _socket;

  // Para chat (/chat)
  static IO.Socket? _chatSocket;

  /// Tras login en AuthService, llama a esto con el email del usuario.
  static void setUserEmail(String email) {
    final e = email.trim().toLowerCase();
    currentUserEmail = e;
    const mapping = {
      'dron_azul1@upc.edu':    'azul',
      'dron_verde1@upc.edu':   'verde',
      'dron_rojo1@upc.edu':    'rojo',
      'dron_amarillo1@upc.edu':'amarillo',
    };
    currentSessionId = mapping[e];
    if (currentSessionId == null) {
      throw Exception('Usuario no autorizado para competir');
    }
  }

  /// JWT para WS
  static Future<String> _getJwt() => AuthService().token;

  /// Base URL para WS (quita '/api')
  static String get _wsBaseUrl => AuthService().webSocketBaseUrl;

  /// Permite usar el socket de juego en DroneControlPage
  static IO.Socket? get socketInstance => _socket;

  //----------------------------------------------------------------------  
  // Sala de espera y juego (/jocs)  
  //----------------------------------------------------------------------

  /// Conecta (o reutiliza) /jocs y se une a la sesión.
  static Future<IO.Socket> initWaitingSocket() async {
    if (_socket != null && _socket!.connected) return _socket!;

    final token = await _getJwt();
    final sid = currentSessionId;
    if (sid == null) throw Exception('sessionId no definido');

    _socket = IO.io(
      '$_wsBaseUrl/jocs',
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
      ..on('waiting', (data) => print('Waiting: ${data['msg']}'))
      ..on('game_started', (_) => print('Game started'))
      ..onConnectError((err) => print('Jocs connect error: $err'))
      ..onError((err)        => print('Jocs socket error: $err'));

    _socket!.connect();
    return _socket!;
  }

  /// Tras game_started, reconecta (útil para DroneControlPage)
  static Future<IO.Socket> initGameSocket() async {
    _socket?.disconnect();
    return await initWaitingSocket();
  }

  /// Envía comando al servidor de juego.
  /// El payload debe incluir lo que necesites, el sessionId se añade aquí.
  static void sendCommand(String action, Map<String, dynamic> payload) {
    if (_socket == null || !_socket!.connected) {
      print('⚠️ Game socket not connected');
      return;
    }
    _socket!.emit('control', {
      'sessionId': currentSessionId,
      'action': action,
      'payload': payload,
    });
  }

  /// Desconecta el WS de /jocs.
  static void dispose() {
    _socket?.disconnect();
    _socket = null;
    currentUserEmail = null;
    currentSessionId = null;
  }

  //----------------------------------------------------------------------  
  // Chat (/chat)  
  //----------------------------------------------------------------------

  /// Conecta (o reutiliza) el socket de chat.
  static Future<IO.Socket> initChatSocket() async {
    if (_chatSocket != null && _chatSocket!.connected) return _chatSocket!;

    final token = await _getJwt();

    _chatSocket = IO.io(
      '$_wsBaseUrl/chat',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .disableAutoConnect()
        .build(),
    );

    _chatSocket!
      ..onConnect((_) => print('⚡ Connected to /chat'))
      ..on('new_message', (data) => print('New msg: $data'))
      ..onConnectError((err) => print('Chat connect error: $err'))
      ..onError((err)        => print('Chat socket error: $err'));

    _chatSocket!.connect();
    return _chatSocket!;
  }

  /// Envía un mensaje al chat.
  /// Usa el `senderId` y `receiverId` que tú pases.
  static void sendChatMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    if (_chatSocket == null || !_chatSocket!.connected) {
      print('⚠️ Chat socket not connected');
      return;
    }
    _chatSocket!.emit('send_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  /// Registra callback para nuevos mensajes entrantes.
  static void onNewMessage(void Function(dynamic message) callback) {
    _chatSocket?.on('new_message', callback);
  }

  /// Desconecta el WS de chat.
  static void disposeChat() {
    _chatSocket?.disconnect();
    _chatSocket = null;
  }
}
