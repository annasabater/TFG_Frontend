// lib/screens/store/all_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/drone_query.dart';
import '../../provider/drone_provider.dart';
import '../../widgets/drone_card.dart';
import '../../widgets/store_sidebar.dart';
import '../../widgets/drone_detail_modal.dart';
import 'my_drones_tab.dart'; // Asegúrate de importar el archivo correcto

class AllTab extends StatefulWidget {
  const AllTab({super.key});
  @override
  State<AllTab> createState() => _AllTabState();
}

class _AllTabState extends State<AllTab> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final String _selectedCat = 'all';
  int _dronesPerPage = 10;
  int _currentPage = 1;
  int _tabIndex = 0; // Añadido para controlar la tab activa
  Map<String, dynamic> _lastFilters = {};
  bool _showSidebar = true; // true: filtros, false: navegación
  bool _showFilters = true; // true: filtros, false: navegación

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final prov = context.read<DroneProvider>();
    if (!prov.isLoading &&
        _scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200) {
      prov.loadMore(
        filter: DroneQuery(
          category: _selectedCat != 'all' ? _selectedCat : null,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _lastFilters = filters;
      _currentPage = 1;
    });
    final prov = context.read<DroneProvider>();
    prov.loadDronesFiltered(
      DroneQuery(
        q: filters['name'],
        category: filters['category'],
        condition: filters['condition'],
        minPrice: filters['minPrice'],
        maxPrice: filters['maxPrice'],
        // location: ...
        page: 1,
        limit: _dronesPerPage,
      ),
    );
  }

  void _changePage(int page) {
    setState(() => _currentPage = page);
    final prov = context.read<DroneProvider>();
    prov.loadDronesFiltered(
      DroneQuery(
        q: _lastFilters['name'],
        category: _lastFilters['category'],
        condition: _lastFilters['condition'],
        minPrice: _lastFilters['minPrice'],
        maxPrice: _lastFilters['maxPrice'],
        // location: ...
        page: page,
        limit: _dronesPerPage,
      ),
    );
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
    final isDesktop = MediaQuery.of(context).size.width > 900;
    Widget sidebarContent;
    if (_showFilters) {
      sidebarContent = StoreSidebar(onApply: _applyFilters);
    } else {
      sidebarContent = _NavSidebar(
        selectedIndex: _tabIndex,
        onTabSelected: (i) {
          setState(() {
            _tabIndex = i;
          });
        },
      );
    }

    Widget sidebar = SizedBox(
      width: 320,
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surface,
        child: sidebarContent,
      ),
    );

    // NUEVO: Cambia el contenido principal según la opción seleccionada
    Widget mainContent;
    if (_tabIndex == 0) {
      mainContent = _AllDronesView();
    } else {
      mainContent = _MyDronesView();
    }

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: sidebar),
      appBar:
          isDesktop
              ? null
              : AppBar(
                title: const Text('Tienda de Drones'),
                leading: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _showFilters ? Icons.view_list : Icons.filter_alt,
                    ),
                    tooltip: _showFilters ? 'Ver navegación' : 'Ver filtros',
                    onPressed:
                        () => setState(() => _showFilters = !_showFilters),
                  ),
                ],
              ),
      body: Row(
        children: [
          if (isDesktop)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 320,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showFilters ? Icons.view_list : Icons.filter_alt,
                          ),
                          tooltip:
                              _showFilters ? 'Ver navegación' : 'Ver filtros',
                          onPressed:
                              () =>
                                  setState(() => _showFilters = !_showFilters),
                        ),
                        Text(
                          _showFilters ? 'Filtros' : 'Navegación',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: sidebarContent),
                ],
              ),
            ),
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}

// NUEVO: Vistas para cada sección
class _AllDronesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Copia el contenido de la vista de "Todos" aquí
    return Column(
      children: [
        // ... Copia la lógica de paginación, grid, etc. de la vista original de "Todos"
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
              return RefreshIndicator(
                onRefresh: () async => prov.loadDrones(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 600 ? 2 : 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: prov.drones.length,
                  itemBuilder:
                      (context, i) => DroneCard(
                        drone: prov.drones[i],
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => DroneDetailModal(drone: prov.drones[i]),
                          );
                        },
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MyDronesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usar el widget original para mostrar los drones del usuario
    return const MyDronesTab();
  }
}

class _NavSidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTabSelected;
  const _NavSidebar({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.all_inbox, 'label': 'Todos', 'color': Colors.blueAccent},
      {'icon': Icons.person, 'label': 'Mis drones', 'color': Colors.green},
    ];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Card(
              elevation: selectedIndex == i ? 4 : 1,
              color:
                  selectedIndex == i
                      ? (tabs[i]['color'] as Color).withOpacity(0.15)
                      : Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    selectedIndex == i
                        ? BorderSide(color: tabs[i]['color'] as Color, width: 2)
                        : BorderSide.none,
              ),
              child: ListTile(
                leading: Icon(
                  tabs[i]['icon'] as IconData,
                  color: tabs[i]['color'] as Color,
                ),
                title: Text(
                  tabs[i]['label'] as String,
                  style: TextStyle(
                    color: tabs[i]['color'] as Color,
                    fontWeight:
                        selectedIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                selected: i == selectedIndex,
                onTap: () => onTabSelected(i),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
