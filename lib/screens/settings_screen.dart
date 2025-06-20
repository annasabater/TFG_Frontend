import 'package:SkyNet/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/api/google_signin_api.dart';
import '../provider/theme_provider.dart';
import '../provider/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProv = Provider.of<ThemeProvider>(context);
    final langProv = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: langProv.currentLocale.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'ca', child: Text('Català')),
              ],
              onChanged: (v) {
                if (v != null) langProv.setLanguage(v);
              },
            ),
          ),
          ListTile(
            leading: Icon(themeProv.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            title: Text(loc.darkMode),
            trailing: Switch(
              value: themeProv.isDarkMode,
              onChanged: (_) => themeProv.toggleTheme(),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility),
            title: Text(loc.daltonicMode),
            value: themeProv.isDaltonicMode,
            onChanged: (_) => themeProv.toggleDaltonicMode(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.menu_book),
            title: Text(loc.readingMode),
            value: themeProv.isReadingMode,
            onChanged: (_) => themeProv.toggleReadingMode(),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(loc.logout, style: const TextStyle(color: Colors.redAccent)),
            onTap: () {
              AuthService().logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
