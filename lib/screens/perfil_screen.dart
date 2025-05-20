// lib/screens/perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../provider/theme_provider.dart';
import '../provider/language_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = AuthService();
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      try {
        final res = await auth.getUserById(currentUser['_id']);
        setState(() {
          _user = res.containsKey('error') ? currentUser : res;
        });
      } catch (_) {
        setState(() {
          _user = currentUser;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _openSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
        final langProvider = Provider.of<LanguageProvider>(context, listen: true);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/profile/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Idioma'),
                trailing: DropdownButton<String>(
                  value: langProvider.currentLocale.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'ca', child: Text('Català')),
                  ],
                  onChanged: (code) {
                    if (code != null) langProvider.setLanguage(code);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Modo oscuro'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  AuthService().logout();
                  context.go('/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo_skynet.png', width: 100),
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.person, size: 70, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _user?['userName'] ?? '',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _user?['email'] ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
