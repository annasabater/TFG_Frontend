// lib/screens/history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/users_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final userProv = context.read<UserProvider>();
    userProv.fetchPurchaseHistory();
    userProv.fetchSalesHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Compras'), Tab(text: 'Ventas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HistoryList(type: HistoryType.purchase),
          _HistoryList(type: HistoryType.sale),
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error));
    }
    if (history.isEmpty) {
      return const Center(child: Text('No hay historial.'));
    }
    return Column(
      children: [
        Padding(
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
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, i) {
              final item = history[i];
              final isSale = widget.type == HistoryType.sale;
              final color = isSale ? Colors.green.shade50 : Colors.blue.shade50;
              final icon = isSale ? Icons.sell : Icons.shopping_cart;
              final userLabel = isSale ? 'Comprador' : 'Vendedor';
              final userValue = isSale ? item['buyer'] : item['seller'];
              return Card(
                color: color,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSale ? Colors.green : Colors.blue,
                    child: Icon(icon, color: Colors.white),
                  ),
                  title: Text(
                    item['model'] ?? 'Modelo desconocido',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${item['date'] ?? '-'}'),
                      if (userValue != null) Text('$userLabel: $userValue'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item['price']} ${item['currency']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSale ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  icon,
                                  color: isSale ? Colors.green : Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(item['model'] ?? 'Modelo desconocido'),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fecha: ${item['date'] ?? '-'}'),
                                Text(
                                  'Precio: ${item['price']} ${item['currency']}',
                                ),
                                if (userValue != null)
                                  Text('$userLabel: $userValue'),
                                if (item['description'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Descripción: ${item['description']}',
                                    ),
                                  ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
