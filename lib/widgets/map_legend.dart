import 'package:flutter/material.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Llegenda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            _buildColorLegendItem(Theme.of(context).colorScheme.error, 'Zona Restringida', context),
            const SizedBox(height: 4),
            _buildColorLegendItem(Theme.of(context).colorScheme.secondaryContainer, 'Zona Regulada', context),
            const SizedBox(height: 4),
            _buildColorLegendItem(Theme.of(context).colorScheme.primary, 'Zona Permitida', context),
            const SizedBox(height: 8),
            _buildIconLegendItem(Icons.location_pin, Theme.of(context).colorScheme.error, 'La teva ubicació', context),
          ],
        ),
      ),
    );
  }

  Widget _buildColorLegendItem(Color color, String label, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildIconLegendItem(IconData icon, Color color, String label, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
} 