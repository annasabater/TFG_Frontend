// lib/screens/store/drone_store_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';
import 'drone_list_screen.dart';

/// Pantalla principal de la botiga de drons
class DroneStoreScreen extends StatefulWidget {
  const DroneStoreScreen({super.key});

  @override
  State<DroneStoreScreen> createState() => _DroneStoreScreenState();
}

class _DroneStoreScreenState extends State<DroneStoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final DroneProvider _prov;
  late final UserProvider  _userProv;

  @override
  void initState() {
    super.initState();
    _prov     = context.read<DroneProvider>();
    _userProv = context.read<UserProvider>();
    _tab      = TabController(length: 3, vsync: this);
    _loadExtraLists();
  }

  Future<void> _loadExtraLists() async {
    final uid = _userProv.currentUser?.id;
    if (uid == null || uid.isEmpty) return;
    await Future.wait([
      _prov.loadFavorites(uid),
      _prov.loadMyDrones(uid),
    ]);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botiga de drons'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Tots'),
            Tab(text: 'Favorits'),
            Tab(text: 'Els meus'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          DroneListScreen(),   // llista completa
          _FavoritesTab(),
          _MyDronesTab(),
        ],
      ),
    );
  }
}

/* ---------------------- PESTANYA “FAVORITS” ---------------------- */

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (_, p, __) {
        if (p.isLoading)   return const Center(child: CircularProgressIndicator());
        if (p.error != null) return Center(child: Text(p.error!));
        if (p.favorites.isEmpty) return const Center(child: Text('Sense favorits'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: p.favorites.length,
          itemBuilder: (_, i) => _FavTile(drone: p.favorites[i]),
        );
      },
    );
  }
}

class _FavTile extends StatelessWidget {
  final drone;
  const _FavTile({required this.drone});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title:  Text(drone.model),
        subtitle: Text('${drone.price} €'),
      );
}

/* ---------------------- PESTANYA “ELS MEUS” ---------------------- */

class _MyDronesTab extends StatelessWidget {
  const _MyDronesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (_, p, __) {
        if (p.isLoading)   return const Center(child: CircularProgressIndicator());
        if (p.error != null) return Center(child: Text(p.error!));
        if (p.myDrones.isEmpty) return const Center(child: Text('Encara no tens anuncis'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: p.myDrones.length,
          itemBuilder: (_, i) => _MyTile(drone: p.myDrones[i]),
        );
      },
    );
  }
}

class _MyTile extends StatelessWidget {
  final drone;
  const _MyTile({required this.drone});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.flight_takeoff),
        title:  Text(drone.model),
        subtitle: Text('${drone.price} € • ${(drone.status ?? 'pending')}'),
      );
}
