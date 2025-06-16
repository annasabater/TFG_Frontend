import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drone.dart';
import '../provider/drone_provider.dart';
import '../provider/cart_provider.dart';
import '../provider/users_provider.dart';
import 'drone_card_rating.dart';

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
    final currentUser = context.watch<UserProvider>().currentUser;
    final isMine = currentUser != null && currentUser.id == drone.ownerId;
    String currencySymbol;
    int decimals = 2;
    switch (currency) {
      case 'USD':
        currencySymbol = '\$'; // $ oficial
        break;
      case 'GBP':
        currencySymbol = '£';
        break;
      case 'JPY':
        currencySymbol = '¥';
        decimals = 0;
        break;
      case 'CHF':
        currencySymbol = 'CHF';
        break;
      case 'CAD':
        currencySymbol = 'CA' + '\$';
        break;
      case 'AUD':
        currencySymbol = 'A' + '\$';
        break;
      case 'CNY':
        currencySymbol = 'CN¥';
        decimals = 0;
        break;
      case 'HKD':
        currencySymbol = 'HK' + '\$';
        break;
      case 'NZD':
        currencySymbol = 'NZ' + '\$';
        break;
      case 'EUR':
      default:
        currencySymbol = '€';
        break;
    }
    String priceStr =
        '${drone.price.toStringAsFixed(decimals)} $currencySymbol';
    final scheme = Theme.of(context).colorScheme;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child:
                      img != null
                          ? Image.network(img, fit: BoxFit.cover)
                          : Container(
                            color: scheme.primaryContainer,
                            child: Icon(
                              Icons.airplanemode_active,
                              color: scheme.primary,
                              size: 48,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 6),
              Text(
                priceStr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              DroneCardRating(droneId: drone.id),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, color: scheme.secondary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Stock: ${drone.stock ?? 1}',
                    style: TextStyle(
                      color:
                          (drone.stock ?? 1) == 0
                              ? scheme.error
                              : scheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if ((drone.stock ?? 1) == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.block, color: scheme.error, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            'Sin stock',
                            style: TextStyle(
                              color: scheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if ((drone.stock ?? 1) < 5)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '¡Pocos!',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (showAddToCart)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Nuevo',
                          style: TextStyle(
                            color: scheme.onSecondaryContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Expanded(
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
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed:
                            isMine || (drone.stock ?? 1) == 0
                                ? null
                                : () {
                                  context.read<CartProvider>().addToCart(drone);
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                        ),
                      ),
                    ),
                  ],
                ),
              if (isMine)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Este dron es tuyo',
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
