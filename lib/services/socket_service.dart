// lib/services/socket_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:SkyNet/services/auth_service.dart';

typedef VoidCallback = void Function();

class SocketService {
  static bool _envLoaded = false;

  /// Callback que se dispara al recibir `game_started`
  static VoidCallback? onGameStarted;

  static String? currentUserEmail;
  static String? currentSessionId;
  static IO.Socket? _socket;
  static IO.Socket? _chatSocket;
  static late String serverUrl;
  static late String jwt;
  static late String chatJwt;

  static const Map<String, String> _colorMapping = {
    'dron_azul1@upc.edu':     'azul',
    'dron_verde1@upc.edu':    'verde',
    'dron_rojo1@upc.edu':     'rojo',
    'dron_amarillo1@upc.edu': 'amarillo',
  };

  static Future<void> _ensureEnvLoaded() async {
    if (_envLoaded) return;
    await dotenv.load(fileName: '.env');
    _envLoaded = true;
    serverUrl = dotenv.env['SERVER_URL'] ?? 'http://localhost:9000';
  }

  /// Registra el email del usuario actual
  static void setUserEmail(String email) {
    currentUserEmail = email.trim().toLowerCase();
  }

  /// Para entornos de competición: fija email y sesión
  static void setCompetitionUserEmail(String email) {
    final e = email.trim().toLowerCase();
    if (!_colorMapping.containsKey(e)) {
      throw Exception('Usuario no autorizado para competir');
    }
    currentUserEmail = e;
    currentSessionId = '1';
  }

  static IO.Socket? get socketInstance => _socket;

  static String get _wsBaseUrl {
    final raw = dotenv.env['SERVER_URL'] ?? 'http://localhost:9000';
    return raw.replaceFirst(RegExp(r'^http'), 'ws');
  }

  /// Permite a otros registrar un callback para cuando empiece el juego
  static void registerOnGameStarted(VoidCallback? callback) {
    onGameStarted = callback;
  }

  /// Inicia (o devuelve) el socket de "espera" (/jocs)
  static Future<IO.Socket> initWaitingSocket() async {
    await _ensureEnvLoaded();
    if (_socket != null) return _socket!;

    final sid = currentSessionId;
    final email = currentUserEmail;
    if (sid == null || email == null) {
      throw Exception('Session o email no definido');
    }

    // Hacemos login automático del dron correspondiente
    final colorKey   = _colorMapping[email]!;
    final envEmail   = 'DRON_${colorKey.toUpperCase()}_EMAIL';
    final envPwd     = 'DRON_${colorKey.toUpperCase()}_PASSWORD';
    final droneEmail = dotenv.env[envEmail];
    final dronePwd   = dotenv.env[envPwd];
    if (droneEmail == null || dronePwd == null) {
      throw Exception('Faltan credenciales en .env: $envEmail o $envPwd');
    }

    // Petición para obtener JWT de dron
    final loginUrl = '${dotenv.env['SERVER_URL']}/api/auth/login';
    final resp = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': droneEmail, 'password': dronePwd}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Login fallido para $colorKey: ${resp.body}');
    }
    final data  = jsonDecode(resp.body) as Map<String, dynamic>;
    jwt         = data['accesstoken'] as String? ?? '';
    if (jwt.isEmpty) {
      throw Exception('No se obtuvo accesstoken para dron $colorKey');
    }

    // Crear socket
    _socket = IO.io(
      '$_wsBaseUrl/jocs',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': jwt})
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        debugPrint('Connected to /jocs (sessionId=$sid)');
        _socket!.emit('join', {'sessionId': sid});
      })
      ..on('waiting', (data) {
        debugPrint('Waiting: ${data['msg']}');
      })
      ..on('game_started', (data) {
        debugPrint('Game started (SocketService)');
        // Disparamos el callback si está registrado
        if (onGameStarted != null) onGameStarted!();
      })
      ..onConnectError((err) => debugPrint('Jocs connect error: $err'))
      ..onError((err)        => debugPrint('Jocs socket error: $err'));

    _socket!.connect();
    return _socket!;
  }

  /// Fuerza reconexión al "socket de juego"
  static Future<IO.Socket> initGameSocket() async {
    _socket?.disconnect();
    return initWaitingSocket();
  }

  /// Enviar comando de control al servidor
  static void sendCommand(String action, Map<String, dynamic> payload) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('Game socket not connected');
      return;
    }
    _socket!.emit('control', {
      'sessionId': currentSessionId,
      'action': action,
      'payload': payload,
    });
  }

  /// Cierra y resetea el socket de juego
  static void dispose() {
    _socket?.disconnect();
    _socket = null;
    onGameStarted = null;
    currentUserEmail = null;
    currentSessionId = null;
  }

  /// Inicia el socket de chat (/chat)
  static Future<IO.Socket> initChatSocket() async {
    if (_chatSocket != null && _chatSocket!.connected) {
      return _chatSocket!;
    }

    final token = await AuthService().token;
    final base  = AuthService().webSocketBaseUrl;
    final url   = base.replaceFirst(RegExp(r'^http'), 'ws') + '/chat';

    _chatSocket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _chatSocket!
      ..onConnect((_)         => debugPrint('Connected to /chat'))
      ..on('new_message', (d) => debugPrint('New msg: $d'))
      ..onConnectError((e)    => debugPrint('Chat connect error: $e'))
      ..onError((e)           => debugPrint('Chat socket error: $e'));

    _chatSocket!.connect();
    return _chatSocket!;
  }

  /// Enviar mensaje de chat
  static void sendChatMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    if (_chatSocket == null || !_chatSocket!.connected) {
      debugPrint('Chat socket not connected');
      return;
    }
    _chatSocket!.emit('send_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  /// Registrar callback para nuevos mensajes
  static void onNewMessage(void Function(dynamic) callback) {
    _chatSocket?.on('new_message', callback);
  }

  /// Desconectar socket de chat
  static void disposeChat() {
    _chatSocket?.disconnect();
    _chatSocket = null;
  }
}
