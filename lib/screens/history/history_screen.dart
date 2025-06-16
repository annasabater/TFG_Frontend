// lib/screens/history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/users_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tabIndex = 0; // 0: Compras, 1: Ventas

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    Widget sidebarContent = _HistoryNavSidebar(
      selectedIndex: _tabIndex,
      onTabSelected: (i) => setState(() => _tabIndex = i),
    );
    Widget sidebar = SizedBox(
      width: 240,
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surface,
        child: sidebarContent,
      ),
    );
    Widget mainContent =
        _tabIndex == 0
            ? const _HistoryList(type: HistoryType.purchase)
            : const _HistoryList(type: HistoryType.sale);
    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: sidebar),
      appBar:
          isDesktop
              ? null
              : AppBar(
                title: const Text('Historial'),
                leading: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
              ),
      body: Row(
        children: [
          if (isDesktop)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 240,
              child: sidebarContent,
            ),
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}

class _HistoryNavSidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTabSelected;
  const _HistoryNavSidebar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {
        'icon': Icons.shopping_cart,
        'label': 'Compras',
        'color': Colors.blueAccent,
      },
      {'icon': Icons.sell, 'label': 'Ventas', 'color': Colors.green},
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
                onTap: () async {
                  onTabSelected(i);
                  final userProv = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );
                  try {
                    if (i == 0) {
                      await userProv.fetchPurchaseHistory();
                    } else {
                      await userProv.fetchSalesHistory();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error cargando historial: $e')),
                    );
                  }
                },
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

enum HistoryType { purchase, sale }

class _HistoryList extends StatefulWidget {
  final HistoryType type;
  const _HistoryList({required this.type});

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _search = '';

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final isLoading = userProv.isHistoryLoading;
    final error = userProv.historyError;
    List<Map<String, dynamic>> history =
        widget.type == HistoryType.purchase
            ? userProv.purchaseHistory
            : userProv.salesHistory;
    // Ordenar por fecha descendente
    history = List<Map<String, dynamic>>.from(history)
      ..sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    // Filtrar por fecha
    if (_fromDate != null) {
      history =
          history.where((item) {
            final date =
                DateTime.tryParse(item['date'] ?? '') ?? DateTime(2000);
            return date.isAfter(_fromDate!) ||
                date.isAtSameMomentAs(_fromDate!);
          }).toList();
    }
    if (_toDate != null) {
      history =
          history.where((item) {
            final date =
                DateTime.tryParse(item['date'] ?? '') ?? DateTime(2100);
            return date.isBefore(_toDate!) || date.isAtSameMomentAs(_toDate!);
          }).toList();
    }
    // Filtrar por búsqueda
    if (_search.isNotEmpty) {
      history =
          history.where((item) {
            final model = (item['model'] ?? '').toString().toLowerCase();
            final user =
                (widget.type == HistoryType.purchase
                        ? (item['seller'] ?? '')
                        : (item['buyer'] ?? ''))
                    .toString()
                    .toLowerCase();
            return model.contains(_search.toLowerCase()) ||
                user.contains(_search.toLowerCase());
          }).toList();
    }
    // Buscador siempre visible
    final searchBar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar modelo o usuario',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Filtrar por fecha',
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange:
                    _fromDate != null && _toDate != null
                        ? DateTimeRange(start: _fromDate!, end: _toDate!)
                        : null,
              );
              if (picked != null) {
                setState(() {
                  _fromDate = picked.start;
                  _toDate = picked.end;
                });
              }
            },
          ),
          if (_fromDate != null || _toDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar filtro de fecha',
              onPressed:
                  () => setState(() {
                    _fromDate = null;
                    _toDate = null;
                  }),
            ),
        ],
      ),
    );
    if (isLoading) {
      return Column(
        children: [
          searchBar,
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }
    if (error != null) {
      return Column(
        children: [searchBar, Expanded(child: Center(child: Text(error)))],
      );
    }
    if (history.isEmpty) {
      return Column(
        children: [
          searchBar,
          const Expanded(child: Center(child: Text('No hay historial.'))),
        ],
      );
    }
    // Tarjetas laterales tipo "Mis drones"
    return Column(
      children: [
        searchBar,
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = history[i];
              final isSale = widget.type == HistoryType.sale;
              final color = isSale ? Colors.green.shade50 : Colors.blue.shade50;
              final icon = isSale ? Icons.sell : Icons.shopping_cart;
              final userLabel = isSale ? 'Comprador' : 'Vendedor';
              final userValue = isSale ? item['buyer'] : item['seller'];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSale ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: color,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['model'] ?? 'Modelo desconocido',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '${item['price']} ${item['currency']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSale ? Colors.green : Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(item['date']),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            if (userValue != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('$userLabel: $userValue'),
                                ],
                              ),
                            ],
                            if (item['description'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Descripción: ${item['description']}',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
