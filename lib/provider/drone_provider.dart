//lib/provider/drone_provider.dart

import 'package:flutter/material.dart';
import '../models/drone.dart';
import '../models/drone_query.dart';
import '../models/shipping_info.dart';
import '../services/drone_service.dart';

class DroneProvider with ChangeNotifier {
  List<Drone> _drones = [];
  List<Drone> _favorites = [];
  List<Drone> _myDrones = [];

  bool _isLoading = false;
  String? _error;

  // per paginar
  int _page = 1;
  bool _hasMore = true;

  List<Drone> get drones => _drones;
  List<Drone> get favorites => _favorites;
  List<Drone> get myDrones => _myDrones;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? e)  { _error = e; notifyListeners(); }

  Future<void> loadDrones() async {
    _setLoading(true); _setError(null);
    _page = 1; _hasMore = true;
    try {
      _drones = await DroneService.getDrones();
    } catch (e) {
      _setError('Error loading drones: $e');
      _drones = [];
    } finally { _setLoading(false); }
  }

  Future<void> loadDronesFiltered(DroneQuery q) async {
    _setLoading(true); _setError(null);
    _page = 1; _hasMore = true;
    try {
      _drones = await DroneService.getDrones(q);
    } catch (e) {
      _setError('Error: $e');
      _drones = [];
    } finally { _setLoading(false); }
  }

  Future<void> loadMore({DroneQuery? filter}) async {
    if (!_hasMore || _isLoading) return;
    _setLoading(true);
    try {
      final next = await DroneService.getDrones(
        filter == null
          ? DroneQuery(page: ++_page, limit: 20)
          : filter.copyWith(page: _page + 1, limit: 20),
      );
      if (next.isEmpty) _hasMore = false;
      _page++;
      _drones.addAll(next);
    } catch (_) {
      // ignora
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> createDrone({
    required String ownerId,
    required String model,
    required double price,
    String? description,
    String? type,
    String? condition,
    String? location,
    String? contact,
    String? category,
  }) async {
    _setLoading(true); _setError(null);
    try {
      final newDrone = Drone(
        id: '',
        ownerId: ownerId,
        model: model,
        price: price,
        description: description,
        type: type,
        condition: condition,
        location: location,
        contact: contact,
        category: category,
        images: const [],
        createdAt: null,
      );
      final created = await DroneService.createDrone(newDrone);
      _drones.insert(0, created);
      return true;
    } catch (e) {
      _setError('Error creating drone: $e');
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadFavorites(String uid) async {
    _setLoading(true);
    try {
      _favorites = await DroneService.getFavorites(uid);
    } catch (e) {
      _setError('Error favs: $e');
      _favorites = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String uid, Drone d) async {
    final already = _favorites.any((x) => x.id == d.id);
    try {
      if (already) {
        await DroneService.removeFavorite(uid, d.id);
        _favorites.removeWhere((x) => x.id == d.id);
      } else {
        await DroneService.addFavorite(uid, d.id);
        _favorites.add(d);
      }
      notifyListeners();
    } catch (e) {
      _setError('Error favs: $e');
      notifyListeners();
    }
  }

  Future<void> loadMyDrones(String uid, {String? status}) async {
    _setLoading(true);
    try {
      _myDrones = await DroneService.getMyDrones(uid, status: status);
    } catch (e) {
      _setError('Error meus: $e');
      _myDrones = [];
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> purchase(String id, ShippingInfo info) async {
    try {
      final upd = await DroneService.purchaseDrone(id, info);
      _replace(upd);
      return true;
    } catch (e) {
      _setError('Error compra: $e');
      return false;
    }
  }

  Future<bool> markSold(String id) async {
    try {
      final upd = await DroneService.markSold(id);
      _replace(upd);
      return true;
    } catch (e) {
      _setError('Error sold: $e');
      return false;
    }
  }

  Future<bool> addReview(String id, int rating, String comment, String userId) async {
    try {
      final upd = await DroneService.addReview(
        droneId: id, userId: userId, rating: rating, comment: comment);
      _replace(upd);
      return true;
    } catch (e) {
      _setError('Error review: $e');
      return false;
    }
  }

  Future<bool> update(String id, Drone d) async {
    _setLoading(true);
    try {
      final upd = await DroneService.updateDrone(id, d);
      _replace(upd);
      return true;
    } catch (e) {
      _setError('Error update: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _replace(Drone d) {
    final i = _drones.indexWhere((x) => x.id == d.id);
    if (i != -1) _drones[i] = d;
    notifyListeners();
  }
}
