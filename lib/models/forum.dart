class Forum {
  final String id;
  final String name;
  final String comment;

  Forum({
    required this.id,
    required this.name,
    required this.comment,
  });

  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['_id'] as String,
      name: json['name'] as String,
      comment: json['comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'comment': comment,
    };
  }
}
