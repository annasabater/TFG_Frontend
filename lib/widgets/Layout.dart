// lib/widgets/Layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const LayoutWrapper({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    final prov       = context.watch<UserProvider>();
    final restricted = prov.isRestricted;
    final admin      = prov.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      drawer: NavigationDrawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        children: [
          _header(context),
          _buildNavItem(context, 'Home', Icons.home, '/'),

          // ---------- Menú complet per a no restringits ------------------
          if (!restricted) ...[
            _buildNavItem(context, 'Usuaris', Icons.info_outline, '/details'),

            if (admin)
              _buildNavItem(context, 'Crear usuari', Icons.person_add, '/editar'),

            if (admin)
              _buildNavItem(context, 'Esborrar usuari', Icons.delete_outline, '/borrar'),

            _buildNavItem(context, 'Perfil', Icons.account_circle, '/profile'),
          ],

          _buildNavItem(context, 'Jocs', Icons.sports_esports, '/jocs'),
          const Divider(),
          _reloadButton(context),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        child: child,
      ),
    );
  }

  // -- Auxiliars (sense canvis rellevants) -------------------------------
  DrawerHeader _header(BuildContext context) => DrawerHeader(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_alt_rounded, size: 60, color: Colors.white),
              const SizedBox(height: 12),
              Text('S K Y N E T',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ],
          ),
        ),
      );

  Padding _reloadButton(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            context.read<UserProvider>().loadUsers();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Carregar usuaris'),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
        ),
      );

  ListTile _buildNavItem(BuildContext context, String title, IconData icon, String route) {
    final isSelected = GoRouterState.of(context).uri.toString() == route;
    final scheme     = Theme.of(context).colorScheme;

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
