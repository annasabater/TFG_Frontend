// lib/screens/social/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/post.dart';
import '../../provider/social_provider.dart';
import '../../services/social_service.dart';
import '../../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  final _commentCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final post = await SocialService.getPost(widget.postId);
    setState(() {
      _post = post;
      _loading = false;
    });
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    await SocialService.comment(_post!.id, _commentCtrl.text.trim());
    _commentCtrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<SocialProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      PostCard(
                        post: _post!,
                        onLike: () => prov.toggleLike(_post!),
                      ),
                      const Divider(),
                      ..._post!.comments.map(
                        (c) => ListTile(
                          leading: CircleAvatar(
                            child: Text(c.authorName[0]),
                          ),
                          title: Text(c.authorName),
                          subtitle: Text(c.content),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Añadir comentario…',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
