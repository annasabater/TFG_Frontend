import 'package:flutter/material.dart';
import '../models/drone.dart';

class CartItem {
  final Drone drone;
  int quantity;
  CartItem({required this.drone, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String _currency = 'EUR';

  List<CartItem> get items => List.unmodifiable(_items);
  String get currency => _currency;

  void setCurrency(String value) {
    _currency = value;
    notifyListeners();
  }

  void addToCart(Drone drone) {
    final idx = _items.indexWhere((e) => e.drone.id == drone.id);
    if (idx >= 0) {
      if (_items[idx].quantity < (drone.stock ?? 1)) {
        _items[idx].quantity++;
        notifyListeners();
      }
    } else {
      _items.add(CartItem(drone: drone));
      notifyListeners();
    }
  }

  void removeFromCart(String droneId) {
    _items.removeWhere((e) => e.drone.id == droneId);
    notifyListeners();
  }

  void updateQuantity(String droneId, int quantity) {
    final idx = _items.indexWhere((e) => e.drone.id == droneId);
    if (idx >= 0) {
      final maxStock = _items[idx].drone.stock ?? 1;
      _items[idx].quantity = quantity.clamp(1, maxStock);
      notifyListeners();
    }
  }

  double get totalPrice {
    double total = 0;
    for (final item in _items) {
      total += item.drone.price * item.quantity;
    }
    return total;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
