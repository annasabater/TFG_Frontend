import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/post.dart';
import '../../provider/social_provider.dart';
import '../../widgets/Layout.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());

    final prov = context.read<SocialProvider>()..loadFeed();

    _scroll.addListener(() {
      final limit = _scroll.position.maxScrollExtent - 800;
      if (_scroll.position.pixels > limit && !prov.feedLoading) {
        prov.loadFeed();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /* ─────────── helpers ─────────── */

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
            Text('Sin publicaciones por el momento',
                style: TextStyle(fontSize: 18, color: scheme.onSurfaceVariant))
          ],
        ),
      );

  /* ─────────── build ─────────── */

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo post',
        onPressed: () => context.go('/create'),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: LayoutWrapper(
        title: 'Feed',
        child: Consumer<SocialProvider>(
          builder: (_, prov, __) {
            final posts            = prov.feed;
            final initialLoading   = prov.feedLoading && posts.isEmpty;

            return LayoutBuilder(builder: (ctx, c) {
              final cols     = _columnsForWidth(c.maxWidth);
              final ratio    = .78;                // ancho / alto  →  más alto
              final spacing  = 16.0;

              return RefreshIndicator(
                color: scheme.primary,
                onRefresh: () => prov.loadFeed(refresh: true),
                child: CustomScrollView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    /* separador decorativo arriba */
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

                    /* contenido principal */
                    if (initialLoading) ...[
                      SliverGrid.count(
                        crossAxisCount: cols,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: ratio,
                        children:
                            List.generate(6, (_) => _shimmerCard()),
                      ),
                    ] else if (posts.isEmpty) ...[
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _empty(scheme),
                      ),
                    ] else ...[
                      SliverPadding(
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            childAspectRatio: ratio,
                          ),
                        ),
                      ),
                    ],

                    /* loader inferior */
                    SliverToBoxAdapter(
                      child: prov.feedLoading && posts.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CupertinoActivityIndicator(
                                  radius: 14,
                                  color: scheme.primary,
                                ),
                              ),
                            )
                          : const SizedBox(height: 60),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
