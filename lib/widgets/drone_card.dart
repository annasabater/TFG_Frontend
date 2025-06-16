import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drone.dart';
import '../provider/drone_provider.dart';
import '../provider/cart_provider.dart';
import '../provider/users_provider.dart';
import 'drone_card_rating.dart';
import '../utils/currency_utils.dart';

class DroneCard extends StatelessWidget {
  final Drone drone;
  final VoidCallback? onTap;
  final bool showAddToCart;
  const DroneCard({
    super.key,
    required this.drone,
    this.onTap,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    final img =
        (drone.images?.isNotEmpty ?? false) ? drone.images!.first : null;
    final currency = context.watch<DroneProvider>().currency;
    final currencySymbol = getCurrencySymbol(currency);
    final decimals = getCurrencyDecimals(currency);
    String priceStr =
        '${drone.price.toStringAsFixed(decimals)} $currencySymbol';
    final scheme = Theme.of(context).colorScheme;
    final currentUser = context.watch<UserProvider>().currentUser;
    final isMine = currentUser != null && currentUser.id == drone.ownerId;
    final isNew =
        (drone.condition == 'new') ||
        (drone.createdAt != null &&
            DateTime.now().difference(drone.createdAt!).inDays < 30);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        img ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: scheme.primaryContainer,
                              child: Icon(
                                Icons.airplanemode_active,
                                color: scheme.primary,
                                size: 48,
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    drone.model,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DroneCardRating(droneId: drone.id),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: scheme.secondary,
                        size: 17,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Stock: ${drone.stock ?? 1}',
                        style: TextStyle(
                          color:
                              (drone.stock ?? 1) == 0
                                  ? scheme.error
                                  : scheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if ((drone.stock ?? 1) == 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.block, color: scheme.error, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                'Sin stock',
                                style: TextStyle(
                                  color: scheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if ((drone.stock ?? 1) < 5)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '¡Pocos!',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (showAddToCart)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          if (isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Nuevo',
                                style: TextStyle(
                                  color: scheme.onSecondaryContainer,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isMine || (drone.stock ?? 1) == 0
                                        ? scheme.surfaceVariant
                                        : scheme.primary,
                                foregroundColor:
                                    isMine || (drone.stock ?? 1) == 0
                                        ? scheme.onSurfaceVariant
                                        : scheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                              ),
                              onPressed:
                                  isMine || (drone.stock ?? 1) == 0
                                      ? null
                                      : () {
                                        context.read<CartProvider>().addToCart(
                                          drone,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Añadido al carrito'),
                                          ),
                                        );
                                      },
                              icon: Icon(
                                isMine || (drone.stock ?? 1) == 0
                                    ? Icons.block
                                    : Icons.add_shopping_cart,
                                size: 18,
                              ),
                              label: Text(
                                isMine
                                    ? 'No puedes comprar tu dron'
                                    : (drone.stock ?? 1) == 0
                                    ? 'Sin stock'
                                    : 'Añadir',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isMine)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Este dron es tuyo',
                        style: TextStyle(
                          color: scheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
