//lib/provider/drone_provider.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  String _currency = 'EUR';
  String get currency => _currency;
  set currency(String value) {
    if (_currency != value) {
      _currency = value;
      notifyListeners();
      loadDrones(page: _currentPage, limit: _currentLimit);
      if (_userIdForReload != null && _userIdForReload!.isNotEmpty) {
        loadFavorites(_userIdForReload!);
        loadMyDrones(_userIdForReload!);
      }
    }
  }

  int _currentPage = 1;
  int _currentLimit = 10;
  int get currentPage => _currentPage;
  int get currentLimit => _currentLimit;
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }

  set currentLimit(int value) {
    _currentLimit = value;
    notifyListeners();
  }

  String? _userIdForReload;
  void setUserIdForReload(String? uid) {
    _userIdForReload = uid;
  }

  List<Drone> get drones => _drones;
  List<Drone> get favorites => _favorites;
  List<Drone> get myDrones => _myDrones;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // Modificado para aceptar página y límite
  Future<void> loadDrones({int page = 1, int limit = 10}) async {
    _setLoading(true);
    _setError(null);
    _page = page;
    _hasMore = true;
    _currentPage = page;
    _currentLimit = limit;
    try {
      _drones = await DroneService.getDrones(
        DroneQuery(currency: _currency, page: page, limit: limit),
      );
    } catch (e) {
      _setError('Error loading drones: $e');
      _drones = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Drone>> loadDronesFiltered(DroneQuery q) async {
    _setLoading(true);
    _setError(null);
    _page = q.page ?? 1;
    _hasMore = true;
    try {
      final result = await DroneService.getDrones(
        q.copyWith(currency: _currency),
      );
      _drones = result;
      return result;
    } catch (e) {
      _setError('Error: $e');
      _drones = [];
      return [];
    } finally {
      _setLoading(false);
    }
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
    String? currency, 
    String? description,
    String? type,
    String? condition,
    String? location,
    String? contact,
    String? category,
    int? stock,
    List<XFile>? imagesWeb, // para web
    List<File>? imagesMobile, // para móvil
    List<String>? existingImages, 
    String? id, 
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newDrone = Drone(
        id: id ?? '', // Si hay id, es edición
        ownerId: ownerId,
        model: model,
        price: price,
        currency: currency ?? _currency, 
        description: description,
        type: type,
        condition: condition,
        location: location,
        contact: contact,
        category: category,
        stock: stock,
        images: existingImages ?? const [],
        createdAt: null,
      );
      Drone result;
      if (id != null && id.isNotEmpty) {
        // Es edición: actualiza el dron existente
        result = await DroneService.updateDrone(
          id,
          newDrone,
          images: imagesMobile,
          imagesWeb: imagesWeb,
        );
        // Actualiza en _drones y _myDrones
        final idx = _drones.indexWhere((d) => d.id == id);
        if (idx != -1) _drones[idx] = result;
        final myIdx = _myDrones.indexWhere((d) => d.id == id);
        if (myIdx != -1) _myDrones[myIdx] = result;
        // Recarga la tienda tras editar
        await loadDrones();
      } else {
        // Es creación
        if ((imagesMobile != null && imagesMobile.isNotEmpty) ||
            (imagesWeb != null && imagesWeb.isNotEmpty) ||
            ((existingImages != null && existingImages.isNotEmpty))) {
          result = await DroneService.createDrone(
            newDrone,
            images: imagesMobile,
            imagesWeb: imagesWeb,
          );
        } else {
          throw Exception('Debes subir al menos 1 imagen.');
        }
        _drones.insert(0, result);
        // Recarga la tienda tras crear
        await loadDrones();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error creando/editando dron: $e');
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

  Future<bool> addReview(
    String id,
    int rating,
    String comment,
    String userId,
  ) async {
    try {
      final upd = await DroneService.addReview(
        droneId: id,
        userId: userId,
        rating: rating,
        comment: comment,
      );
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

  Future<bool> updateDrone(
    String id, {
    required String model,
    required String description,
    required double price,
    required String location,
    required String category,
    required String condition,
    required String contact,
    required int stock,
    List<XFile>? imagesWeb,
    List<File>? imagesMobile,
  }) async {
    final d = Drone(
      id: id,
      ownerId: '', // not needed for update
      model: model,
      price: price,
      description: description,
      location: location,
      category: category,
      condition: condition,
      contact: contact,
      stock: stock,
      images: const [],
      createdAt: null,
    );
    return await update(id, d);
  }

  Future<bool> deleteDrone(String id) async {
    _setLoading(true);
    try {
      final ok = await DroneService.deleteDrone(id);
      if (ok) {
        _myDrones.removeWhere((d) => d.id == id);
        // Recargar la lista general de drones
        await loadDrones();
        notifyListeners();
      }
      return ok;
    } catch (e) {
      _setError('Error al borrar: $e');
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
