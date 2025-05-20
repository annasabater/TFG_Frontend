//lib/services/social_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/post.dart';

class SocialService {
  static const _base = 'http://localhost:9000/api';


  /// Cabecera con JSON y, si existe, el JWT del usuario.
  static Map<String, String> _headers({bool multipart = false}) {
    final hdr = <String, String>{};
    if (!multipart) hdr['Content-Type'] = 'application/json';

    final dynAuth = AuthService();
    String? token;
    try {
      token = (dynAuth as dynamic).token;        
    } catch (_) {}

    if (token != null && token.isNotEmpty) {
      hdr['Authorization'] = 'Bearer $token';
    }
    return hdr;
  }

  static void _throwIfNot200(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('Error ${r.statusCode}: ${r.body}');
    }
  }

  /* ------------ Feed (gente que sigo) ------------ */

  static Future<List<Post>> getFeed({int page = 1}) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/feed?page=$page&limit=10'),
      headers: _headers(),
    );
    _throwIfNot200(res);

    return (jsonDecode(res.body) as List)
        .map((e) => Post.fromJson(e, uid))
        .toList();
  }

  //explore todos los posts

  static Future<List<Post>> getExplore({int page = 1}) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/explore?page=$page&limit=10'),
      headers: _headers(),
    );
    _throwIfNot200(res);

    return (jsonDecode(res.body) as List)
        .map((e) => Post.fromJson(e, uid))
        .toList();
  }

  //like/unlike un post

  static Future<void> like(String postId) async {
    final res = await http.post(
      Uri.parse('$_base/posts/$postId/like'),
      headers: _headers(),
    );
    _throwIfNot200(res);
  }

  //comment un post

  static Future<void> comment(String postId, String content) async {
    final res = await http.post(
      Uri.parse('$_base/posts/$postId/comments'),
      headers: _headers(),
      body: jsonEncode({'content': content}),
    );
    _throwIfNot200(res);
  }

  // seguir/deseguir un usuario

  static Future<void> follow(String userId) async {
    final res = await http.post(
      Uri.parse('$_base/users/$userId/follow'),
      headers: _headers(),
    );
    _throwIfNot200(res);
  }

  static Future<void> unFollow(String userId) async {
    final res = await http.post(
      Uri.parse('$_base/users/$userId/unfollow'),
      headers: _headers(),
    );
    _throwIfNot200(res);
  }

  // Crear un post

  static Future<void> createPost({
    required File file,
    required String mediaType, 
    String? description,
    String? location,
    List<String>? tags,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('$_base/posts'))
      ..headers.addAll(_headers(multipart: true))
      ..fields['mediaType'] = mediaType
      ..fields['description'] = description ?? ''
      ..fields['location'] = location ?? ''
      ..fields['tags'] = jsonEncode(tags ?? [])
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await req.send();
    if (res.statusCode != 201) {
      throw Exception('Error al crear post (${res.statusCode})');
    }
  }

  // obtener un post por id

  static Future<Post> getPost(String postId) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/posts/$postId'),
      headers: _headers(),
    );
    _throwIfNot200(res);
    return Post.fromJson(jsonDecode(res.body), uid);
  }

  // perfil de un usuario

  static Future<Map<String, dynamic>> getUserWithPosts(String userId) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/users/$userId/profile'),
      headers: _headers(),
    );
    _throwIfNot200(res);
    final j = jsonDecode(res.body);

    final posts = (j['posts'] as List)
        .map((e) => Post.fromJson(e, uid))
        .toList();

    return {
      'user': j['user'],
      'posts': posts,
      'following': j['following'] as bool,
    };
  }

  // buscar usuarios

  static Future<List<Map<String, dynamic>>> searchUsers(String q) async {
    final res = await http.get(
      Uri.parse('$_base/users?query=$q&limit=10'),
      headers: _headers(),
    );
    _throwIfNot200(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }


  //posts de un usuario propio  
  static Future<List<Post>> getPostsByUser(String userId,
      {int page = 1, int limit = 15}) async {
    final uid = AuthService().currentUser?['_id'];   // para saber si yo di like

    final res = await http.get(
      Uri.parse('$_base/users/$userId/posts?page=$page&limit=$limit'),
      headers: _headers(),
    );
    _throwIfNot200(res);

    return (jsonDecode(res.body) as List)
        .map((e) => Post.fromJson(e, uid))
        .toList();
  }

}
