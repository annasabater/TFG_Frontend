// lib/widgets/Layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/users_provider.dart';
import '../provider/theme_provider.dart';
import '../services/auth_service.dart';
import '../widgets/language_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const LayoutWrapper({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    final usersProv   = context.watch<UserProvider>();
    final restricted  = usersProv.isRestricted;
    final admin       = usersProv.isAdmin;
    final loc         = AppLocalizations.of(context)!;
    final scheme      = Theme.of(context).colorScheme;

    /* ------------- helpers para saber ruta seleccionada ------------- */
    bool _isRoute(String r) => GoRouterState.of(context).uri.toString() == r;
    bool _isSocialRoute() =>
        _isRoute('/feed') || _isRoute('/explore') || _isRoute('/create');

    /* ------------- UI ------------- */
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const LanguageSelector(),
          Consumer<ThemeProvider>(
            builder: (_, t, __) => IconButton(
              icon: Icon(t.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              tooltip: t.isDarkMode ? loc.lightMode : loc.darkMode,
              onPressed: () => t.toggleTheme(),
            ),
          ),
        ],
      ),

      /* ============== Drawer ============== */
      drawer: NavigationDrawer(
        backgroundColor: scheme.surface,
        children: [
          _header(scheme),

          /* HOME */
          _navItem(context, loc.home, Icons.home, '/', _isRoute('/')),

          /* --------------- SOCIAL MEDIA --------------- */
          ExpansionTile(
            initiallyExpanded: _isSocialRoute(),
            leading: Icon(Icons.people, color: scheme.onSurface),
            title: Text('Social Media',
                style: TextStyle(
                    fontWeight:
                        _isSocialRoute() ? FontWeight.bold : FontWeight.normal,
                    color: _isSocialRoute()
                        ? scheme.primary
                        : scheme.onSurface)),
            childrenPadding: const EdgeInsets.only(left: 16),
            children: [
              _navItem(context, 'Feed', Icons.dynamic_feed, '/feed',
                  _isRoute('/feed')),
              _navItem(context, 'Explorar', Icons.explore, '/explore',
                  _isRoute('/explore')),
              _navItem(context, 'Nuevo post', Icons.add_a_photo, '/create',
                  _isRoute('/create')),
            ],
          ),

          if (restricted) ...[
            _navItem(context, loc.games, Icons.sports_esports, '/jocs',
                _isRoute('/jocs')),
            _navItem(context, loc.chat, Icons.chat, '/chat',
                _isRoute('/chat')),
          ] else ...[
            _navItem(context, loc.users, Icons.info_outline, '/details',
                _isRoute('/details')),
            if (admin)
              _navItem(context, loc.createUser, Icons.person_add, '/editar',
                  _isRoute('/editar')),
            if (admin)
              _navItem(context, loc.deleteUser, Icons.delete_outline, '/borrar',
                  _isRoute('/borrar')),
            _navItem(context, loc.profile, Icons.account_circle, '/profile',
                _isRoute('/profile')),
            _navItem(context, loc.map, Icons.map, '/mapa', _isRoute('/mapa')),
            _navItem(context, loc.chat, Icons.chat, '/chat', _isRoute('/chat')),
            _navItem(context, loc.store, Icons.store, '/store',
                _isRoute('/store')),
          ],

          const Divider(),
          if (!restricted) _reloadButton(context, loc),
          _logoutButton(context, loc),
        ],
      ),

      body: Container(
        color: scheme.surfaceVariant.withOpacity(.10),
        child: child,
      ),
    );
  }

  /* ────────────────── Drawer Header ────────────────── */
  DrawerHeader _header(ColorScheme scheme) => DrawerHeader(
        decoration: BoxDecoration(color: scheme.primary),
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_skynet.png', width: 80),
            const SizedBox(height: 8),
            const Icon(Icons.people_alt_rounded, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text('S K Y N E T',
                style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
      );

  /* ────────────────── Items ────────────────── */
  ListTile _navItem(BuildContext ctx, String title, IconData icon, String route,
      bool selected) {
    final scheme = Theme.of(ctx).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? scheme.primary : scheme.onSurface),
      title: Text(title,
          style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? scheme.primary : scheme.onSurface)),
      selected: selected,
      selectedTileColor: scheme.primaryContainer.withOpacity(.30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Navigator.pop(ctx);
        ctx.go(route);
      },
    );
  }

  /* ────────────────── Botones especiales ────────────────── */
  Padding _reloadButton(BuildContext ctx, AppLocalizations loc) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            ctx.read<UserProvider>().loadUsers();
            Navigator.pop(ctx);
          },
          icon: const Icon(Icons.refresh),
          label: Text(loc.reloadUsers),
        ),
      );

  Padding _logoutButton(BuildContext ctx, AppLocalizations loc) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await AuthService().logout();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              ctx.go('/login');
            }
          },
          icon: const Icon(Icons.logout),
          label: Text(loc.logout),
        ),
      );
}
