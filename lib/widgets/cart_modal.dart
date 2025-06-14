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
    // Usar la moneda global de la tienda
    final droneProv = Provider.of<DroneProvider>(context, listen: false);
    final currency = droneProv.currency;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cart.loading) const LinearProgressIndicator(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Carrito de compra',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (balances.isNotEmpty)
              Wrap(
                spacing: 12,
                children:
                    balances.entries
                        .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                        .toList(),
              ),
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
                    // Usar la moneda global
                    return Row(
                      children: [
                        Expanded(child: Text(item.drone.model)),
                        Text('Stock: $stock'),
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
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => cart.removeFromCart(item.drone.id),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Quitar selección de divisa, solo mostrar la actual
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Comprar'),
                onPressed: () async {
                  final userId =
                      Provider.of<user_provider.UserProvider>(
                        context,
                        listen: false,
                      ).currentUser?.id;
                  if (userId == null) return;
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error en la compra: $e')),
                    );
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
