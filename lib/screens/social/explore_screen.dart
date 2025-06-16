// lib/screens/social/explore_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../provider/social_provider.dart';
import '../../services/social_service.dart';
import '../../widgets/post_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _queryCtrl = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  late final String _myId;

  @override
  void initState() {
    super.initState();
    // Obtenemos nuestro ID para filtrar
    _myId = AuthService().currentUser?['_id'] as String;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialProvider>().loadExplore();
    });
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (q.trim().isEmpty) {
        setState(() => _results = []);
        return;
      }
      final res = await SocialService.searchUsers(q.trim());
      setState(() => _results = res);
    });
  }

  int _columnsForWidth(double w) {
    if (w >= 1280) return 4;
    if (w >= 1024) return 3;
    if (w >= 650)  return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SocialProvider>();
    // Filtrar mis propios posts
    final allPosts = prov.explore;
    final posts = allPosts.where((p) => p.authorId != _myId).toList();
    final loading = prov.exploreLoading && posts.isEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _queryCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar usuarios…',
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        // Sugerencias de usuarios
        if (_results.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final u = _results[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(u['userName'][0])),
                  title: Text(u['userName']),
                  subtitle: Text(u['email']),
                  onTap: () => context.go('/u/${u['_id']}'),
                );
              },
            ),
          ),
        const Divider(height: 1),
        // Grid de posts
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => prov.loadExplore(refresh: true),
            child: LayoutBuilder(builder: (ctx, cons) {
              final cols = _columnsForWidth(cons.maxWidth);
              const spacing = 16.0;
              const ratio = .78;

              if (loading) {
                // Placeholder mientras carga
                return GridView.count(
                  padding: const EdgeInsets.all(12),
                  crossAxisCount: cols,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: ratio,
                  children: List.generate(
                    6,
                    (_) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                );
              }

              if (posts.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.noOtherUserPosts));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: posts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: ratio,
                ),
                itemBuilder: (_, i) {
                  final p = posts[i];
                  return PostCard(
                    post: p,
                    onLike: () => prov.toggleLike(p),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
