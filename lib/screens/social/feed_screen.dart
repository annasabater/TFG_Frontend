// lib/screens/social/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/post.dart';
import '../../provider/social_provider.dart';
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
    final socialProv = context.read<SocialProvider>();
    socialProv.loadFeed();
    _scroll.addListener(() {
      if (_scroll.position.pixels >
          _scroll.position.maxScrollExtent - 400) {
        socialProv.loadFeed();
      }
    });
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (_, prov, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Feed'),
          centerTitle: false,
        ),
        body: RefreshIndicator(
          onRefresh: () => prov.loadFeed(refresh: true),
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: prov.feed.length,
            itemBuilder: (_, i) {
              final p = prov.feed[i];
              return PostCard(
                post: p,
                onLike: () => prov.toggleLike(p),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/create'),
          child: const Icon(Icons.add_a_photo_outlined),
        ),
      ),
    );
  }
}
