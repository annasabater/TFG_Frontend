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
  int _tabIndex = 0; // Añadido para controlar la tab activa
  bool _showFilters = true; // true: filtros, false: navegación

  void _onApplyFilters(Map<String, dynamic> filters) {
    // Llama al método de la vista de drones si está montada
    final state = _allDronesViewKey.currentState;
    if (state != null) {
      state.applyFilters(filters);
    }
  }

  final GlobalKey<_AllDronesViewState> _allDronesViewKey = GlobalKey();

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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    Widget sidebarContent;
    if (_showFilters) {
      sidebarContent = StoreSidebar(onApply: _onApplyFilters);
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
      mainContent = _AllDronesView(key: _allDronesViewKey);
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
class _AllDronesView extends StatefulWidget {
  const _AllDronesView({Key? key}) : super(key: key);
  @override
  State<_AllDronesView> createState() => _AllDronesViewState();
}

class _AllDronesViewState extends State<_AllDronesView>
    with SingleTickerProviderStateMixin {
  bool _isLastPage = false;
  late AnimationController _animController;
  Map<String, dynamic> _filters = const {};
  String? _lastCurrency;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();
    _lastCurrency = Provider.of<DroneProvider>(context, listen: false).currency;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = Provider.of<DroneProvider>(context);
    if (_lastCurrency != prov.currency) {
      _lastCurrency = prov.currency;
      // Mantener la página actual al cambiar de divisa
      _changePage(prov.currentPage, prov, force: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _changePage(
    int page,
    DroneProvider prov, {
    bool force = false,
  }) async {
    final filters = _filters.isNotEmpty ? _filters : {};
    try {
      await prov.loadDronesFiltered(
        DroneQuery(
          q: filters['name'],
          category: filters['category'],
          condition: filters['condition'],
          minPrice: filters['minPrice'],
          maxPrice: filters['maxPrice'],
          page: page,
          limit: prov.currentLimit,
          currency: prov.currency,
        ),
      );
      setState(() {
        _isLastPage = prov.drones.length < prov.currentLimit;
      });
      prov.currentPage = page; // <-- Usar setter público
      _animController.forward(from: 0);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando drones: $e')));
    }
  }

  Future<void> _changeDronesPerPage(int? value, DroneProvider prov) async {
    if (value == null) return;
    try {
      prov.currentLimit = value; // <-- Usar setter público
      prov.currentPage = 1; // <-- Usar setter público
      await prov.loadDronesFiltered(
        DroneQuery(
          q: _filters['name'],
          category: _filters['category'],
          condition: _filters['condition'],
          minPrice: _filters['minPrice'],
          maxPrice: _filters['maxPrice'],
          page: 1,
          limit: value,
          currency: prov.currency,
        ),
      );
      setState(() {
        _isLastPage = prov.drones.length < value;
      });
      _animController.forward(from: 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cambiando número de items: $e')),
      );
    }
  }

  void applyFilters(Map<String, dynamic> filters) {
    setState(() => _filters = filters);
    final prov = Provider.of<DroneProvider>(context, listen: false);
    _changePage(1, prov, force: true);
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DroneProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;
    _isLastPage = prov.drones.length < prov.currentLimit;
    final totalPages = _isLastPage ? prov.currentPage : (prov.currentPage + 1);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('Mostrar:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: prov.currentLimit,
                items:
                    const [5, 10, 20]
                        .map(
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
                        )
                        .toList(),
                onChanged: (v) => _changeDronesPerPage(v, prov),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder:
                    (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Row(
                  key: ValueKey(prov.currentPage),
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          prov.currentPage > 1
                              ? () => _changePage(prov.currentPage - 1, prov)
                              : null,
                    ),
                    for (int i = 1; i <= totalPages; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color:
                              i == prov.currentPage
                                  ? Colors.blueAccent
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap:
                              i == prov.currentPage
                                  ? null
                                  : () => _changePage(i, prov),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              '$i',
                              style: TextStyle(
                                color:
                                    i == prov.currentPage
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          !_isLastPage
                              ? () => _changePage(prov.currentPage + 1, prov)
                              : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _animController,
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
                  onRefresh: () async => _changePage(prov.currentPage, prov),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          isMobile
                              ? 1
                              : (MediaQuery.of(context).size.width < 600
                                  ? 2
                                  : 4),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isMobile ? 2.2 : 0.75,
                    ),
                    itemCount: prov.drones.length,
                    itemBuilder:
                        (context, i) => DroneCard(
                          drone: prov.drones[i],
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) =>
                                      DroneDetailModal(drone: prov.drones[i]),
                            );
                          },
                        ),
                  ),
                );
              },
            ),
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
