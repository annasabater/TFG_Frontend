// lib/models/post.dart

import '../services/social_service.dart';   
class PostComment {
  final String authorId;
  final String authorName;
  final String content;

  PostComment({
    required this.authorId,
    required this.authorName,
    required this.content,
  });

  factory PostComment.fromJson(Map<String, dynamic> j) {
    final auth = j['author'];
    final id   = auth is Map ? (auth['_id'] ?? '') : (auth ?? '');
    final name = auth is Map ? (auth['userName'] ?? '-') : '-';
    return PostComment(
      authorId   : id,
      authorName : name,
      content    : j['content'] ?? '',
    );
  }
}

class Post {
  final String         id;
  final String         authorId;
  final String         authorName;
  final String         mediaUrl;              
  final String         mediaType;
        String?        description;
        String?        location;
  final List<String>   tags;
        int            likes;
        bool           likedByMe;
  final DateTime       createdAt;
  final List<PostComment> comments;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.mediaUrl,
    required this.mediaType,
    this.description,
    this.location,
    required this.tags,
    required this.likes,
    required this.likedByMe,
    required this.createdAt,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> j, String? myId) {
    final auth     = j['author'];
    final authorId = auth is Map ? (auth['_id'] ?? '') : (auth ?? '');
    final authorNm = auth is Map ? (auth['userName'] ?? '-') : '-';
    final rawLikes = (j['likes'] as List?) ?? const [];
    final likeIds  = rawLikes.map((e) => e is Map ? e['_id'] : e).cast<String>();

    return Post(
      id          : j['_id'] ?? '',
      authorId    : authorId,
      authorName  : authorNm,
      mediaUrl    : SocialService.absolute(j['mediaUrl'] ?? ''),  
      mediaType   : j['mediaType'] ?? 'image',
      description : j['description'],
      location    : j['location'],
      tags        : List<String>.from(j['tags'] ?? const []),
      likes       : likeIds.length,
      likedByMe   : myId != null && likeIds.contains(myId),
      createdAt   : DateTime.parse(j['createdAt'] as String),
      comments    : ((j['comments'] ?? const []) as List)
                      .map((c) => PostComment.fromJson(
                             c as Map<String, dynamic>))
                      .toList(),
    );
  }
}
