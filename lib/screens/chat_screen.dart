import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';
import '../models/user.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final currentUser = provider.currentUser;
    final user = provider.users.firstWhere((u) => u.id == widget.userId, orElse: () => User(id: '', userName: 'Usuari', email: '', role: ''));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(child: Text(user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?')),
            const SizedBox(width: 12),
            Expanded(child: Text(user.userName)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                final isMe = msg.senderId == currentUser?.id;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.black87 : Colors.grey.shade200,
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
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Missatge...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(currentUser),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(currentUser),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(User? currentUser) {
    final text = _controller.text.trim();
    if (text.isEmpty || currentUser == null) return;
    setState(() {
      _messages.add(_ChatMessage(
        senderId: currentUser.id ?? '',
        text: text,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });
  }
}

class _ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;
  _ChatMessage({required this.senderId, required this.text, required this.timestamp});
} 