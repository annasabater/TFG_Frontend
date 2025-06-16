import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../provider/cart_provider.dart';
import '../provider/users_provider.dart' as user_provider;
import '../provider/drone_provider.dart';

class CartModal extends StatefulWidget {
  const CartModal({super.key});

  @override
  State<CartModal> createState() => _CartModalState();
}

class _CartModalState extends State<CartModal> {
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final userId =
        Provider.of<user_provider.UserProvider>(
          context,
          listen: false,
        ).currentUser?.id;
    if (userId != null) {
      Provider.of<CartProvider>(
        context,
        listen: false,
      ).fetchUserBalances(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final balances = cart.balances;
    final droneProv = Provider.of<DroneProvider>(context, listen: false);
    final currency = droneProv.currency;
    final userProv = Provider.of<user_provider.UserProvider>(
      context,
      listen: false,
    );
    final userBalance = balances[currency]?.toStringAsFixed(2) ?? '0.00';
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cart.loading) const LinearProgressIndicator(),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    const Text(
                      'Carrito de compra',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Saldo de la divisa seleccionada
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.amber,
                  size: 20,
                ),
                label: Text(
                  'Saldo: $userBalance $currency',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.amber.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('El carrito está vacío'),
              )
            else ...[
              SizedBox(
                height: 220,
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final stock =
                        cart.latestStocks[item.drone.id] ??
                        item.drone.stock ??
                        1;
                    final price =
                        cart.latestPrices[item.drone.id] ?? item.drone.price;
                    final img =
                        (item.drone.images?.isNotEmpty ?? false)
                            ? item.drone.images!.first
                            : null;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            if (img != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  img,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.airplanemode_active,
                                  color: Colors.grey,
                                  size: 28,
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.drone.model,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'Stock: $stock',
                              style: const TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed:
                                  item.quantity > 1
                                      ? () => cart.updateQuantity(
                                        item.drone.id,
                                        item.quantity - 1,
                                      )
                                      : null,
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed:
                                  item.quantity < stock
                                      ? () => cart.updateQuantity(
                                        item.drone.id,
                                        item.quantity + 1,
                                      )
                                      : null,
                            ),
                            Text(
                              '${(price * item.quantity).toStringAsFixed(2)} $currency',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => cart.removeFromCart(item.drone.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Divisa:'),
                  Text(
                    currency,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${items.fold<double>(0, (sum, item) => sum + ((cart.latestPrices[item.drone.id] ?? item.drone.price) * item.quantity)).toStringAsFixed(2)} $currency',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Comprar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  final userId =
                      Provider.of<user_provider.UserProvider>(
                        context,
                        listen: false,
                      ).currentUser?.id;
                  if (userId == null) return;
                  setState(() => _errorMsg = null);
                  try {
                    final ok = await cart.purchaseCart(context, userId);
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compra realizada correctamente'),
                        ),
                      );
                      cart.clear();
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    final error = e.toString().toLowerCase();
                    String msg = 'No se ha podido realizar la compra.';
                    if (error.contains('saldo') ||
                        error.contains('insuficiente')) {
                      msg = 'Saldo insuficiente';
                    }
                    setState(() => _errorMsg = msg);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
