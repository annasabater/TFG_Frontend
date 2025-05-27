// lib/screens/social/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/social_service.dart';
import '../../models/post.dart';
import '../../services/auth_service.dart';
import '../../widgets/video_player_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Post> _future;
  final String? _myId = AuthService().currentUser?['_id'];

  @override
  void initState() {
    super.initState();
    _future = SocialService.getPostById(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs  = Theme.of(context).colorScheme;

    return FutureBuilder<Post>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || !snap.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(loc.error)),
          );
        }

        final post   = snap.data!;
        final isMine = post.authorId == _myId;

        return Scaffold(
          appBar: AppBar(
            // Botón de retroceso que manda al perfil del autor
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/u/${post.authorId}');
              },
            ),
            title: Text(post.authorName),
            actions: [
              if (isMine)
                PopupMenuButton<_PostMenu>(
                  onSelected: (choice) async {
                    switch (choice) {
                      case _PostMenu.edit:
                        context.push('/posts/${post.id}/edit', extra: post);
                        break;
                      case _PostMenu.delete:
                        final confirm = await _confirmDelete(context, loc);
                        if (confirm) {
                          await SocialService.deletePost(post.id);
                          if (mounted) {
                            // Tras borrar, volvemos también al perfil
                            context.go('/u/${post.authorId}');
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _PostMenu.edit,
                      child: Text(loc.edit),
                    ),
                    PopupMenuItem(
                      value: _PostMenu.delete,
                      child: Text(loc.delete),
                    ),
                  ],
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Imagen o vídeo, visible por completo dentro de un contenedor
              if (post.mediaType == 'image') ...[
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 300,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        post.mediaUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 300,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: VideoPlayerWidget(url: post.mediaUrl),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Botón de like simplificado
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.likedByMe ? Icons.favorite : Icons.favorite_border,
                      color: cs.error,
                    ),
                    onPressed: () async {
                      await SocialService.like(post.id);
                      setState(() {
                        post.likedByMe = !post.likedByMe;
                        post.likes += post.likedByMe ? 1 : -1;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text('${post.likes} likes',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),

              const Divider(height: 32),

              if ((post.description ?? '').isNotEmpty)
                Text(post.description!,
                    style: Theme.of(context).textTheme.bodyLarge),

              const SizedBox(height: 24),
              Text(loc.comments,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              if (post.comments.isEmpty)
                Text(loc.noComments,
                    style: TextStyle(color: cs.outline)),
              ...post.comments.map(
                (c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text(c.authorName[0])),
                  title: Text(c.authorName,
                      style: const TextStyle(fontSize: 14)),
                  subtitle: Text(c.content),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx, AppLocalizations loc) async {
    return (await showDialog<bool>(
          context: ctx,
          builder: (c) => AlertDialog(
            title: Text(loc.delete),
            content: Text(loc.deleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(loc.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(c, true),
                child: Text(loc.accept),
              ),
            ],
          ),
        )) ??
        false;
  }
}

enum _PostMenu { edit, delete }
