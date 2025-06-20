// lib/screens/waiting_room_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/socket_service.dart';

class WaitingRoomPage extends StatefulWidget {
  final String sessionId;
  const WaitingRoomPage({super.key, required this.sessionId});

  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  String _waitingMsg = '';
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _setupSocket();
  }

  Future<void> _setupSocket() async {
    _socket = await SocketService.initWaitingSocket();
    _socket!
      ..on('waiting', (data) {
        if (data is Map && data.containsKey('msg')) {
          setState(() => _waitingMsg = data['msg'] as String);
        }
      })
      ..on('game_started', (_) {
        if (context.mounted) {
          context.go('/jocs/control/${widget.sessionId}');
        }
      });
  }

  @override
  void dispose() {
    _socket
      ?..off('waiting')
      ..off('game_started');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final message = _waitingMsg.isEmpty
        ? loc.waitingRoomMessage
        : _waitingMsg;

    return Scaffold(
      appBar: AppBar(title: Text(loc.waitingRoomTitle)),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
