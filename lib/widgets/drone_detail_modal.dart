import 'package:flutter/material.dart';
import '../../models/drone.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../../provider/users_provider.dart';
import 'package:go_router/go_router.dart';
import 'comments_section.dart';

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
                      items:
                          imgs
                              .map(
                                (img) => ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(
                                      img,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
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
                Text(
                  drone.model,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${drone.price.toStringAsFixed(0)} €',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                if (drone.description?.isNotEmpty ?? false)
                  Text(drone.description!),
                const SizedBox(height: 12),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) {
                        final userProv = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        final currentUserId = userProv.currentUser?.id;
                        final isMine = currentUserId == drone.ownerId;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chat_bubble_outline,
                                color: isMine ? Colors.grey : Colors.teal,
                                size: 28,
                              ),
                              tooltip:
                                  isMine
                                      ? 'No puedes chatear contigo mismo'
                                      : 'Chat con el vendedor',
                              onPressed:
                                  isMine
                                      ? null
                                      : () {
                                        Navigator.of(context).pop();
                                        GoRouter.of(
                                          context,
                                        ).go('/chat/${drone.ownerId}');
                                      },
                            ),
                            if (isMine)
                              const Positioned(
                                child: Icon(
                                  Icons.block,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
                // Sección de comentarios
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
