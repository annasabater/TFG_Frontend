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
  late Future<Post> _futurePost;
  final String? _myId = AuthService().currentUser?['_id'];
  final _commentCtrl = TextEditingController();

  bool _submitting = false;
  bool _showCommentField = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  void _loadPost() {
    _futurePost = SocialService.getPostById(widget.postId);
  }

  Future<void> _submitComment() async {
    final txt = _commentCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await SocialService.comment(widget.postId, txt);
      _commentCtrl.clear();
      _loadPost();                // actualitzem
      setState(() => _showCommentField = false);
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.errorSendingComment(e))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deleteComment(String cid) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCommentTitle),
        content: Text(AppLocalizations.of(context)!.deleteCommentConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(AppLocalizations.of(context)!.delete)),
        ],
      ),
    );
    if (sure != true) return;

    try {
      await SocialService.deleteComment(widget.postId, cid);
      _loadPost();
      setState(() {});            // refresquem FutureBuilder
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorDeletingComment(e))),
      );
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs  = Theme.of(context).colorScheme;

    return FutureBuilder<Post>(
      future: _futurePost,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || !snap.hasData) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text(loc.error)));
        }

        final post   = snap.data!;
        final isMine = post.authorId == _myId;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(post.authorName),
            actions: [
              if (isMine)
                PopupMenuButton<_PostMenu>(
                  onSelected: (choice) async {
                    if (choice == _PostMenu.edit) {
                      context.push('/posts/${post.id}/edit', extra: post);
                    } else {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(loc.delete),
                          content: Text(loc.deleteConfirm),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: Text(loc.cancel)),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: Text(loc.accept)),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await SocialService.deletePost(post.id);
                        if (mounted) context.go('/u/${post.authorId}');
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: _PostMenu.edit,   child: Text(loc.edit)),
                    PopupMenuItem(value: _PostMenu.delete, child: Text(loc.delete)),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              // ---------- CONTINGUT ----------
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Media
                    (post.mediaType == 'image')
                        ? Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(post.mediaUrl, fit: BoxFit.contain),
                            ),
                          )
                        : Center(
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: VideoPlayerWidget(url: post.mediaUrl),
                              ),
                            ),
                          ),
                    const SizedBox(height: 12),

                    // Likes
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
                        Text(loc.likesCount(post.likes),
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

                    // Capçalera comentaris
                    Row(
                      children: [
                        Text(loc.comments,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                              _showCommentField ? Icons.expand_less : Icons.add_comment),
                          onPressed: () =>
                              setState(() => _showCommentField = !_showCommentField),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Llistat comentaris
                    if (post.comments.isEmpty)
                      Text(loc.noComments, style: TextStyle(color: cs.outline)),
                    ...post.comments.map(
                      (c) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(c.authorName[0])),
                        title: Text(c.authorName,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(c.content),
                        trailing: (c.authorId == _myId || isMine)
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteComment(c.id),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              // Input (plegable) per escriure comentari
              if (_showCommentField)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Escriu un comentari...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          enabled: !_submitting,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _submitting
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _submitComment,
                            ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _PostMenu { edit, delete }
