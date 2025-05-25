class Comment {
  final String id;
  final String droneId;
  final String userId;
  final String text;
  final double? rating;
  final String? parentCommentId;
  final List<Comment> replies;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.droneId,
    required this.userId,
    required this.text,
    this.rating,
    this.parentCommentId,
    this.replies = const [],
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      droneId: json['droneId'] ?? '',
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      parentCommentId: json['parentCommentId'],
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(e))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
