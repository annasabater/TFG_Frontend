import 'dart:convert';
import 'dart:io' show File;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../models/post.dart';

class SocialService {
  /* ─────────────────── Config ─────────────────── */
  static const _base = 'http://localhost:9000/api';

  static String get _origin => _base.replaceAll('/api', '');

  static String absolute(String path) =>
      path.startsWith('http') ? path : '$_origin$path';

  /* ─────────────────── Headers ─────────────────── */
  static Future<Map<String, String>> _headers({bool multipart = false}) async {
    final hdr = <String, String>{};
    if (!multipart) hdr['Content-Type'] = 'application/json';

    try {
      final dyn   = AuthService();                   
      final token = (dyn as dynamic).token;          
      final str   = token is String ? token : (token is Future ? await token : '');
      if (str.isNotEmpty) hdr['Authorization'] = 'Bearer $str';
    } catch (_) {
    }
    return hdr;
  }

  static void _throwIfNot200(http.BaseResponse r) {
    if (r.statusCode >= 400) {
      throw Exception('Error ${r.statusCode}');
    }
  }

  /* ═════════════ Feed & Explore ═════════════ */
  static Future<List<Post>> getFeed({int page = 1}) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/feed?page=$page&limit=10'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    return (jsonDecode(res.body) as List)
        .map((e) => Post.fromJson(e, uid))
        .toList();
  }

  static Future<List<Post>> getExplore({int page = 1}) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/explore?page=$page&limit=10'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    return (jsonDecode(res.body) as List)
        .map((e) => Post.fromJson(e, uid))
        .toList();
  }

  /* ═════════════ Like / Comment ═════════════ */
  static Future<void> like(String postId) async {
    final res = await http.post(
      Uri.parse('$_base/posts/$postId/like'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
  }

  static Future<void> comment(String postId, String content) async {
    final res = await http.post(
      Uri.parse('$_base/posts/$postId/comments'),
      headers: await _headers(),
      body: jsonEncode({'content': content}),
    );
    _throwIfNot200(res);
  }

  /* ═════════════ Follow / Unfollow ═════════════ */
  static Future<void> follow(String userId) async {
    final res = await http.post(
      Uri.parse('$_base/users/$userId/follow'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
  }

  static Future<void> unFollow(String userId) async {
    final res = await http.post(
      Uri.parse('$_base/users/$userId/unfollow'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
  }

  /* ═════════════ Crear Post (móvil/desktop) ═════════════ */
  static Future<void> createPost({
    required File file,
    required String mediaType,
    String? description,
    String? location,
    List<String>? tags,
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('$_base/posts'))
      ..headers.addAll(await _headers(multipart: true))
      ..fields['mediaType']   = mediaType
      ..fields['description'] = description ?? ''
      ..fields['location']    = location ?? ''
      ..fields['tags']        = jsonEncode(tags ?? [])
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await req.send();
    _throwIfNot200(res);
  }

  /* ═════════════ Crear Post (web) ═════════════ */
  static Future<void> createPostWeb({
    required XFile xfile,
    required String mediaType,
    String? description,
    String? location,
    List<String>? tags,
  }) async {
    final bytes = await xfile.readAsBytes();
    final req = http.MultipartRequest('POST', Uri.parse('$_base/posts'))
      ..headers.addAll(await _headers(multipart: true))
      ..fields['mediaType']   = mediaType
      ..fields['description'] = description ?? ''
      ..fields['location']    = location ?? ''
      ..fields['tags']        = jsonEncode(tags ?? [])
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: xfile.name,
          contentType: MediaType('image', _ext(xfile.name)),
        ),
      );

    final res = await req.send();
    _throwIfNot200(res);
  }

  /* mini-util */
  static String _ext(String name) {
    final i = name.lastIndexOf('.');
    return (i >= 0 && i < name.length - 1) ? name.substring(i + 1) : 'jpeg';
  }

  /* ═════════════ Obtener Post / Perfil ═════════════ */
  static Future<Post> getPost(String postId) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/posts/$postId'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    return Post.fromJson(jsonDecode(res.body), uid);
  }

  static Future<Map<String, dynamic>> getUserWithPosts(String userId) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/users/$userId/profile'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    final j = jsonDecode(res.body);
    return {
      'user'     : j['user'],
      'posts'    : (j['posts'] as List).map((e) => Post.fromJson(e, uid)).toList(),
      'following': j['following'] as bool,
    };
  }

  /* ═════════════ Buscar usuarios ═════════════ */
  static Future<List<Map<String, dynamic>>> searchUsers(String q) async {
    final res = await http.get(
      Uri.parse('$_base/users?query=$q&limit=10'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  /* ══════ Obtener - Actualizar - Borrar un post ══════ */

static Future<Post> getPostById(String id) async {
  final uid = AuthService().currentUser?['_id'];
  final res = await http.get(Uri.parse('$_base/posts/$id'),
      headers: await _headers());
  _throwIfNot200(res);
  return Post.fromJson(jsonDecode(res.body), uid);
}

static Future<void> deletePost(String id) async {
  final res = await http.delete(Uri.parse('$_base/posts/$id'),
      headers: await _headers());
  _throwIfNot200(res);
}

static Future<List<Post>> getMyPosts() async {
  final uid = AuthService().currentUser?['_id'];
  final res = await http.get(Uri.parse('$_base/posts/mine'), headers: await _headers());
  _throwIfNot200(res);
  final data = jsonDecode(res.body) as List;
  return data.map((x) => Post.fromJson(x, uid)).toList();
}

static Future<void> updatePost(String postId, String description) async {
  final res = await http.put(Uri.parse('$_base/posts/$postId'),
      headers: await _headers(),
      body: jsonEncode({'description': description}));
  _throwIfNot200(res);
}

static Future<List<Post>> getFeedFromFollowing({int page = 1}) async {
  final uid = AuthService().currentUser?['_id'];
  final res = await http.get(Uri.parse('$_base/posts/following?page=$page'), headers: await _headers());
  _throwIfNot200(res);
  final data = jsonDecode(res.body) as List;
  return data.map((x) => Post.fromJson(x, uid)).toList();
}

  /* ═════════════ Posts por usuario ═════════════ */
  static Future<List<Post>> getPostsByUser(
    String userId, {
    int page = 1,
    int limit = 15,
  }) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/users/$userId/posts?page=$page&limit=$limit'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    return (jsonDecode(res.body) as List)
        .map((e) => Post.fromJson(e, uid))
        .toList();
  }
}
