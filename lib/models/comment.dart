class Comment {
  final String id;
  final String droneId;
  final String userName; // Cambiado para mostrar el nombre
  final String userEmail;
  final String text;
  final double? rating;
  final String? parentCommentId;
  final List<Comment> replies;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.droneId,
    required this.userName,
    required this.userEmail,
    required this.text,
    this.rating,
    this.parentCommentId,
    this.replies = const [],
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // userId puede ser String o Map
    String name = '';
    String email = '';
    final user = json['userId'];
    if (user is Map) {
      name = user['name'] ?? user['userName'] ?? '';
      email = user['email'] ?? '';
    } else if (user is String) {
      name = user;
    }
    return Comment(
      id: json['_id'] ?? '',
      droneId: json['droneId'] ?? '',
      userName: name,
      userEmail: email,
      text: json['text'] ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      parentCommentId: json['parentCommentId'],
      replies:
          (json['replies'] as List<dynamic>? ?? [])
              .map((e) => Comment.fromJson(e))
              .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
