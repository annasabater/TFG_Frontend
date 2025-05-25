// lib/screens/store/all_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/drone_query.dart';
import '../../provider/drone_provider.dart';
import '../../widgets/drone_card.dart';
import '../../widgets/store_sidebar.dart';

class AllTab extends StatefulWidget {
  const AllTab({super.key});
  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCat = 'all';
  int _dronesPerPage = 10;
  int _currentPage = 1;
  int _totalPages = 1;
  Map<String, dynamic> _lastFilters = {};
  bool _showSidebar = false;

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

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _lastFilters = filters;
      _currentPage = 1;
    });
    final prov = context.read<DroneProvider>();
    prov.loadDronesFiltered(DroneQuery(
      q: filters['name'],
      category: filters['category'],
      condition: filters['condition'],
      priceMin: filters['minPrice'],
      priceMax: filters['maxPrice'],
      // location: ...
      page: 1,
      limit: _dronesPerPage,
    ));
  }

  void _changePage(int page) {
    setState(() => _currentPage = page);
    final prov = context.read<DroneProvider>();
    prov.loadDronesFiltered(DroneQuery(
      q: _lastFilters['name'],
      category: _lastFilters['category'],
      condition: _lastFilters['condition'],
      priceMin: _lastFilters['minPrice'],
      priceMax: _lastFilters['maxPrice'],
      // location: ...
      page: page,
      limit: _dronesPerPage,
    ));
  }

  void _changeDronesPerPage(int? value) {
    if (value == null) return;
    setState(() {
      _dronesPerPage = value;
      _currentPage = 1;
    });
    _applyFilters(_lastFilters);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          SizedBox(
            width: 280,
            child: StoreSidebar(onApply: _applyFilters),
          ),
        Expanded(
          child: Column(
            children: [
              if (isMobile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.filter_alt),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => StoreSidebar(onApply: _applyFilters, isMobile: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              // Selector de drones por página
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Text('Drones por página:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _dronesPerPage,
                      items: const [5, 10, 20]
                          .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                          .toList(),
                      onChanged: (v) => _changeDronesPerPage(v),
                    ),
                    const Spacer(),
                    // Paginación
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
                    ),
                    Text('Página $_currentPage'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changePage(_currentPage + 1),
                    ),
                  ],
                ),
              ),
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
                    _catChip('venta', 'Compra drons'),
                    _catChip('alquiler', 'Serveis'),
                  ],
                ),
              ),

              // Grid de productos
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
                      return const Center(child: Text('No hay anuncios'));
                    }
                    // Calcular total de páginas (asumiendo que el backend devuelve el total o puedes estimar)
                    // Aquí solo ejemplo simple:
                    final total = prov.drones.length;
                    _totalPages = (total / _dronesPerPage).ceil().clamp(1, 999);
                    return RefreshIndicator(
                      onRefresh: () async => context.read<DroneProvider>().loadDrones(),
                      child: CustomScrollView(
                        controller: _scrollCtrl,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(12),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => DroneCard(
                                  drone: prov.drones[i],
                                  onTap: () => context.pushNamed(
                                    'droneDetail',
                                    pathParameters: {'id': prov.drones[i].id},
                                    extra: prov.drones[i],
                                  ),
                                ),
                                childCount: prov.drones.length,
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
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
