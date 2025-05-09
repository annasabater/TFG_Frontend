import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/drone.dart';
import '../../models/drone_query.dart';
import '../../provider/drone_provider.dart';

class DroneListScreen extends StatefulWidget {
  const DroneListScreen({super.key});

  @override
  State<DroneListScreen> createState() => _DroneListScreenState();
}

class _DroneListScreenState extends State<DroneListScreen> {
  final _searchCtrl = TextEditingController();
  late DroneProvider _prov;

  @override
  void initState() {
    super.initState();
    _prov = context.read<DroneProvider>();
    _prov.loadDrones();
  }

  Future<void> _onRefresh() => _prov.loadDrones();

  void _onSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) {
      _prov.loadDrones();
    } else {
      _prov.loadDronesFiltered(const DroneQuery(q: ''));
      // si vols filtrar de debò: DroneQuery(q: q)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cerca per model, ubicació…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _prov.loadDrones();
                  },
                ),
              ),
              onSubmitted: _onSearch,
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: Consumer<DroneProvider>(
              builder: (_, p, __) {
                if (p.isLoading) return const Center(child: CircularProgressIndicator());
                if (p.error != null) return Center(child: Text(p.error!));
                if (p.drones.isEmpty) return const Center(child: Text('No hi ha anuncis'));

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: p.drones.length,
                    itemBuilder: (_, i) => _DroneTile(drone: p.drones[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------ tile d’un anunci ------------------ */
class _DroneTile extends StatelessWidget {
  final Drone drone;
  const _DroneTile({required this.drone});

  @override
  Widget build(BuildContext context) {
    final img = (drone.images?.isNotEmpty ?? false) ? drone.images!.first : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: img != null
              ? Image.network(img, width: 64, height: 64, fit: BoxFit.cover)
              : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.flight, color: Colors.grey),
                ),
        ),
        title: Text(drone.model),
        subtitle: Text('${drone.price.toStringAsFixed(0)} € • ${drone.location ?? '-'}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.pushNamed(
          'droneDetail',
          pathParameters: {'id': drone.id},   
          extra: drone,
        ),
      ),
    );
  }
}
