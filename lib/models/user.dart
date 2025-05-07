// lib/models/user.dart
class User {
  final String? id;
  final String userName;
  final String email;
  final String role;
  final String? password;

  User({
    this.id,
    required this.userName,
    required this.email,
    required this.role,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id:       json['_id']?.toString() ?? '',
        userName: (json['userName'] ?? json['username'] ?? '').toString(),
        email:    (json['email']    ?? '').toString(),
        role:     (json['role']     ?? '').toString(),
        // password pot no venir del backend
      );

  Map<String, dynamic> toJson() => {
        '_id':      id,
        'userName': userName,
        'email':    email,
        'role':     role,
      };
}
