//lib/screens/store/my_drones_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/drone_provider.dart';

class MyDronesTab extends StatelessWidget {
  const MyDronesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading) return const Center(child: CircularProgressIndicator());
        if (prov.error != null) return Center(child: Text(prov.error!));
        if (prov.myDrones.isEmpty) return const Center(child: Text('Encara no tens anuncis'));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: prov.myDrones.length,
          itemBuilder: (_, i) {
            final drone = prov.myDrones[i];
            return ListTile(
              leading: const Icon(Icons.flight_takeoff),
              title: Text(drone.model),
              subtitle: Text('${drone.price.toStringAsFixed(0)} € • ${drone.status ?? 'pending'}'),

            );
          },
        );
      },
    );
  }
}
