//lib/screens/store/drone_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/drone.dart';
import '../../models/drone_query.dart';
import '../../provider/drone_provider.dart';

enum ListSource { all, favorites, mine }

class DroneListScreen extends StatefulWidget {
  final String categoryFilter;
  const DroneListScreen({super.key, this.categoryFilter = 'all'});

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
    _load();
  }

  Future<void> _load() async {
    if (widget.categoryFilter == 'all') {
      await _prov.loadDrones();
    } else {
      await _prov.loadDronesFiltered(
          DroneQuery(category: widget.categoryFilter));
    }
  }

  Future<void> _onRefresh() => _load();

  void _onSearch(String query) {
    final q = query.trim();
    _prov.loadDronesFiltered(DroneQuery(q: q, category: widget.categoryFilter));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  _load();
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
              if (p.isLoading)         return const Center(child: CircularProgressIndicator());
              if (p.error != null)     return Center(child: Text(p.error!));
              if (p.drones.isEmpty)    return const Center(child: Text('No hi ha anuncis'));

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
    );
  }
}


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
