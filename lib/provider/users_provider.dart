// users_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/UserService.dart';

class UserProvider with ChangeNotifier {
  // ------------------ Estat ---------------------------------------------
  final List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ------------------ Getters -------------------------------------------
  List<User> get users  => List.unmodifiable(_users);
  User?      get currentUser => _currentUser;
  bool       get isLoading   => _isLoading;
  String?    get error       => _error;

  // ------------------ Restriccions pel correu ---------------------------
  static const _restrictedEmails = {
    'dron_azul1@upc.edu',
    'dron_verde1@upc.edu',
    'dron_rojo1@upc.edu',
    'dron_amarillo1@upc.edu',
    'invitado_1@upc.edu',
  };

  bool get isRestricted {
    final mail = _currentUser?.email.trim().toLowerCase();
    return mail != null && _restrictedEmails.contains(mail);
  }

  /// Administrador ↔ rol = 'Administrador' **i** correu *@upc.edu*
  bool get isAdmin {
    final u = _currentUser;
    if (u == null) return false;
    return u.role.toLowerCase() == 'administrador' &&
        u.email.trim().toLowerCase().endsWith('@upc.edu');
  }

  // ------------------ Helpers de sessió ---------------------------------
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  // ------------------ Interns -------------------------------------------
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  // ------------------ CRUD backend --------------------------------------
  Future<void> loadUsers() async {
    _setLoading(true);
    _setError(null);
    try {
      final fetched = await UserService.getUsers();
      _users
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _setError('Error loading users: $e');
      _users.clear();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> crearUsuari(String userName, String email, String password, String role) async {
    _setLoading(true);
    _setError(null);
    try {
      final nouUsuari = User(userName: userName, email: email, password: password, role: role);
      final created = await UserService.createUser(nouUsuari);
      _users.add(created);
      return true;
    } catch (e) {
      _setError('Error creating user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> eliminarUsuariPerId(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await UserService.deleteUser(id);
      if (ok) _users.removeWhere((u) => u.id == id);
      return ok;
    } catch (e) {
      _setError('Error deleting user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> eliminarUsuari(String userName) async {
    _setLoading(true);
    _setError(null);
    try {
      final u = _users.firstWhere((e) => e.userName == userName);
      if (u.id != null) {
        final ok = await UserService.deleteUser(u.id!);
        if (ok) _users.remove(u);
        return ok;
      } else {
        _users.remove(u);
        return true;
      }
    } catch (e) {
      _setError('Error deleting user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}