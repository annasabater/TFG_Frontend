//lib/screens/drone_screen.dart

import 'package:flutter/material.dart';
import '../models/drone.dart';
import '../services/drone_service.dart';

class DroneProvider with ChangeNotifier {
  List<Drone> _drones = [];
  Drone? _selectedDrone;
  bool _isLoading = false;
  String? _error;

  // Getters públicos
  List<Drone> get drones => _drones;
  Drone? get selectedDrone => _selectedDrone;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }


  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  /// Carga todos los drones desde el backend
  Future<void> loadDrones() async {
    _setLoading(true);
    _setError(null);

    try {
      _drones = await DroneService.getDrones();
    } catch (e) {
      _setError('Error loading drones: $e');
      _drones = [];
    } finally {
      _setLoading(false);
    }
  }
/*
  /// Carga un solo drone por ID y lo deja en selectedDrone
  Future<void> loadDrone(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedDrone = await DroneService.getDroneById(id);
    } catch (e) {
      _setError('Error loading drone: $e');
      _selectedDrone = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Crea un nuevo drone y lo añade a la lista local
  Future<bool> createDrone({
    required String sellerId,
    required String model,
    required double price,
    String? description,
    String? type,
    String? condition,
    String? location,
    String? contact,
    String? category,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final newDrone = Drone(
        id: '', // el backend asignará el ID
        sellerId: sellerId,
        model: model,
        price: price,
        description: description,
        type: type,
        condition: condition,
        location: location,
        contact: contact,
        category: category,
        createdAt: null,
        images: [],
      );
      final created = await DroneService.createDrone(newDrone);
      _drones.add(created);
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error creating drone: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Elimina un drone por su ID
  Future<bool> deleteDroneById(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await DroneService.deleteDrone(id);
      if (success) {
        _drones.removeWhere((d) => d.id == id);
        notifyListeners();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error deleting drone: $e');
      _setLoading(false);
      return false;
    }
  }*/
}
