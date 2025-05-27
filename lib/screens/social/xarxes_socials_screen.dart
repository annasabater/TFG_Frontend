// lib/screens/social/xarxes_socials_screen.dart

import 'package:flutter/material.dart';
import 'package:SkyNet/screens/social/explore_screen.dart';
import 'package:SkyNet/screens/social/feed_screen.dart';

class XarxesSocialsScreen extends StatelessWidget {
  const XarxesSocialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //  Header “Red Social” 
        body: Column(
          children: [
            Container(
              height: 56,
              color: theme.colorScheme.primary,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Red Social',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(icon: Icon(Icons.explore_outlined), text: 'EXPLORAR'),
                  Tab(icon: Icon(Icons.dynamic_feed_outlined), text: 'SIGUIENDO'),
                ],
              ),
            ),

            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                children: const [
                  ExploreScreen(),
                  FeedScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
