// lib/services/socket_service.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:SkyNet/services/auth_service.dart';

typedef VoidCallback = void Function();

class SocketService {
  static VoidCallback? onGameStarted;
  static String? currentUserEmail;
  static String? currentUserColor;
  static String? currentSessionId;
  static IO.Socket? _socket;
  static IO.Socket? _chatSocket;

  static const Map<String, String> _colorMapping = {
    'dron_azul1@upc.edu':     'azul',
    'dron_verde1@upc.edu':    'verde',
    'dron_rojo1@upc.edu':     'rojo',
    'dron_amarillo1@upc.edu': 'amarillo',
  };

  /// Tras login, llama a esto con el email.
  static void setUserEmail(String email) {
    currentUserEmail = email.trim().toLowerCase();
  }

  /// Valida email de competidor. Fija currentSessionId='1'.
  static void setCompetitionUserEmail(String email) {
    final e = email.trim().toLowerCase();
    currentUserEmail = e;
    currentUserColor = _colorMapping[e];
    if (currentUserColor == null) {
      throw Exception('Usuario no autorizado para competir');
    }
    currentSessionId = '1';
  }

  static Future<String> _getJwt() => AuthService().token;
  static String get _wsBaseUrl => AuthService().webSocketBaseUrl;
  static IO.Socket? get socketInstance => _socket;

  /// Registra el callback para cuando llegue 'game_started'
  static void registerOnGameStarted(VoidCallback callback) {
    onGameStarted = callback;
  }

  /// Conecta (o reutiliza) al namespace /jocs y emite 'join'
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
        print('⚡ Connected to /jocs (sessionId=$sid)');
        _socket!.emit('join', {'sessionId': sid});
      })
      ..on('waiting', (data) => print('🕒 Waiting: ${data['msg']}'))
      ..on('game_started', (_) {
        print('🚀 Game started (SocketService)');
        onGameStarted?.call();
      })
      ..onConnectError((err) => print('❌ Jocs connect error: $err'))
      ..onError((err) => print('❌ Jocs socket error: $err'));

    _socket!.connect();
    return _socket!;
  }

  /// Desconecta y reconecta (útil tras game_started)
  static Future<IO.Socket> initGameSocket() async {
    _socket?.disconnect();
    return await initWaitingSocket();
  }

  /// Envía comando 'control'
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

  /// Limpia todo
  static void dispose() {
    _socket?.disconnect();
    _socket = null;
    onGameStarted = null;
    currentUserEmail = null;
    currentUserColor = null;
    currentSessionId = null;
  }

  // --------------------- Chat ---------------------
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
      ..onError((err) => print('Chat socket error: $err'));
    _chatSocket!.connect();
    return _chatSocket!;
  }

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

  static void onNewMessage(void Function(dynamic) callback) {
    _chatSocket?.on('new_message', callback);
  }

  static void disposeChat() {
    _chatSocket?.disconnect();
    _chatSocket = null;
  }
}
