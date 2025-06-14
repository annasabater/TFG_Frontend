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
    final rating =
        drone.ratings.isNotEmpty
            ? drone.ratings.map((r) => r.rating).reduce((a, b) => a + b) /
                drone.ratings.length
            : 0.0;
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
        decimals == 0
            ? drone.price.round().toString()
            : drone.price.toStringAsFixed(2);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  img != null
                      ? Hero(
                        tag: 'drone-img-${drone.id}',
                        child: Image.network(
                          img,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.flight,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drone.model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$priceStr $currencySymbol',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${drone.stock ?? '-'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  DroneCardRating(droneId: drone.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
