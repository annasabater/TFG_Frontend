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

class _HistoryList extends StatelessWidget {
  final HistoryType type;
  const _HistoryList({required this.type});

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final isLoading = userProv.isHistoryLoading;
    final error = userProv.historyError;
    final history =
        type == HistoryType.purchase
            ? userProv.purchaseHistory
            : userProv.salesHistory;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error));
    }
    if (history.isEmpty) {
      return const Center(child: Text('No hay historial.'));
    }
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, i) {
        final item = history[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(item['model'] ?? 'Modelo desconocido'),
            subtitle: Text('Fecha: ${item['date'] ?? '-'}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item['price']} ${item['currency']}'),
                if (type == HistoryType.sale && item['buyer'] != null)
                  Text(
                    'Comprador: ${item['buyer']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                if (type == HistoryType.purchase && item['seller'] != null)
                  Text(
                    'Vendedor: ${item['seller']}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
