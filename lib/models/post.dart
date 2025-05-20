// lib/models/post.dart

class PostComment {
  String authorId;
  String authorName;
  String content;

  PostComment({
    required this.authorId,
    required this.authorName,
    required this.content,
  });

  factory PostComment.fromJson(Map<String, dynamic> j) => PostComment(
        authorId: j['author']['_id'],
        authorName: j['author']['userName'],
        content: j['content'],
      );
}

class Post {
  String id;
  String authorId;
  String authorName;
  String mediaUrl;
  String mediaType; 
  String? description;
  String? location;
  List<String> tags;
  int likes;
  bool likedByMe;
  DateTime createdAt;
  List<PostComment> comments;          

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

  factory Post.fromJson(Map<String, dynamic> j, String? myId) => Post(
        id: j['_id'],
        authorId: j['author']['_id'],
        authorName: j['author']['userName'],
        mediaUrl: j['mediaUrl'],
        mediaType: j['mediaType'],
        description: j['description'],
        location: j['location'],
        tags: List<String>.from(j['tags'] ?? []),
        likes: (j['likes'] as List).length,
        likedByMe: myId != null && (j['likes'] as List).contains(myId),
        createdAt: DateTime.parse(j['createdAt']),
        comments: (j['comments'] as List)
            .map((c) => PostComment.fromJson(c))
            .toList(),
      );
}
