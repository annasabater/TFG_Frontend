// lib/screens/social/user_profile_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../provider/theme_provider.dart';
import '../../services/social_service.dart';
import '../../widgets/post_card.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _user;
  List<Post> _posts = [];
  bool _loading = true;
  bool _following = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final data = await SocialService.getUserWithPosts(widget.userId);
      setState(() {
        _user      = data['user'];
        _posts     = List<Post>.from(data['posts']);
        _following = data['following'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    try {
      if (_following) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Dejar de seguir'),
            content: Text('¿Quieres dejar de seguir a ${_user!['userName']}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Sí'),
              ),
            ],
          ),
        );
        if (confirm != true) return;
        await SocialService.unFollow(widget.userId);
      } else {
        await SocialService.follow(widget.userId);
      }
      await _loadProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al ${_following ? 'dejar de seguir' : 'seguir'}: $e')),
      );
    }
  }

  int _columnsForWidth(double w) {
    if (w >= 1280) return 4;
    if (w >= 1024) return 3;
    if (w >= 650)  return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final isDark    = themeProv.isDarkMode;
    final scheme    = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // Usamos el color por defecto del AppBar para mantener consistencia
        // backgroundColor y elevation quedan como los del tema global
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(''),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProv.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: scheme.primary,
              onRefresh: _loadProfile,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: scheme.primary.withOpacity(.2),
                            child: Text(
                              (_user!['userName'] as String)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _user!['userName'],
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _following
                                      ? scheme.secondaryContainer
                                      : scheme.primary,
                                ),
                                child: Text(
                                  _following ? 'Siguiendo' : 'Seguir',
                                  style: TextStyle(
                                    color: _following
                                        ? scheme.onSecondaryContainer
                                        : scheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Mensaje'),
                                onPressed: () =>
                                    context.go('/chat/${widget.userId}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final p = _posts[i];
                          return PostCard(
                            post: p,
                            onLike: () async {
                              await SocialService.like(p.id);
                              setState(() {
                                p.likedByMe = !p.likedByMe;
                                p.likes += p.likedByMe ? 1 : -1;
                              });
                            },
                          );
                        },
                        childCount: _posts.length,
                      ),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            _columnsForWidth(MediaQuery.of(context).size.width),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
