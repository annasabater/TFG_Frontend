import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    return InkWell(
      onTap: () => context.push('/posts/${post.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(child: Text(post.authorName[0])),
              title: GestureDetector(
                onTap: () => context.go('/u/${post.authorId}'),
                child: Text(
                  post.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(timeago.format(post.createdAt, locale: 'es')),
            ),
            (post.mediaType == 'image')
                ? Image.network(
                    post.mediaUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : const LinearProgressIndicator(),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayerWidget(url: post.mediaUrl),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.likedByMe ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: post.likedByMe ? Colors.red : null,
                    onPressed: onLike,
                  ),
                  Text('${post.likes}'),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () => context.push('/posts/${post.id}'),
                  ),
                ],
              ),
            ),
            if (post.description?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(post.description!),
              ),
          ],
        ),
      ),
    );
  }
}
