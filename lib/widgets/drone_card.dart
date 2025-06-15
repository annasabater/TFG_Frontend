import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drone.dart';
import '../provider/drone_provider.dart';
import '../provider/cart_provider.dart';
import 'drone_card_rating.dart';

class DroneCard extends StatelessWidget {
  final Drone drone;
  final VoidCallback? onTap;
  const DroneCard({super.key, required this.drone, this.onTap});

  @override
  Widget build(BuildContext context) {
    final img =
        (drone.images?.isNotEmpty ?? false) ? drone.images!.first : null;
    final currency = context.watch<DroneProvider>().currency;
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
    // Considerar "nuevo" si la condición es "new" o creado hace menos de 30 días
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
              const Spacer(),
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
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      context.read<CartProvider>().addToCart(drone);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Añadido al carrito')),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Añadir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
