class User {
  final String? id;
  final String userName;
  final String email;
  final String password;
  final String role;

  User({
    this.id,
    required this.userName,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String?,           // si Mongo devuelve _id
      userName: json['userName'] as String,
      email: json['email'] as String,
      password: '',                          // no devolver contraseña al leer
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userName': userName,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
