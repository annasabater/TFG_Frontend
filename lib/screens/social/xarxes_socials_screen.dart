// lib/screens/social/xarxes_socials_screen.dart

import 'package:flutter/material.dart';
import 'package:SkyNet/screens/social/explore_screen.dart';
import 'package:SkyNet/screens/social/feed_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class XarxesSocialsScreen extends StatelessWidget {
  const XarxesSocialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //  Header "Red Social"
        body: Column(
          children: [
            Container(
              height: 56,
              color: theme.colorScheme.primary,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.socialNetwork,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Botón para ir a la pantalla de seguidos
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.people_alt_outlined),
                  label: Text(AppLocalizations.of(context)!.seeFollowing),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () => context.go('/following'),
                ),
              ],
            ),

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
                  Tab(icon: const Icon(Icons.explore_outlined), text: AppLocalizations.of(context)!.exploreTab),
                  Tab(
                    icon: const Icon(Icons.dynamic_feed_outlined),
                    text: AppLocalizations.of(context)!.followingTab,
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
