import 'package:flutter/material.dart';
import '../models/drone.dart';

class DroneCard extends StatelessWidget {
  final Drone drone;
  final VoidCallback? onTap;
  const DroneCard({Key? key, required this.drone, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final img = (drone.images?.isNotEmpty ?? false) ? drone.images!.first : null;
    final rating = drone.ratings.isNotEmpty
        ? drone.ratings.map((r) => r.rating).reduce((a, b) => a + b) / drone.ratings.length
        : 0.0;
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
              child: img != null
                  ? Image.network(img, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.flight, size: 48, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drone.model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${drone.price.toStringAsFixed(0)} €',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < rating.round()
                          ? Icons.star
                          : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      )),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
