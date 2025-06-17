// lib/screens/social/xarxes_socials_screen.dart

import 'package:flutter/material.dart';
import 'package:SkyNet/screens/social/explore_screen.dart';
import 'package:SkyNet/screens/social/feed_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/provider/theme_provider.dart';
import 'package:SkyNet/widgets/language_selector.dart';

class XarxesSocialsScreen extends StatelessWidget {
  const XarxesSocialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text(loc.socialNetwork),
          actions: [
            IconButton(
              icon: const Icon(Icons.people_alt_outlined),
              tooltip: loc.seeFollowing,
              onPressed: () => context.go('/following'),
            ),
            const LanguageSelector(),
            Consumer<ThemeProvider>(
              builder: (_, t, __) => IconButton(
                icon: Icon((t.isDarkMode) ? Icons.dark_mode : Icons.light_mode),
                tooltip: (t.isDarkMode) ? loc.lightMode : loc.darkMode,
                onPressed: () => t.toggleTheme(),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // TabBar justo debajo, fondo blanco
            Material(
              color: Colors.white,
              child: TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 24),
                ),
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(icon: const Icon(Icons.explore_outlined), text: loc.exploreTab),
                  Tab(
                    icon: const Icon(Icons.dynamic_feed_outlined),
                    text: loc.followingTab,
                  ),
                ],
              ),
            ),
            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                children: const [ExploreScreen(), FeedScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
