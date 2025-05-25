import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentService {
  final String baseUrl;
  CommentService(this.baseUrl);

  Future<List<dynamic>> getComments(String droneId) async {
    final uri = Uri.parse('$baseUrl/api/comments/$droneId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Error al obtener comentarios');
    }
  }

  Future<void> addComment(Map<String, dynamic> data, String token) async {
    final uri = Uri.parse('$baseUrl/api/comments');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (res.statusCode != 201) {
      throw Exception('Error al enviar comentario');
    }
  }
}
