// lib/screens/store/all_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/drone.dart';
import '../../models/drone_query.dart';
import '../../provider/drone_provider.dart';

class AllTab extends StatefulWidget {
  const AllTab({super.key});
  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCat = 'all';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final prov = context.read<DroneProvider>();
    if (!prov.isLoading &&
        _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      prov.loadMore(
        filter: DroneQuery(category: _selectedCat != 'all' ? _selectedCat : null),
      );
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final prov = context.read<DroneProvider>();
    if (q.trim().isEmpty) {
      prov.loadDronesFiltered(DroneQuery(category: _selectedCat != 'all' ? _selectedCat : null));
    } else {
      prov.loadDronesFiltered(DroneQuery(
        q: q.trim(),
        category: _selectedCat != 'all' ? _selectedCat : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cercador
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Cerca per model, ubicació…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchCtrl.clear();
                  _onSearch('');
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onSubmitted: _onSearch,
          ),
        ),

        // Categories strip
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _catChip('all', 'Totes'),
              _catChip('drones', 'Compra drons'),
              _catChip('services', 'Serveis'),
              _catChip('gear', 'Material'),
            ],
          ),
        ),

        // Grid de productes
        Expanded(
          child: Consumer<DroneProvider>(
            builder: (_, prov, __) {
              if (prov.isLoading && prov.drones.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (prov.error != null) {
                return Center(child: Text(prov.error!));
              }
              if (prov.drones.isEmpty) {
                return const Center(child: Text('No hi ha anuncis'));
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<DroneProvider>().loadDrones(),
                child: CustomScrollView(
                  controller: _scrollCtrl,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _ProductCard(drone: prov.drones[i]),
                          childCount: prov.drones.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width < 600 ? 2 : 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .75,
                        ),
                      ),
                    ),
                    if (prov.isLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _catChip(String id, String label) {
    final sel = id == _selectedCat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) {
          setState(() => _selectedCat = id);
          _onSearch(_searchCtrl.text);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Drone drone;
  const _ProductCard({required this.drone});

  @override
  Widget build(BuildContext context) {
    final img = (drone.images?.isNotEmpty ?? false) ? drone.images!.first : null;
    return GestureDetector(
      onTap: () => context.pushNamed(
        'droneDetail',
        pathParameters: {'id': drone.id},
        extra: drone,
      ),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: img != null
                  ? Image.network(img,
                      width: double.infinity, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.flight)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drone.model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${drone.price.toStringAsFixed(0)} €',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
