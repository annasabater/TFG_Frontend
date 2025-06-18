import 'package:flutter/material.dart';
import '../../models/drone.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'comments_section.dart';
import '../../provider/cart_provider.dart';
import '../../provider/drone_provider.dart';
import '../../utils/currency_utils.dart';
import '../../provider/users_provider.dart';

class DroneDetailModal extends StatelessWidget {
  final Drone drone;
  const DroneDetailModal({super.key, required this.drone});

  @override
  Widget build(BuildContext context) {
    final imgs = drone.images ?? [];
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final modalWidth = isDesktop ? 600.0 : double.infinity;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.25 : 8,
        vertical: isDesktop ? 40 : 8,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: modalWidth,
          minWidth: isDesktop ? 400 : 0,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imágenes o placeholder
                if (imgs.isNotEmpty)
                  Hero(
                    tag: 'drone-img-${drone.id}',
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: isDesktop ? 320 : 220,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        viewportFraction: 1.0,
                      ),
                      items: imgs.map((img) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              img,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Container(
                    height: isDesktop ? 240 : 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.flight,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),

                const SizedBox(height: 16),
                // Modelo
                Text(
                  drone.model,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                // Precio
                Builder(
                  builder: (context) {
                    final currency = context.watch<DroneProvider>().currency;
                    final symbol = getCurrencySymbol(currency);
                    final decimals = getCurrencyDecimals(currency);
                    return Text(
                      '${drone.price.toStringAsFixed(decimals)} $symbol',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    );
                  },
                ),

                const SizedBox(height: 12),
                // Descripción
                if ((drone.description ?? '').isNotEmpty)
                  Text(drone.description!),

                const SizedBox(height: 12),
                // Chips de info
                Wrap(
                  spacing: 12,
                  children: [
                    _InfoChip(Icons.category, drone.category ?? '-'),
                    _InfoChip(Icons.event, drone.type ?? '-'),
                    _InfoChip(Icons.grade, drone.condition ?? '-'),
                    _InfoChip(Icons.place, drone.location ?? '-'),
                  ],
                ),

                const SizedBox(height: 18),
                // Stock y badge
                Row(
                  children: [
                    Icon(Icons.inventory_2,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Stock: ${drone.stock ?? 1}',
                      style: TextStyle(
                        color: (drone.stock ?? 1) == 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if ((drone.stock ?? 1) == 0)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.block,
                                color: Theme.of(context).colorScheme.error,
                                size: 16),
                            const SizedBox(width: 2),
                            Text(
                              'Sin stock',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if ((drone.stock ?? 1) < 5)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

                const SizedBox(height: 18),
                // Botones: Añadir al carrito + Cerrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Añadir al carrito
                    Builder(builder: (context) {
                      final currentUserId =
                          Provider.of<UserProvider>(context, listen: false)
                              .currentUser
                              ?.id;
                      final isMine = currentUserId == drone.ownerId;
                      final outOfStock = (drone.stock ?? 1) == 0;

                      if (isMine) return const SizedBox.shrink();
                      return ElevatedButton.icon(
                        icon: Icon(
                            outOfStock ? Icons.block : Icons.add_shopping_cart),
                        label:
                            Text(outOfStock ? 'Sin stock' : 'Añadir al carrito'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: outOfStock
                              ? Colors.grey.shade300
                              : Colors.blueAccent,
                          foregroundColor:
                              outOfStock ? Colors.grey : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onPressed: outOfStock
                            ? null
                            : () {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .addToCart(drone);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Añadido al carrito')),
                                );
                              },
                      );
                    }),

                    // Cerrar modal
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                CommentsSection(droneId: drone.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 18), label: Text(label));
}
