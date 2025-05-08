// lib/widgets/Layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';
import '../services/auth_service.dart';
import '../provider/theme_provider.dart';
import '../widgets/language_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const LayoutWrapper({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserProvider>();
    final restricted = prov.isRestricted;
    final admin = prov.isAdmin;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        actions: [
          const LanguageSelector(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              tooltip: themeProvider.isDarkMode ? localizations.lightMode : localizations.darkMode,
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        children: [
          _header(context),
          _buildNavItem(context, localizations.home, Icons.home, '/'),

          if (!restricted) ...[
            _buildNavItem(context, localizations.users, Icons.info_outline, '/details'),

            if (admin)
              _buildNavItem(context, localizations.createUser, Icons.person_add, '/editar'),

            if (admin)
              _buildNavItem(context, localizations.deleteUser, Icons.delete_outline, '/borrar'),

            _buildNavItem(context, localizations.profile, Icons.account_circle, '/profile'),
          ],

          _buildNavItem(context, localizations.games, Icons.sports_esports, '/jocs'),
          _buildNavItem(context, localizations.map, Icons.map, '/mapa'),
          _buildNavItem(context, localizations.chat, Icons.chat, '/chat'),
          const Divider(),
          _reloadButton(context),
          _logoutButton(context),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        child: child,
      ),
    );
  }

  DrawerHeader _header(BuildContext context) => DrawerHeader(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    double logoSize = constraints.maxHeight * 0.35;
                    logoSize = logoSize.clamp(40, 90);
                    return Image.asset(
                      'assets/logo_skynet.png',
                      width: logoSize,
                      height: logoSize,
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Icon(Icons.people_alt_rounded, size: 30, color: Colors.white),
                const SizedBox(height: 8),
                Text('S K Y N E T',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )),
              ],
            ),
          ),
        ),
      );

  Padding _reloadButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<UserProvider>().loadUsers();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.refresh),
        label: Text(localizations.reloadUsers),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
      ),
    );
  }

  Padding _logoutButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () async {
          await AuthService().logout();
          if (context.mounted) {
            Navigator.pop(context);
            GoRouter.of(context).go('/login');
          }
        },
        icon: const Icon(Icons.logout),
        label: Text(localizations.logout),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(45),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ListTile _buildNavItem(BuildContext context, String title, IconData icon, String route) {
    final isSelected = GoRouterState.of(context).uri.toString() == route;
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isSelected ? scheme.primary : scheme.onSurface),
      title: Text(title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? scheme.primary : scheme.onSurface,
          )),
      selected: isSelected,
      selectedTileColor: scheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
