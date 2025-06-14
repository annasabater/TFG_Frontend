import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drone.dart';
import '../services/drone_service.dart';
import '../services/UserService.dart';
import '../provider/users_provider.dart';
import '../provider/drone_provider.dart';

class CartItem {
  final Drone drone;
  int quantity;
  CartItem({required this.drone, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  Map<String, dynamic> _latestStocks = {};
  Map<String, dynamic> _latestPrices = {};
  Map<String, String> _latestCurrencies = {};
  Map<String, dynamic> _balances = {};
  bool _loading = false;

  List<CartItem> get items => List.unmodifiable(_items);

  String get currency {
    throw UnimplementedError('Usar CartProvider.of(context).currency');
  }

  static CartProvider of(BuildContext context) =>
      Provider.of<CartProvider>(context, listen: false);

  String currencyFromContext(BuildContext context) {
    final droneProv = Provider.of<DroneProvider>(context, listen: false);
    return droneProv.currency;
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

  Future<void> updateCartForCurrency(BuildContext context) async {
    final currency = currencyFromContext(context);
    _loading = true;
    notifyListeners();
    for (final item in _items) {
      final drone = await DroneService.getDroneByIdWithCurrency(
        item.drone.id,
        currency,
      );
      _latestStocks[item.drone.id] = drone.stock ?? 1;
      _latestPrices[item.drone.id] = drone.price;
      _latestCurrencies[item.drone.id] = drone.currency ?? currency;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchUserBalances(String userId) async {
    _balances = await UserService.getUserBalance(userId);
    notifyListeners();
  }

  Future<bool> purchaseCart(BuildContext context, String userId) async {
    final currency = currencyFromContext(context);
    final itemsList =
        _items
            .map((e) => {'droneId': e.drone.id, 'quantity': e.quantity})
            .toList();
    return await DroneService.purchaseMultiple(
      userId: userId,
      payWithCurrency: currency,
      items: itemsList,
    );
  }

  Map<String, dynamic> get latestStocks => _latestStocks;
  Map<String, dynamic> get latestPrices => _latestPrices;
  Map<String, String> get latestCurrencies => _latestCurrencies;
  Map<String, dynamic> get balances => _balances;
  bool get loading => _loading;
}
