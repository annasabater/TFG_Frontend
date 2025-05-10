// lib/screens/store/drone_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/drone.dart';
import '../../models/shipping_info.dart';
import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';

class DroneDetailScreen extends StatelessWidget {
  final Drone drone;
  const DroneDetailScreen({super.key, required this.drone});

  @override
  Widget build(BuildContext context) {
    final droneProv = context.watch<DroneProvider>();
    final userProv  = context.watch<UserProvider>();
    final String userId = userProv.currentUser?.id ?? '';

    final bool isFav  = droneProv.favorites.any((d) => d.id == drone.id);
    final bool canBuy = userId.isNotEmpty && userId != drone.ownerId && !drone.isSold;

    return Scaffold(
      appBar: AppBar(
        title: Text(drone.model),
        actions: [
          IconButton(
            tooltip: isFav ? 'Treure de favorits' : 'Afegir a favorits',
            icon   : Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () => droneProv.toggleFavorite(userId, drone),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailBody(drone: drone),
          const SizedBox(height: 16),
          if (canBuy)
            ElevatedButton.icon(
              icon : const Icon(Icons.shopping_cart),
              label: const Text('Compra'),
              onPressed: () async {
                final info = await _showPurchaseDialog(context);
                if (info == null) return;
                final ok = await droneProv.purchase(drone.id, info);
                if (context.mounted) {
                  final msg = ok ? 'Compra confirmada!' : 'Error de compra';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                }
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon : const Icon(Icons.rate_review),
        label: const Text('Nova ressenya'),
        onPressed: () async {
          final data = await _showAddReviewDialog(context);
          if (data == null) return;
          final (int rating, String comment) = data;
          await droneProv.addReview(drone.id, rating, comment, userId);
        },
      ),
    );
  }


  Future<ShippingInfo?> _showPurchaseDialog(BuildContext ctx) {
    final addressCtrl = TextEditingController();
    final phoneCtrl   = TextEditingController();

    return showDialog<ShippingInfo>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Dades d\'enviament'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Adreça completa'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Telèfon'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addressCtrl.text.trim().isEmpty) return;
              Navigator.pop(
                ctx,
                ShippingInfo(
                  address: addressCtrl.text.trim(),
                  phone  : phoneCtrl.text.trim(),
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }


  Future<(int,String)?> _showAddReviewDialog(BuildContext ctx) async {
    final ctrl = TextEditingController();
    int rating = 5;

    return showDialog<(int,String)>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Afegeix una ressenya'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: rating,
                isExpanded: true,
                items: List.generate(
                  5,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('\${i + 1} estrelles'),
                  ),
                ),
                onChanged: (v) => setState(() => rating = v!),
              ),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Comentari'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel·lar')),
          ElevatedButton(
            onPressed: () {
              final txt = ctrl.text.trim();
              if (txt.isEmpty) return;
              Navigator.pop(ctx, (rating, txt));
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Drone drone;
  const _DetailBody({required this.drone});

  String humanCategory(String cat) {
    switch (cat) {
      case 'venta':    return 'Compra drons';
      case 'alquiler': return 'Servei';
      default:         return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgs = drone.images ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // imatges
        if (imgs.isNotEmpty)
          SizedBox(
            height: 250,
            child: PageView.builder(
              itemCount: imgs.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imgs[i], fit: BoxFit.cover),
              ),
            ),
          )
        else
          Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flight, size: 100, color: Colors.grey),
          ),

        const SizedBox(height: 16),
        Text(drone.model,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('\${drone.price.toStringAsFixed(0)} €',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 12),
        if (drone.description?.isNotEmpty ?? false) Text(drone.description!),

        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            _InfoChip(Icons.category,  humanCategory(drone.category ?? '-')),
            _InfoChip(Icons.event,     drone.type     ?? '-'),
            _InfoChip(Icons.grade,     drone.condition?? '-'),
            _InfoChip(Icons.place,     drone.location ?? '-'),
          ],
        ),
        const Divider(height: 32),

        Text('Valoracions (\${drone.ratings.length})',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        if (drone.ratings.isEmpty)
          const Text('Encara no hi ha ressenyes')
        else
          ...drone.ratings.map(
            (r) => ListTile(
              leading: CircleAvatar(child: Text(r.rating.toString())),
              title: Row(
                children: List.generate(
                  r.rating,
                  (_) => const Icon(Icons.star,
                      size: 18, color: Colors.amber),
                ),
              ),
              subtitle: Text(r.comment),
            ),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
      );
}