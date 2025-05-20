// lib/screens/social/explore_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/post.dart';
import '../../provider/social_provider.dart';
import '../../services/social_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/post_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _queryCtrl = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = []; // resultados de usuarios

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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SocialProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      body: Column(
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
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => prov.loadExplore(refresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: prov.explore.length,
                itemBuilder: (_, i) {
                  final p = prov.explore[i];
                  return PostCard(
                    post: p,
                    onLike: () => prov.toggleLike(p),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
