// lib/screens/chat_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../provider/users_provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      _currentUser = provider.currentUser;
      if (_currentUser == null || _currentUser!.id == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      // Inicializamos socket sólo para recibir new_message
      SocketService.initChatSocket().then((_) {
        SocketService.onNewMessage((data) {
          setState(() {
            _messages.insert(
              0,
              _ChatMessage(
                senderId: data['senderId'] as String,
                text: data['content'] as String,
                timestamp: DateTime.parse(data['createdAt'] as String),
              ),
            );
          });
        });
      });
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    if (_currentUser == null) return;
    try {
      final jwt = await AuthService().token;
      final url = Uri.parse(
          '${AuthService().baseApiUrl}/messages/${_currentUser!.id}/${widget.userId}');
      final resp = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt'
        },
      );
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        final history = data.map((m) {
          final created = m['createdAt'] ?? m['timestamp'];
          return _ChatMessage(
            senderId: m['senderId'] as String,
            text: m['content'] as String,
            timestamp: DateTime.parse(created as String),
          );
        }).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        setState(() => _messages.addAll(history));
      }
    } catch (e) {
      debugPrint('Error cargando historial: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentUser == null) return;

    final jwt = await AuthService().token;
    final url = Uri.parse('${AuthService().baseApiUrl}/messages');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt'
      },
      body: jsonEncode({
        'senderId': _currentUser!.id,
        'receiverId': widget.userId,
        'content': text,
      }),
    );

    if (resp.statusCode == 201) {
      // Se añadirá automáticamente desde el listener de new_message
      _controller.clear();
    } else {
      // Opcional: mostrar error al enviar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando mensaje')),
      );
    }
  }

  @override
  void dispose() {
    SocketService.disposeChat();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final provider = Provider.of<UserProvider>(context);
    final peer = provider.users.firstWhere(
      (u) => u.id == widget.userId,
      orElse: () => User(id: '', userName: 'Unknown', email: '', role: ''),
    );

    return Scaffold(
      appBar: AppBar(title: Text(peer.userName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                final isMe = msg.senderId == _currentUser!.id;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;
  _ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}
