import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';

class CommentsSection extends StatefulWidget {
  final String droneId;
  const CommentsSection({super.key, required this.droneId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _commentCtrl = TextEditingController();
  double? _rating;
  bool _loading = false;
  List<Comment> _comments = [];
  String? _replyTo;
  final _replyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => _loading = true);
    try {
      final service = CommentService(AuthService().baseApiUrl);
      final data = await service.getComments(widget.droneId);
      setState(() {
        _comments = data.map<Comment>((e) => Comment.fromJson(e)).toList();
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _addComment() async {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final user = userProv.currentUser;
    if (user == null || _commentCtrl.text.trim().isEmpty) return;
    final data = {
      'droneId': widget.droneId,
      'userId': user.id,
      'text': _commentCtrl.text.trim(),
      if (_rating != null) 'rating': _rating!.round(),
    };
    setState(() => _loading = true);
    try {
      final service = CommentService(AuthService().baseApiUrl);
      final token = await AuthService().token;
      await service.addComment(data, token);
      _commentCtrl.clear();
      _rating = null;
      await _fetchComments();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _addReply(String parentId) async {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final user = userProv.currentUser;
    if (user == null || _replyCtrl.text.trim().isEmpty) return;
    final data = {
      'droneId': widget.droneId,
      'userId': user.id,
      'text': _replyCtrl.text.trim(),
      'parentCommentId': parentId,
    };
    setState(() => _loading = true);
    try {
      final service = CommentService(AuthService().baseApiUrl);
      final token = await AuthService().token;
      await service.addComment(data, token);
      _replyCtrl.clear();
      _replyTo = null;
      await _fetchComments();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Widget _buildComment(Comment c) {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final user = userProv.currentUser;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  c.userId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (c.rating != null)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Text('${c.rating!.toStringAsFixed(1)}'),
                    ],
                  ),
                const Spacer(),
                Text(
                  '${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(c.text),
            if (_replyTo == c.id)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _replyCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Responder...',
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _addReply(c.id),
                          child: const Text('Enviar'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _replyTo = null),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_replyTo != c.id)
              TextButton(
                onPressed:
                    user != null ? () => setState(() => _replyTo = c.id) : null,
                child: const Text('Responder'),
              ),
            if (c.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Column(children: c.replies.map(_buildReply).toList()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReply(Comment c) {
    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  c.userId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(c.text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final user = userProv.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text('Comentarios', style: Theme.of(context).textTheme.titleMedium),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!_loading && _comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No hay comentarios.'),
          ),
        if (!_loading && _comments.isNotEmpty)
          ..._comments.map(_buildComment).toList(),
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un comentario...',
                  ),
                ),
                Row(
                  children: [
                    DropdownButton<double>(
                      value: _rating,
                      hint: const Text('Puntuación'),
                      items:
                          [1, 2, 3, 4, 5]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.toDouble(),
                                  child: Text('$e ⭐'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _addComment,
                      child: const Text('Comentar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (user == null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Inicia sesión para comentar.'),
          ),
      ],
    );
  }
}
