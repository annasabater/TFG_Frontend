import 'package:flutter/material.dart';

import '../models/drone.dart';
import '../models/drone_query.dart';
import '../services/drone_service.dart';

class DroneProvider with ChangeNotifier {
  /* ---------------- Estat ---------------- */

  List<Drone> _drones = [];
  List<Drone> _favorites = [];
  List<Drone> _myDrones = [];

  bool   _isLoading = false;
  String? _error;

  /* ---------------- Getters ---------------- */

  List<Drone> get drones     => _drones;
  List<Drone> get favorites  => _favorites;
  List<Drone> get myDrones   => _myDrones;

  bool   get isLoading => _isLoading;
  String? get error     => _error;

  /* ---------------- Helpers interns ---------------- */

  void _setLoading(bool v)   { _isLoading = v; notifyListeners(); }
  void _setError(String? e)  { _error     = e; notifyListeners(); }

  /* ====================================================================== */
  /*                          CRUD bàsic (llista)                           */
  /* ====================================================================== */

  Future<void> loadDrones() async {
    _setLoading(true); _setError(null);
    try   { _drones = await DroneService.getDrones(); }
    catch (e) { _setError('Error loading drones: $e'); _drones = []; }
    finally   { _setLoading(false); }
  }

  Future<void> loadDronesFiltered(DroneQuery q) async {
    _setLoading(true); _setError(null);
    try   { _drones = await DroneService.getDrones(q); }
    catch (e) { _setError('Error: $e'); _drones = []; }
    finally   { _setLoading(false); }
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
        id        : '',          // el backend ho posa
        ownerId   : ownerId,
        model     : model,
        price     : price,
        description: description,
        type      : type,
        condition : condition,
        location  : location,
        contact   : contact,
        category  : category,
        images    : const [],
        createdAt : null,
      );
      final created = await DroneService.createDrone(newDrone);
      _drones.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error creating drone: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDroneById(String id) async {
    _setLoading(true); _setError(null);
    try {
      final ok = await DroneService.deleteDrone(id);
      if (ok) { _drones.removeWhere((d) => d.id == id); notifyListeners(); }
      return ok;
    } catch (e) {
      _setError('Error deleting drone: $e');
      return false;
    } finally { _setLoading(false); }
  }

  /* ====================================================================== */
  /*                               Reviews                                  */
  /* ====================================================================== */

  Future<bool> addReview(String droneId, int rating,
      String comment, String userId) async {
    try {
      final updated = await DroneService.addReview(
        droneId: droneId,
        userId : userId,
        rating : rating,
        comment: comment,
      );
      final i = _drones.indexWhere((d) => d.id == droneId);
      if (i != -1) _drones[i] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error adding review: $e');
      return false;
    }
  }

  /* ====================================================================== */
  /*                               Favorits                                 */
  /* ====================================================================== */

  Future<void> loadFavorites(String userId) async {
    _setLoading(true);
    try   { _favorites = await DroneService.getFavorites(userId); }
    catch (e) { _setError('Error loading favs: $e'); _favorites = []; }
    finally   { _setLoading(false); }
  }

  Future<void> toggleFavorite(String userId, Drone drone) async {
    final already = _favorites.any((d) => d.id == drone.id);
    try {
      if (already) {
        await DroneService.removeFavorite(userId, drone.id);
        _favorites.removeWhere((d) => d.id == drone.id);
      } else {
        await DroneService.addFavorite(userId, drone.id);
        _favorites.add(drone);
      }
      notifyListeners();
    } catch (e) {
      _setError('Error updating favs: $e');
    }
  }

  /* ====================================================================== */
  /*                               Els meus                                 */
  /* ====================================================================== */

  Future<void> loadMyDrones(String userId, {String? status}) async {
    _setLoading(true);
    try   { _myDrones = await DroneService.getMyDrones(userId, status: status); }
    catch (e) { _setError('Error: $e'); _myDrones = []; }
    finally   { _setLoading(false); }
  }
}
