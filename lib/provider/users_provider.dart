// users_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/UserService.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    _setError(null);

    try {
      _users = await UserService.getUsers();
    } catch (e) {
      _setError('Error loading users: $e');
      _users = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> crearUsuari(String userName, String email, String password, String role) async {
    _setLoading(true);
    _setError(null);

    try {
      final nouUsuari = User(userName: userName, email: email, password: password, role: role);
      final createdUser = await UserService.createUser(nouUsuari);
      _users.add(createdUser);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error creating user: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarUsuariPerId(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await UserService.deleteUser(id);
      if (success) {
        _users.removeWhere((user) => user.id == id);
        notifyListeners();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error deleting user: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarUsuari(String userName) async {
    _setLoading(true);
    _setError(null);

    try {
      final userToDelete = _users.firstWhere((user) => user.userName == userName);

      if (userToDelete.id != null) {
        final success = await UserService.deleteUser(userToDelete.id!);
        if (success) {
          _users.removeWhere((user) => user.userName == userName);
          notifyListeners();
        }
        _setLoading(false);
        return success;
      } else {
        _users.removeWhere((user) => user.userName == userName);
        notifyListeners();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError('Error deleting user: $e');
      _setLoading(false);
      return false;
    }
  }
}