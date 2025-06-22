import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Import directo de la pantalla PlujaAsteroides
import 'package:SkyNet/screens/mini_game/pluja_asteroides.dart';

class MenuJocsScreen extends StatelessWidget {
  const MenuJocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final cardSize = (screenWidth > 600) ? 180.0 : screenWidth * 0.4;

    final games = [
      {
        'widget': const PlujaAsteroidesScreen(),
        'title': loc.rainAsteroids,
        'icon': Icons.cloud_outlined,
        'description': loc.rainAsteroidsDescription,
      },
      {
        'route': '/play-testing/tap-target',
        'title': loc.tapTarget,
        'icon': Icons.my_location_outlined,
        'description': loc.tapTargetDescription,
      },
      {
        'route': '/play-testing/flappy-ball',
        'title': loc.flappyBall,
        'icon': Icons.sports_baseball_outlined,
        'description': loc.flappyBallDescription,
      },
      {
        'route': '/play-testing/reaction-test',
        'title': loc.reactionTest,
        'icon': Icons.flash_on_outlined,
        'description': loc.reactionTestDescription,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.menuMiniGamesTitle),
        backgroundColor: colors.primary,
        elevation: 2,
      ),
      backgroundColor: colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: games.map((game) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      if (game.containsKey('widget')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => game['widget'] as Widget,
                          ),
                        );
                      } else {
                        context.go(game['route'] as String);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: cardSize,
                      height: cardSize,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              game['icon'] as IconData,
                              size: 36,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            game['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(game['title'] as String),
                        content: Text(game['description'] as String),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(loc.ok),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: Text(loc.info),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
