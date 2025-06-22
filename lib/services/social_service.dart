// lib/services/social_service.dart

import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/post.dart';
import '../models/user.dart';

class SocialService {
  static String get _base {
    var url = dotenv.env['SERVER_URL'] ?? 'http://localhost:9000/api';
    if (!url.endsWith('/api')) url = url.replaceAll(RegExp(r'/api.*'), '') + '/api';
    return url;
  }

  /// Host sin el "/api", útil para assets o rutas fuera de la API REST.
  static String get _host => _base.replaceFirst(RegExp(r'/api$'), '');

  /// Construye una URL absoluta para recursos fuera de la API (imágenes, etc.).
  static String absolute(String path) =>
    path.startsWith('http') ? path : '$_host$path';

  static Future<Map<String, String>> _headers({bool multipart = false}) async {
    final hdr = <String, String>{};
    if (!multipart) hdr['Content-Type'] = 'application/json';
    try {
      final dyn   = AuthService();
      final token = (dyn as dynamic).token;
      final str   = token is String
          ? token
          : (token is Future ? await token : '');
      if (str.isNotEmpty) hdr['Authorization'] = 'Bearer $str';
    } catch (_) {}
    return hdr;
  }

  static void _throwIfNot200(http.BaseResponse r) {
    if (r.statusCode >= 400) throw Exception('Error ${r.statusCode}');
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

  static Future<List<Post>> getExplore({int page = 1, int limit = 10}) async {
    final uid = AuthService().currentUser?['_id'];
    try {
      final res = await http.get(
        Uri.parse('$_base/feed?page=$page&limit=$limit'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((e) => Post.fromJson(e, uid))
            .toList();
      } else {
        debugPrint('SocialService.getExplore HTTP ${res.statusCode}');
        return <Post>[];
      }
    } catch (e, st) {
      debugPrint('SocialService.getExplore error: $e\n$st');
      return <Post>[];
    }
  }

  static Future<List<Post>> getFeed({int page = 1, int limit = 10}) async {
    final uid = AuthService().currentUser?['_id'];
    try {
      final res = await http.get(
        Uri.parse('$_base/posts/following?page=$page&limit=$limit'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((e) => Post.fromJson(e, uid))
            .toList();
      } else {
        debugPrint('SocialService.getFeed HTTP ${res.statusCode}');
        return <Post>[];
      }
    } catch (e, st) {
      debugPrint('SocialService.getFeed error: $e\n$st');
      return <Post>[];
    }
  }

  static Future<List<Post>> getMyPosts({int page = 1, int limit = 15}) async {
    final uid = AuthService().currentUser?['_id'];
    try {
      final res = await http.get(
        Uri.parse('$_base/users/$uid/posts?page=$page&limit=$limit'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((e) => Post.fromJson(e, uid))
            .toList();
      } else {
        debugPrint('SocialService.getMyPosts HTTP ${res.statusCode}');
        return <Post>[];
      }
    } catch (e, st) {
      debugPrint('SocialService.getMyPosts error: $e\n$st');
      return <Post>[];
    }
  }

  static Future<Post> getPostById(String postId) async {
    final uid = AuthService().currentUser?['_id'];
    final res = await http.get(
      Uri.parse('$_base/posts/$postId'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    return Post.fromJson(jsonDecode(res.body), uid);
  }

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

  static String _ext(String name) {
    final i = name.lastIndexOf('.');
    return (i >= 0 && i < name.length - 1) ? name.substring(i + 1) : 'jpeg';
  }

  static Future<void> updatePost(String postId, String description) async {
    final res = await http.put(
      Uri.parse('$_base/posts/$postId'),
      headers: await _headers(),
      body: jsonEncode({'description': description}),
    );
    _throwIfNot200(res);
  }

  static Future<void> deletePost(String postId) async {
    final res = await http.delete(
      Uri.parse('$_base/posts/$postId'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
  }

  static Future<List<Map<String, dynamic>>> searchUsers(String q) async {
    final res = await http.get(
      Uri.parse('$_base/users?query=$q&limit=50'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<void> deleteComment(String postId, String commentId) async {
    final res = await http.delete(
      Uri.parse('$_base/posts/$postId/comments/$commentId'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
  }

  static Future<List<User>> getFollowingUsers(String userId) async {
    final res = await http.get(
      Uri.parse('$_base/users/$userId/profile'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    final j = jsonDecode(res.body);
    final followingList = (j['user']['following'] ?? []) as List;
    return followingList.map((e) => User.fromJson(e)).toList();
  }

  static Future<List<User>> getMyFollowing({int page = 1, int limit = 20}) async {
    final res = await http.get(
      Uri.parse('$_base/users/me/following?page=$page&limit=$limit'),
      headers: await _headers(),
    );
    _throwIfNot200(res);
    final data = jsonDecode(res.body);
    final followingList = (data['following'] ?? []) as List;
    return followingList.map((e) => User.fromJson(e)).toList();
  }
}
