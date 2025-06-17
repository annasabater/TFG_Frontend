import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:SkyNet/widgets/Layout.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  //final GoogleSignInAccount user;
  //const HomeScreen({Key? key,}) : super (key: key);
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<UserProvider>(context, listen: false).loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Definir ancho de tarjeta: máximo 320px en desktop, 70% en móvil
    double cardWidth = screenWidth * 0.7;
    if (screenWidth > 600) {
      cardWidth = 320;
    }

    return LayoutWrapper(
      title: loc.home,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/drones_banner.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 24,
                  right: 24,
                  child: Text(
                    loc.welcomeMessage,
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(2, 2))
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.appDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    loc.features,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Feature Cards Scroll adaptado a móvil y PC
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final features = [
                          {
                            'image': 'assets/drones_store.webp',
                            'title': loc.storeFeatureTitle,
                            'description': loc.storeFeatureDescription,
                            'route': '/store',
                            'color': Colors.deepPurpleAccent,
                          },
                          {
                            'image': 'assets/drones_community.webp',
                            'title': loc.socialFeatureTitle,
                            'description': loc.socialFeatureDescription,
                            'route': '/xarxes',
                            'color': Colors.blueAccent,
                          },
                          {
                            'image': 'assets/drones_chat.webp',
                            'title': loc.chatFeatureTitle,
                            'description': loc.chatFeatureDescription,
                            'route': '/chat',
                            'color': Colors.green,
                          },
                          {
                            'image': 'assets/drones_games.webp',
                            'title': loc.gamesFeatureTitle,
                            'description': loc.gamesFeatureDescription,
                            'route': '/jocs',
                            'color': Colors.orangeAccent,
                          },
                        ];

                        final feature = features[index];

                        return _DashboardButton(
                          image: feature['image'] as String,
                          title: feature['title'] as String,
                          description: feature['description'] as String,
                          route: feature['route'] as String,
                          color: feature['color'] as Color,
                          maxWidth: cardWidth,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final Color color;
  final String route;
  final double maxWidth;

  const _DashboardButton({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.color,
    required this.route,
    required this.maxWidth,
  });

  @override
  State<_DashboardButton> createState() => _DashboardButtonState();
}

class _DashboardButtonState extends State<_DashboardButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => context.go(widget.route),
            child: Container(
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: _hovering ? widget.color.withOpacity(0.10) : colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.13),
                    blurRadius: _hovering ? 18 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: widget.color.withOpacity(_hovering ? 0.7 : 0.3),
                  width: _hovering ? 2.5 : 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.asset(
                      widget.image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
