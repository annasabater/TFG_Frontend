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
  String? _replyTo;
  final _replyCtrl = TextEditingController();
  Future<List<Comment>>? _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  Future<List<Comment>> _fetchComments() async {
    final service = CommentService(AuthService().baseApiUrl);
    final data = await service.getComments(widget.droneId);
    return data.map<Comment>((e) => Comment.fromJson(e)).toList();
  }

  Future<void> _refreshComments() async {
    setState(() {
      _commentsFuture = _fetchComments();
    });
  }

  Future<void> _addComment() async {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final user = userProv.currentUser;
    if (user == null || _commentCtrl.text.trim().isEmpty || _rating == null)
      return;
    final data = {
      'droneId': widget.droneId,
      'userId': user.id,
      'text': _commentCtrl.text.trim(),
      'rating': _rating!.round(),
    };
    try {
      final service = CommentService(AuthService().baseApiUrl);
      final token = await AuthService().token;
      await service.addComment(data, token);
      _commentCtrl.clear();
      _rating = null;
      await _refreshComments();
    } catch (_) {}
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
    try {
      final service = CommentService(AuthService().baseApiUrl);
      final token = await AuthService().token;
      await service.addComment(data, token);
      _replyCtrl.clear();
      _replyTo = null;
      await _refreshComments();
    } catch (_) {}
  }

  Widget _buildComment(Comment c, List<Comment> allComments) {
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
                  c.userName.isNotEmpty ? c.userName : c.userEmail,
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
                  '${c.createdAt.day.toString().padLeft(2, '0')}/'
                  '${c.createdAt.month.toString().padLeft(2, '0')}/'
                  '${c.createdAt.year}  '
                  '${c.createdAt.hour.toString().padLeft(2, '0')}:'
                  '${c.createdAt.minute.toString().padLeft(2, '0')}',
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
                child: Column(
                  children: c.replies.map((r) => _buildReply(r)).toList(),
                ),
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
                  c.userName.isNotEmpty ? c.userName : c.userEmail,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${c.createdAt.day.toString().padLeft(2, '0')}/'
                  '${c.createdAt.month.toString().padLeft(2, '0')}/'
                  '${c.createdAt.year}  '
                  '${c.createdAt.hour.toString().padLeft(2, '0')}:'
                  '${c.createdAt.minute.toString().padLeft(2, '0')}',
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
        Row(
          children: [
            Icon(Icons.comment, color: Colors.blueAccent, size: 26),
            const SizedBox(width: 8),
            Text(
              'Comentarios',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        FutureBuilder<List<Comment>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error al cargar comentarios.'),
              );
            }
            final comments = snapshot.data ?? [];
            final rootComments =
                comments.where((c) => c.parentCommentId == null).toList();
            final ratings =
                rootComments
                    .where((c) => c.rating != null)
                    .map((c) => c.rating!)
                    .toList();
            double avg = 0;
            if (ratings.isNotEmpty) {
              avg = ratings.reduce((a, b) => a + b) / ratings.length;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ratings.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ...List.generate(5, (i) {
                          if (avg >= i + 1) {
                            return const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 22,
                            );
                          } else if (avg > i && avg < i + 1) {
                            return const Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 22,
                            );
                          } else {
                            return const Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 22,
                            );
                          }
                        }),
                        const SizedBox(width: 8),
                        Text(
                          avg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${ratings.length})',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                // Mostrar el formulario para comentar siempre que el usuario esté logueado
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deja tu comentario',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _commentCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Escribe un comentario...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 8),
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
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.send),
                                  onPressed:
                                      (_commentCtrl.text.trim().isNotEmpty &&
                                              _rating != null)
                                          ? _addComment
                                          : null,
                                  label: const Text('Comentar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Mostrar todos los comentarios raíz
                ...rootComments.map((c) => _buildComment(c, comments)).toList(),
              ],
            );
          },
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
