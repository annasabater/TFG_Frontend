//lib/screens/store/drone_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/drone.dart';
import '../../models/drone_query.dart';
import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';

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
        DroneQuery(category: widget.categoryFilter),
      );
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
          child: Row(
            children: [
              Expanded(
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
              const SizedBox(width: 8),
              _CurrencySelector(),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: Consumer<DroneProvider>(
            builder: (_, p, __) {
              if (p.isLoading)
                return const Center(child: CircularProgressIndicator());
              if (p.error != null) return Center(child: Text(p.error!));
              if (p.drones.isEmpty)
                return const Center(child: Text('No hi ha anuncis'));

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
    final img =
        (drone.images?.isNotEmpty ?? false) ? drone.images!.first : null;
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final myId = userProv.currentUser?.id;
    final currency = context.watch<DroneProvider>().currency;
    final symbol = _CurrencySelector.symbols[currency] ?? currency;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              img != null
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
        subtitle: Text(
          '${drone.price.toStringAsFixed(0)} $symbol • ${(drone.location ?? '-')}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            myId == drone.ownerId
                ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: IconButton(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey,
                          size: 22,
                        ),
                        tooltip: 'Eres el anunciante',
                        onPressed: null,
                      ),
                    ),
                    const Positioned(
                      child: Icon(
                        Icons.block,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ],
                )
                : IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.teal,
                    size: 22,
                  ),
                  tooltip: 'Chat con el creador',
                  onPressed: () {
                    GoRouter.of(context).go('/chat/ 24{drone.ownerId}');
                  },
                ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap:
            () => context.pushNamed(
              'droneDetail',
              pathParameters: {'id': drone.id},
              extra: drone,
            ),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  static const currencies = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
    'HKD',
    'NZD',
  ];
  static const symbols = {
    'EUR': '€',
    'USD': ' 24',
    'GBP': '£',
    'JPY': '¥',
    'CHF': 'Fr',
    'CAD': 'C 24',
    'AUD': 'A 24',
    'CNY': '¥',
    'HKD': 'HK 24',
    'NZD': 'NZ 24',
  };

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DroneProvider>();
    return DropdownButton<String>(
      value: prov.currency,
      icon: Icon(_getCurrencyIcon(prov.currency)),
      underline: Container(),
      onChanged: (v) {
        if (v != null) prov.currency = v;
      },
      items:
          currencies.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  Icon(_getCurrencyIcon(c)),
                  const SizedBox(width: 4),
                  Text(c),
                ],
              ),
            );
          }).toList(),
    );
  }

  IconData _getCurrencyIcon(String currency) {
    switch (currency) {
      case 'EUR':
        return Icons.euro;
      case 'USD':
        return Icons.attach_money;
      case 'GBP':
        return Icons.currency_pound;
      case 'JPY':
        return Icons.currency_yen;
      case 'CHF':
        return Icons.currency_franc;
      case 'CAD':
        return Icons.currency_exchange;
      case 'AUD':
        return Icons.currency_exchange;
      case 'CNY':
        return Icons.currency_yen;
      case 'HKD':
        return Icons.currency_exchange;
      case 'NZD':
        return Icons.currency_exchange;
      default:
        return Icons.attach_money;
    }
  }
}
