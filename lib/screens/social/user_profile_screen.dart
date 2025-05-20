// lib/screens/social/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/social_service.dart';
import '../../models/post.dart';
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
    _load();
  }

  Future<void> _load() async {
    final data = await SocialService.getUserWithPosts(widget.userId);
    setState(() {
      _user = data['user'];
      _posts = data['posts'];
      _following = data['following'];
      _loading = false;
    });
  }

  Future<void> _toggleFollow() async {
    _following
        ? await SocialService.unFollow(widget.userId)
        : await SocialService.follow(widget.userId);
    setState(() => _following = !_following);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?['userName'] ?? ''),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          child: Text(_user!['userName'][0]),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _user!['userName'],
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _toggleFollow,
                          child: Text(_following ? 'Siguiendo' : 'Seguir'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Mensaje'),
                          onPressed: () =>
                              context.go('/chat/${widget.userId}'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  GridView.builder(
                    padding: const EdgeInsets.all(4),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _posts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemBuilder: (_, i) {
                      final p = _posts[i];
                      return GestureDetector(
                        onTap: () => context.go('/posts/${p.id}'),
                        child: Image.network(p.mediaUrl, fit: BoxFit.cover),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
