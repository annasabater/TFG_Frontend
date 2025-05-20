import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/social_service.dart';

/// Provider que gestiona el estado del feed y de explore
class SocialProvider with ChangeNotifier {
  /* ─────────────── FEED (gente que sigo) ─────────────── */
  final List<Post> _feed = [];
  int _feedPage = 1;
  bool _feedLoading = false;

  List<Post> get feed => _feed;
  bool get feedLoading => _feedLoading;

  Future<void> loadFeed({bool refresh = false}) async {
    if (_feedLoading) return;
    _feedLoading = true;
    notifyListeners();

    if (refresh) {
      _feed.clear();
      _feedPage = 1;
    }

    final fetched = await SocialService.getFeed(page: _feedPage);
    _feed.addAll(fetched);
    _feedPage++;
    _feedLoading = false;
    notifyListeners();
  }

  /* ─────────────── EXPLORE (todos los posts) ─────────────── */
  final List<Post> _explore = [];
  int _explorePage = 1;
  bool _exploreLoading = false;

  List<Post> get explore => _explore;
  bool get exploreLoading => _exploreLoading;

  Future<void> loadExplore({bool refresh = false}) async {
    if (_exploreLoading) return;
    _exploreLoading = true;
    notifyListeners();

    if (refresh) {
      _explore.clear();
      _explorePage = 1;
    }

    final fetched = await SocialService.getExplore(page: _explorePage);
    _explore.addAll(fetched);
    _explorePage++;
    _exploreLoading = false;
    notifyListeners();
  }

  /* ─────────────── Like / Unlike ─────────────── */
  Future<void> toggleLike(Post p) async {
    await SocialService.like(p.id);
    if (p.likedByMe) {
      p.likedByMe = false;
      p.likes--;
    } else {
      p.likedByMe = true;
      p.likes++;
    }
    notifyListeners();
  }
}
