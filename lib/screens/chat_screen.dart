import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../provider/users_provider.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  const ChatScreen({super.key, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_ChatMessage>[];
  late final UserProvider _provider;
  User? _currentUser;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _provider = Provider.of<UserProvider>(context, listen: false);
      final user = _provider.currentUser;
      debugPrint('ChatScreen: currentUser = $user');

      if (user == null) {
        setState(() => _loadingUser = false);
        return;
      }

      _currentUser = user;
      setState(() => _loadingUser = false);

      await SocketService.initChatSocket();
      SocketService.onNewMessage(_handleNewMessage);

      await _loadHistory();
      _scrollToBottom();
    });
  }

  void _handleNewMessage(dynamic raw) {
    final msg = Message.fromJson(raw as Map<String, dynamic>);
    final partnerId = msg.senderId == _currentUser!.id
        ? msg.receiverId
        : msg.senderId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.addConversation(partnerId);
      setState(() {
        _messages.add(_ChatMessage(
          senderId: msg.senderId,
          text: msg.content,
          timestamp: msg.timestamp ?? DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  Future<void> _loadHistory() async {
    if (_currentUser == null) return;
    try {
      final jwt = await AuthService().token;
      final url = Uri.parse(
        '${AuthService().baseApiUrl}/messages/${_currentUser!.id}/${widget.userId}',
      );
      final resp = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );
      if (resp.statusCode == 200) {
        final data = (jsonDecode(resp.body) as List<dynamic>);
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

    final msg = _ChatMessage(
      senderId: _currentUser!.id!,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(msg);
    });
    _scrollToBottom();

    SocketService.sendChatMessage(
      senderId: _currentUser!.id!,
      receiverId: widget.userId,
      content: text,
    );

    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    SocketService.disposeChat();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('No estás logueado')),
      );
    }

    final peer = _provider.users.firstWhere(
      (u) => u.id == widget.userId,
      orElse: () => User(id: '', userName: 'Unknown', email: '', role: ''),
    );

    return Scaffold(
      appBar: AppBar(title: Text(peer.userName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isMe = msg.senderId == _currentUser!.id;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.blueAccent
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...'
                    ),
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
