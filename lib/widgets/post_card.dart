import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/post.dart';
import 'video_player_widget.dart';     

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final isImage = post.mediaType == 'image';

    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () => context.go('/posts/${post.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: true,
              leading: CircleAvatar(child: Text(post.authorName[0])),
              title: GestureDetector(
                onTap: () => context.go('/u/${post.authorId}'),
                child: Text(post.authorName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              trailing: IconButton(
                icon: Icon(
                  post.likedByMe
                      ? Icons.favorite
                      : Icons.favorite_border_outlined,
                  color: post.likedByMe ? cs.error : cs.onSurfaceVariant,
                ),
                onPressed: onLike,
              ),
            ),

            AspectRatio(
              aspectRatio: isImage ? 4 / 3 : 16 / 9,
              child: isImage
                  ? Image.network(post.mediaUrl, fit: BoxFit.cover)
                  : VideoPlayerWidget(url: post.mediaUrl),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('${post.likes} likes',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (post.description?.isNotEmpty ?? false)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(post.description!),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
