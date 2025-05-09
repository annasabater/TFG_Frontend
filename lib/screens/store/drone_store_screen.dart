// lib/screens/store/drone_store_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';
import 'all_tab.dart';
import 'favorites_tab.dart';
import 'my_drones_tab.dart';

class DroneStoreScreen extends StatefulWidget {
  const DroneStoreScreen({Key? key}) : super(key: key);

  @override
  State<DroneStoreScreen> createState() => _DroneStoreScreenState();
}

class _DroneStoreScreenState extends State<DroneStoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final DroneProvider _droneProv;
  late final UserProvider _userProv;

  @override
  void initState() {
    super.initState();

    // Agafem els providers però NO fem still notifyListeners() aquí
    _droneProv     = context.read<DroneProvider>();
    _userProv      = context.read<UserProvider>();
    _tabController = TabController(length: 3, vsync: this);

    // Ajornem la càrrega de dades fins després del primer build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _droneProv.loadDrones();
      _loadExtras();
    });
  }

  Future<void> _loadExtras() async {
    final uid = _userProv.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      await Future.wait([
        _droneProv.loadFavorites(uid),
        _droneProv.loadMyDrones(uid),
      ]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Botiga'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: scheme.onPrimary,
          unselectedLabelColor: scheme.onPrimary.withOpacity(0.7),
          indicatorColor: scheme.secondary,
          indicatorWeight: 4,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Tots'),
            Tab(text: 'Favorits'),
            Tab(text: 'Els meus'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AllTab(),
          FavoritesTab(),
          MyDronesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/store/add'),
        tooltip: 'Nou anunci',
        child: const Icon(Icons.add),
      ),
    );
  }
}
