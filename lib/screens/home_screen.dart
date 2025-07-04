import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:SkyNet/widgets/Layout.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga usuarios / sesión
    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).loadUsers(),
    );
  }

  /// Comprueba si el correo pertenece a uno de los 4 drones
  bool _isDroneMail(String? mail) {
    const drones = {
      'dron_rojo1@upc.edu',
      'dron_azul1@upc.edu',
      'dron_verde1@upc.edu',
      'dron_amarillo1@upc.edu',
    };
    return mail != null && drones.contains(mail.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final loc         = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth   = screenWidth > 600 ? 320.0 : screenWidth * 0.7;

    // Obtener e-mail del usuario actual
    final userProv  = context.watch<UserProvider>();
    final userEmail = userProv.currentUser?.email;
    final isDrone   = _isDroneMail(userEmail);

    // Definir lista de features
    final features = <Map<String, dynamic>>[
      {
        'image'      : 'assets/game.jpeg',
        'title'      : isDrone ? loc.gamesTitle           : loc.menuMiniGamesTitle,
        'description': isDrone ? loc.gameDescriptiontitle : loc.gamesFeatureDescription,
        'route'      : isDrone ? '/jocs'                  : '/play-testing',
        'color'      : Colors.orangeAccent,
      },
      {
        'image'      : 'assets/barcelona.jpg',
        'title'      : loc.mapsTitle,
        'description': loc.mapFeatureDescription,
        'route'      : '/mapa',
        'color'      : Colors.deepPurpleAccent,
      },
      {
        'image'      : 'assets/settings.jpg',
        'title'      : loc.configurationFeatureTitle,
        'description': loc.configurationFeatureDescription,
        'route'      : '/settings',
        'color'      : Colors.blueAccent,
      },
    ];

    // Si NO es dron, añado la tarjeta de espectador
    if (!isDrone) {
      features.add({
        'image'      : 'assets/espectador.jpg',
        'title'      : loc.spectateSessionsTitle,
        'description': loc.spectateGames,
        'route'      : '/jocs/spectate',
        'color'      : Colors.green,  
      });
    }

    return LayoutWrapper(
      title: loc.home,
      child: SingleChildScrollView(
        child: Column(
          children: [
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
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
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
                  Text(loc.appDescription,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Text(loc.features,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        final f = features[index];
                        return _DashboardButton(
                          image      : f['image']      as String,
                          title      : f['title']      as String,
                          description: f['description']as String,
                          route      : f['route']      as String,
                          color      : f['color']      as Color,
                          maxWidth   : cardWidth,
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
      onExit:  (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale   : _hovering ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve   : Curves.easeInOut,
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
                color       : _hovering ? widget.color.withOpacity(0.10) : colors.surface,
                boxShadow   : [
                  BoxShadow(
                    color     : widget.color.withOpacity(0.13),
                    blurRadius: _hovering ? 18 : 10,
                    offset    : const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: widget.color.withOpacity(_hovering ? 0.7 : 0.3),
                  width: _hovering ? 2.5 : 1.2,
                ),
              ),
              child: Column(
                mainAxisSize      : MainAxisSize.min,
                mainAxisAlignment : MainAxisAlignment.center,
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
                      fontSize  : 21,
                      fontWeight: FontWeight.bold,
                      color     : widget.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      widget.description,
                      textAlign   : TextAlign.center,
                      style       : TextStyle(fontSize: 15.5, color: colors.onSurfaceVariant),
                      maxLines    : 3,
                      overflow    : TextOverflow.ellipsis,
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
