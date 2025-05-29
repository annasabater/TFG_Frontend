// lib/screens/perfil_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/auth_service.dart';
import '../services/social_service.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../provider/theme_provider.dart';
import '../provider/language_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late final String _myUserId;
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _myUserId = AuthService().currentUser?['_id'] as String;
    _postsFuture = SocialService.getMyPosts();
  }

  void _loadMyPostsFromFeed() {
    _postsFuture = SocialService.getMyPosts();
  }

  void _openSettingsMenu() {
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    final langProv  = Provider.of<LanguageProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar Perfil'),
            onTap: () {
              Navigator.pop(c);
              context.go('/profile/edit');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
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
            leading: const Icon(Icons.dark_mode),
            title: const Text('Modo oscuro'),
            trailing: Switch(
              value: themeProv.isDarkMode,
              onChanged: (_) => themeProv.toggleTheme(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              AuthService().logout();
              context.go('/login');
            },
          ),
        ]),
      ),
    );
  }

  int _columnsForWidth(double w) {
    if (w >= 1280) return 4;
    if (w >= 1024) return 3;
    if (w >= 650)  return 2;
    return 1;
  }

  Widget _shimmerCard() => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettingsMenu)
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create'),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nuevo post'),
      ),
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: () {
          setState(_loadMyPostsFromFeed);
          return _postsFuture;
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Column(children: [
              Image.asset('assets/logo_skynet.png', width: 100),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 70,
                backgroundColor: scheme.primary,
                child: const Icon(Icons.person, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                AuthService().currentUser?['userName'] ?? '',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AuthService().currentUser?['email'] ?? '',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ]),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.people_alt_outlined),
              label: const Text('Ver seguidos / Buscar usuarios'),
              onPressed: () => context.go('/following'),
            ),
            const SizedBox(height: 32),

            FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                        child: CircularProgressIndicator(color: scheme.primary)),
                  );
                }
                if (snap.hasError) {
                  return Center(child: Text('Error cargando tus posts'));
                }
                final posts = snap.data!;
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty,
                            size: 60, color: scheme.primary.withOpacity(.6)),
                        const SizedBox(height: 12),
                        Text(
                          'Aún no has publicado nada',
                          style: TextStyle(
                              fontSize: 18, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(builder: (ctx, cons) {
                  final cols    = _columnsForWidth(cons.maxWidth);
                  final spacing = 16.0;
                  final ratio   = .78;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: ratio,
                    ),
                    itemBuilder: (_, i) {
                      final post = posts[i];
                      return PostCard(
                        post: post,
                        onLike: () => SocialService.like(post.id)
                            .then((_) {
                          setState(() {
                            post.likedByMe = !post.likedByMe;
                            post.likes += post.likedByMe ? 1 : -1;
                          });
                        }),
                      );
                    },
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
