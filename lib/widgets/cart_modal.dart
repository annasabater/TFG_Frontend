import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

class CartModal extends StatelessWidget {
  const CartModal({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final currencies = [
      'EUR',
      'USD',
      'GBP',
      'JPY',
      'CHF',
      'CAD',
      'AUD',
      'CNY',
      'HKD',
      'NZD',
    ];
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    return Row(
                      children: [
                        Expanded(child: Text(item.drone.model)),
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
                              item.quantity < (item.drone.stock ?? 1)
                                  ? () => cart.updateQuantity(
                                    item.drone.id,
                                    item.quantity + 1,
                                  )
                                  : null,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Divisa:'),
                  DropdownButton<String>(
                    value: cart.currency,
                    items:
                        currencies
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => v != null ? cart.setCurrency(v) : null,
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
                    '${cart.totalPrice.toStringAsFixed(2)} ${cart.currency}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Comprar'),
                onPressed: () {
                  // Aquí irá la petición de compra en el futuro
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compra realizada (simulada)'),
                    ),
                  );
                  cart.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
