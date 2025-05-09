// lib/screens/store/drone_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/drone.dart';
import '../../provider/users_provider.dart';
import '../../provider/drone_provider.dart';

class DroneDetailScreen extends StatelessWidget {
  final Drone drone;
  const DroneDetailScreen({super.key, required this.drone});

  @override

  Widget build(BuildContext context) {
    final droneProv = context.watch<DroneProvider>();
    final userProv  = context.watch<UserProvider>();
    final userId    = userProv.currentUser?.id ?? '';

    final isFav = droneProv.favorites.any((d) => d.id == drone.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(drone.model),
        actions: [
          IconButton(
            tooltip: isFav ? 'Treure de favorits' : 'Afegir a favorits',
            icon  : Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () => droneProv.toggleFavorite(userId, drone),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon : const Icon(Icons.rate_review),
        label: const Text('Nova ressenya'),
        onPressed: () async {
          final data = await _showAddReviewDialog(context);
          if (data == null) return;                       // cancel·lat
          final (int rating, String comment) = data;
          await droneProv.addReview(drone.id, rating, comment, userId);
        },
      ),
      body: _DetailBody(drone: drone),
    );
  }

  /* ---------- Diàleg nova ressenya ---------- */
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
                    child: Text('${i + 1} estrelles'),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel·lar'),
          ),
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

/* -------------------------------------------------------------------------- */
/*                                Cos de la view                              */
/* -------------------------------------------------------------------------- */

class _DetailBody extends StatelessWidget {
  final Drone drone;
  const _DetailBody({required this.drone});

  @override
  Widget build(BuildContext context) {
    final imgList = drone.images ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        /* ------------------- Imatges ------------------- */
        if (imgList.isNotEmpty)
          SizedBox(
            height: 250,
            child: PageView.builder(
              itemCount: imgList.length,
              pageSnapping: true,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imgList[i], fit: BoxFit.cover),
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

        /* ------------------- Dades bàsiques ------------------- */
        Text(
          drone.model,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${drone.price.toStringAsFixed(0)} €',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 12),
        if (drone.description != null && drone.description!.isNotEmpty)
          Text(drone.description!),

        /* ------------------- Informació extra ------------------- */
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _InfoChip(icon: Icons.category, label: drone.category ?? '-'),
            _InfoChip(icon: Icons.event,    label: drone.type ?? '-'),
            _InfoChip(icon: Icons.grade,    label: drone.condition ?? '-'),
            _InfoChip(icon: Icons.place,    label: drone.location ?? '-'),
          ],
        ),
        const Divider(height: 32),

        /* ------------------- Valoracions ------------------- */
        Text(
          'Valoracions (${drone.ratings.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (drone.ratings.isEmpty)
          const Text('Encara no hi ha ressenyes')
        else
          ...drone.ratings.map((r) => ListTile(
                leading: CircleAvatar(child: Text(r.rating.toString())),
                title: Row(
                  children: List.generate(
                    r.rating,
                    (_) => const Icon(Icons.star, color: Colors.amber, size: 18),
                  ),
                ),
                subtitle: Text(r.comment),
              )),
      ],
    );
  }
}

/* ---------- Widget ajudant ---------- */
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
    );
  }
}
