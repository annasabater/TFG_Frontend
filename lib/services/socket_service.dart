// lib/services/socket_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:SkyNet/services/auth_service.dart';

typedef VoidCallback = void Function();

class SocketService {
  static bool _envLoaded = false;

  static VoidCallback? onGameStarted;

  static String? currentUserEmail;
  static String? currentSessionId;
  static IO.Socket? _socket;
  static IO.Socket? _chatSocket;
  static late String jwt;

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
  }

  /// Base HTTP (para REST, login, y web-socket en web)
  static String get httpBase {
    final raw = dotenv.env['SERVER_URL'];
    if (raw != null && raw.isNotEmpty) {
      return raw.replaceFirst(RegExp(r'/api/?$'), '');
    }
    if (kIsWeb) {
      final uri = Uri.base;
      final port = (uri.hasPort && uri.port != 80 && uri.port != 443)
          ? ':${uri.port}'
          : '';
      return '${uri.scheme}://${uri.host}$port';
    }
    return 'http://localhost:9000';
  }

  /// Base WS (wss:// o ws://) para móvil/desktop
  static String get wsBase {
    if (httpBase.startsWith('https')) {
      return httpBase.replaceFirst('https', 'wss');
    } else {
      return httpBase.replaceFirst('http', 'ws');
    }
  }

  /// URL pública para websockets (usa wsBase en nativas, httpBase en web)
  static String get baseUrl => kIsWeb ? httpBase : wsBase;

  static void setUserEmail(String email) {
    currentUserEmail = email.trim().toLowerCase();
  }

  static void setCompetitionUserEmail(String email) {
    final e = email.trim().toLowerCase();
    if (!_colorMapping.containsKey(e)) {
      throw Exception('Usuari no autoritzat per competir');
    }
    currentUserEmail = e;
    currentSessionId = '1';
  }

  static IO.Socket? get socketInstance => _socket;

  static void registerOnGameStarted(VoidCallback? callback) {
    onGameStarted = callback;
  }

  /// Inicializa el socket de espera / lobby
  static Future<IO.Socket> initWaitingSocket() async {
    await _ensureEnvLoaded();
    if (_socket != null) return _socket!;

    final sid   = currentSessionId;
    final email = currentUserEmail;
    if (sid == null || email == null) {
      throw Exception('Session o email no definit');
    }

    // Credenciales de dron según color
    final colorKey   = _colorMapping[email]!;
    final envEmail   = 'DRON_${colorKey.toUpperCase()}_EMAIL';
    final envPwd     = 'DRON_${colorKey.toUpperCase()}_PASSWORD';
    final droneEmail = dotenv.env[envEmail];
    final dronePwd   = dotenv.env[envPwd];
    if (droneEmail == null || dronePwd == null) {
      throw Exception('Falten credencials en .env: $envEmail o $envPwd');
    }

    // 🔧 Login para obtener JWT
    final apiBase  = '${httpBase}/api';
    final loginUrl = '$apiBase/auth/login';

    final resp = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': droneEmail, 'password': dronePwd}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Login fallit per $colorKey: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    jwt = data['accesstoken'] as String? ?? '';
    if (jwt.isEmpty) {
      throw Exception('No s\'ha obtingut accessToken per al dron $colorKey');
    }

    // Conexión al namespace /jocs
    final socketUrl = '$baseUrl/jocs';
    final builder = IO.OptionBuilder()
      // 🔒 Solo WebSocket (sin polling)
      .setTransports(['websocket'])
      .setAuth({'token': jwt});

    // Cabecera ngrok únicamente en móviles/escritorio
    if (!kIsWeb) {
      builder.setExtraHeaders({'ngrok-skip-browser-warning': 'true'});
    }

    _socket = IO.io(
      socketUrl,
      builder
        .disableAutoConnect()
        .build(),
    );

    _socket!
      ..onConnect((_) => _socket!.emit('join', {'sessionId': sid}))
      ..on('waiting', (_) {})
      ..on('game_started', (_) {
        if (onGameStarted != null) onGameStarted!();
      })
      ..onConnectError((_) {})
      ..onError((_) {});

    _socket!.connect();
    return _socket!;
  }

  /// Reinicia la conexión (p. ej. tras un endCompetition)
  static Future<IO.Socket> initGameSocket() async {
    _socket?.disconnect();
    _socket = null;
    return initWaitingSocket();
  }

  /// Envia comandos de control (move, fire…)
  static void sendCommand(String action, Map<String, dynamic> payload) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit('control', {
      'sessionId': currentSessionId,
      'action': action,
      'payload': payload,
    });
  }

  static void dispose() {
    _socket?.disconnect();
    _socket = null;
    onGameStarted    = null;
    currentUserEmail = null;
    currentSessionId = null;
  }

  /// Namespace de chat (igual que antes)
  static Future<IO.Socket> initChatSocket() async {
    if (_chatSocket != null && _chatSocket!.connected) {
      return _chatSocket!;
    }
    final token = await AuthService().token;
    final base  = AuthService().webSocketBaseUrl;
    final url   = '$base/chat';

    _chatSocket = IO.io(
      url,
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .disableAutoConnect()
        .build(),
    );

    _chatSocket!
      ..onConnect((_)       {})
      ..on('new_message', (_) {})
      ..onConnectError((_)  {})
      ..onError((_)         {});

    _chatSocket!.connect();
    return _chatSocket!;
  }

  static void sendChatMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    if (_chatSocket == null || !_chatSocket!.connected) return;
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
