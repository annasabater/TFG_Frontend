//lib/provider/social_provider.dart

import 'package:flutter/widgets.dart';      
import '../models/post.dart';
import '../services/social_service.dart';

/// Provider que gestiona Feed y Explore.
class SocialProvider extends ChangeNotifier {
  final List<Post> _feed = [];
  int  _feedPage        = 1;
  bool _feedLoading     = false;

  List<Post> get feed        => List.unmodifiable(_feed);
  bool       get feedLoading => _feedLoading;

  Future<void> loadFeed({bool refresh = false}) async {
    if (_feedLoading) return;
    _feedLoading = true;
    notifyListeners();

    if (refresh) {
      _feed.clear();
      _feedPage = 1;
    }

    try {
      final items = await SocialService.getFeed(page: _feedPage);
      _feed.addAll(items);
      _feedPage++;
    } finally {
      _feedLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
    }
  }

  final List<Post> _explore = [];
  int  _explorePage        = 1;
  bool _exploreLoading     = false;

  List<Post> get explore        => List.unmodifiable(_explore);
  bool       get exploreLoading => _exploreLoading;

  Future<void> loadExplore({bool refresh = false}) async {
    if (_exploreLoading) return;
    _exploreLoading = true;
    notifyListeners();

    if (refresh) {
      _explore.clear();
      _explorePage = 1;
    }

    try {
      final items = await SocialService.getExplore(page: _explorePage);
      _explore.addAll(items);
      _explorePage++;
    } finally {
      _exploreLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
    }
  }

  Future<void> toggleLike(Post p) async {
    p.likedByMe ? p.likes-- : p.likes++;
    p.likedByMe = !p.likedByMe;
    notifyListeners();

    try {
      await SocialService.like(p.id);
    } catch (_) {
      p.likedByMe ? p.likes-- : p.likes++;
      p.likedByMe = !p.likedByMe;
      notifyListeners();
    }
  }
}
