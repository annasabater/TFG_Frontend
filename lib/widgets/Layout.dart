import 'package:SkyNet/api/google_signin_api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/users_provider.dart';
import '../provider/theme_provider.dart';
import '../widgets/language_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  final settingsRoute = '/settings';

  const LayoutWrapper({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    // Obtener provider de usuarios
    final usersProv = context.watch<UserProvider?>();
    final currentUser = usersProv?.currentUser;

    // Si aún no está disponible el usuario, mostramos loader
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final admin = usersProv!.isAdmin;
    final email = currentUser.email.toLowerCase();
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    const droneEmails = {
      'dron_azul1@upc.edu',
      'dron_verde1@upc.edu',
      'dron_rojo1@upc.edu',
      'dron_amarillo1@upc.edu',
    };
    bool isInvitado(String e) => RegExp(r'^invitado\d+@upc\.edu\$').hasMatch(e);
    bool isRoute(String r) => GoRouterState.of(context).uri.toString() == r;

    // Construcción de los ítems de navegación
    List<Widget> navItems = [
      _navItem(context, loc.home, Icons.home, '/', isRoute('/')),
    ];

    if (droneEmails.contains(email)) {
      navItems.add(_navItem(context, loc.games, Icons.sports_esports, '/jocs', isRoute('/jocs')));
      navItems.add(
        _navItem(context, loc.settings, Icons.settings, settingsRoute, isRoute(settingsRoute)),
      );
    } else if (isInvitado(email)) {
      navItems.addAll([
        _navItem(context, loc.socialNetwork, Icons.people, '/xarxes', isRoute('/xarxes')),
        _navItem(context, loc.chat, Icons.chat, '/chat', isRoute('/chat')),
        _navItem(context, loc.spectateGames, Icons.visibility, '/jocs/spectate', isRoute('/jocs/spectate')),
      ]);
      navItems.add(
        _navItem(context, loc.settings, Icons.settings, settingsRoute, isRoute(settingsRoute)),
      );
    } else {
      navItems.addAll([
        _navItem(context, loc.socialNetwork, Icons.people, '/xarxes', isRoute('/xarxes')),
        _navItem(context, loc.chat, Icons.chat, '/chat', isRoute('/chat')),
        _navItem(context, loc.profile, Icons.account_circle, '/profile', isRoute('/profile')),
        _navItem(context, loc.map, Icons.map, '/mapa', isRoute('/mapa')),
        _navItem(context, loc.store, Icons.store, '/store', isRoute('/store')),
        _navItem(context, loc.spectateGames, Icons.visibility, '/jocs/spectate', isRoute('/jocs/spectate')),
        _navItem(context, loc.playTesting, Icons.videogame_asset, '/play-testing', isRoute('/play-testing')),
        if (admin)
          _navItem(context, loc.adminDetails, Icons.admin_panel_settings, '/detalles', isRoute('/detalles')),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Consumer<ThemeProvider>(
            builder: (_, t, __) => IconButton(
              icon: Icon(t.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              tooltip: t.isDarkMode ? loc.lightMode : loc.darkMode,
              onPressed: () => t.toggleTheme(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: Material(
            color: scheme.surface,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 220, child: _header(scheme)),
                ...navItems.map((item) {
                  bool isSelected = item is ListTile && item.selected;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primaryContainer.darken(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: scheme.primary.withOpacity(0.10),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: item,
                    ),
                  );
                }),
                const Divider(height: 24),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: scheme.surfaceContainerHighest.withOpacity(.10),
        child: child,
      ),
    );
  }

  DrawerHeader _header(ColorScheme scheme) => DrawerHeader(
        decoration: BoxDecoration(color: scheme.primary),
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/logo_skynet.png'),
            ),
            const SizedBox(height: 12),
            const Icon(Icons.people_alt_rounded, color: Colors.white, size: 30),
            const SizedBox(height: 12),
            Text(
              'S K Y N E T',
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      );

  ListTile _navItem(
    BuildContext ctx,
    String title,
    IconData icon,
    String route,
    bool selected,
  ) {
    final scheme = Theme.of(ctx).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? scheme.primary : scheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? scheme.primary : scheme.onSurface,
        ),
      ),
      selected: selected,
      selectedTileColor: scheme.primaryContainer.withOpacity(.30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Navigator.pop(ctx);
        ctx.go(route);
      },
    );
  }
}

// Extensión para oscurecer un color
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
