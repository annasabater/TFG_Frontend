// lib/screens/social/feed_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/auth_service.dart';
import '../../models/post.dart';
import '../../provider/social_provider.dart';
import '../../widgets/post_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _scroll = ScrollController();
  late final String _myId;

  @override
  void initState() {
    super.initState();
    // Obtengo mi ID para filtrar mis propias publicaciones
    _myId = AuthService().currentUser?['_id'] as String;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialProvider>().loadFeed();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
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

  Widget _empty(ColorScheme scheme) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty,
                size: 60, color: scheme.primary.withOpacity(.6)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.noFollowedPosts,
                style: TextStyle(fontSize: 18, color: scheme.onSurfaceVariant)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      color: scheme.primary,
      onRefresh: () => context.read<SocialProvider>().loadFeed(refresh: true),
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 12),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Consumer<SocialProvider>(
            builder: (_, prov, __) {
              // Filtrar mis propias publicaciones
              final allPosts = prov.feed;
              final posts = allPosts.where((p) => p.authorId != _myId).toList();
              final loading = prov.feedLoading && posts.isEmpty;
              final cols    = _columnsForWidth(MediaQuery.of(context).size.width);
              final ratio   = .78;
              final spacing = 16.0;

              if (loading) {
                return SliverGrid.count(
                  crossAxisCount: cols,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: ratio,
                  children: List.generate(6, (_) => _shimmerCard()),
                );
              } else if (posts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _empty(scheme),
                );
              } else {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final Post p = posts[i];
                        return PostCard(
                          post: p,
                          onLike: () => prov.toggleLike(p),
                        );
                      },
                      childCount: posts.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: ratio,
                    ),
                  ),
                );
              }
            },
          ),
          SliverToBoxAdapter(
            child: Consumer<SocialProvider>(
              builder: (_, prov, __) {
                final posts = prov.feed.where((p) => p.authorId != _myId).toList();
                return prov.feedLoading && posts.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            radius: 14,
                            color: scheme.primary,
                          ),
                        ),
                      )
                    : const SizedBox(height: 60);
              },
            ),
          ),
        ],
      ),
    );
  }
}
