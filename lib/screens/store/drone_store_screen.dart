// lib/screens/store/drone_store_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';
import '../../provider/cart_provider.dart';
import 'all_tab.dart';
import '../../widgets/balance_form.dart';
import '../../widgets/cart_modal.dart';
import '../history/history_screen.dart';
import '../../widgets/language_selector.dart';
import '../../provider/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DroneStoreScreen extends StatefulWidget {
  const DroneStoreScreen({Key? key}) : super(key: key);

  @override
  State<DroneStoreScreen> createState() => _DroneStoreScreenState();
}

class _DroneStoreScreenState extends State<DroneStoreScreen>
    with SingleTickerProviderStateMixin {
  late final DroneProvider _droneProv;
  late final UserProvider _userProv;
  bool _changingCurrency = false;

  @override
  void initState() {
    super.initState();

    _droneProv = context.read<DroneProvider>();
    _userProv = context.read<UserProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = _userProv.currentUser?.id;
      _droneProv.setUserIdForReload(uid);
      _droneProv.loadDrones();
      _loadExtras();
      // Refrescar saldo al entrar
      if (uid != null && uid.isNotEmpty) {
        await Provider.of<CartProvider>(
          context,
          listen: false,
        ).fetchUserBalances(uid);
      }
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

  Future<void> _changeCurrency(BuildContext context, String value) async {
    setState(() => _changingCurrency = true);
    final prov = Provider.of<DroneProvider>(context, listen: false);
    // Usa la página y límite actuales del provider
    final page = prov.currentPage;
    final limit = prov.currentLimit;
    prov.currency = value;
    await prov.loadDrones(page: page, limit: limit);
    // Refrescar saldo al cambiar divisa
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final cartProv = Provider.of<CartProvider>(context, listen: false);
    final uid = userProv.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      await cartProv.fetchUserBalances(uid);
    }
    setState(() => _changingCurrency = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.store),
        actions: [
          const LanguageSelector(),
          Consumer<ThemeProvider>(
            builder: (_, t, __) => IconButton(
              icon: Icon(t.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              tooltip: t.isDarkMode ? AppLocalizations.of(context)!.lightMode : AppLocalizations.of(context)!.darkMode,
              onPressed: () => t.toggleTheme(),
            ),
          ),
          if (_changingCurrency)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          Builder(
            builder: (context) {
              final userProv = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final cartProv = Provider.of<CartProvider>(
                context,
                // listen: true para que se actualice el saldo
                listen: true,
              );
              final droneProv = Provider.of<DroneProvider>(
                context,
                listen: false,
              );
              final currency = droneProv.currency;
              final saldo =
                  cartProv.balances[currency]?.toStringAsFixed(2) ?? '0.00';
              return GestureDetector(
                onTap: () async {
                  final uid = userProv.currentUser?.id;
                  if (uid != null && uid.isNotEmpty) {
                    await cartProv.fetchUserBalances(uid);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Chip(
                    avatar: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.amber,
                      size: 20,
                    ),
                    label: Text(
                      'Saldo: $saldo $currency',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.amber.withOpacity(0.1),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de compras/ventas',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          // Cambio de moneda
          Consumer<DroneProvider>(
            builder: (context, droneProv, _) {
              return PopupMenuButton<String>(
                icon: Row(
                  children: [
                    const Icon(Icons.currency_exchange),
                    const SizedBox(width: 4),
                    Text(
                      droneProv.currency,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                tooltip: 'Cambiar divisa',
                onSelected: (value) async {
                  await _changeCurrency(context, value);
                },
                itemBuilder:
                    (context) =>
                        [
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
                            ]
                            .map(
                              (currency) => PopupMenuItem(
                                value: currency,
                                child: Text(currency),
                              ),
                            )
                            .toList(),
              );
            },
          ),
          // Icono de carrito
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    tooltip: 'Carrito',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const CartModal(),
                      );
                    },
                  ),
                  if (cart.items.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Icono de moneda para ingresar saldo
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.account_balance_wallet),
                  tooltip: 'Ingresar saldo',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BalanceForm()),
                    );
                  },
                ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AllTab(),
          if (_changingCurrency)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
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
