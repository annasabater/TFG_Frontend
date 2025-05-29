import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/users_provider.dart';
import '../../services/social_service.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  List<dynamic> _followingUsers = [];
  List<dynamic> _searchResults = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<List<dynamic>> _getFollowingUsers(String userId) async {
    return await SocialService.getFollowingUsers(userId);
  }

  Future<void> _loadFollowing() async {
    setState(() => _loading = true);
    try {
      final provider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = provider.currentUser;
      if (currentUser == null) return;
      final seguidos = await _getFollowingUsers(currentUser.id!);
      setState(() => _followingUsers = seguidos);
    } catch (e) {
      setState(() => _followingUsers = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _loading = true);
    try {
      final provider = Provider.of<UserProvider>(context, listen: false);
      await provider.loadUsers();
      final users = provider.users;
      setState(() {
        _searchResults = users.where((u) =>
          u.userName.toLowerCase().contains(query.toLowerCase()) ||
          u.email.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    } catch (e) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _followUser(String userId) async {
    await SocialService.follow(userId);
    await _loadFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguidos y buscar usuarios')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar usuarios...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) {
                      setState(() => _query = v);
                      if (v.isNotEmpty) {
                        _searchUsers(v);
                      } else {
                        setState(() => _searchResults = []);
                      }
                    },
                  ),
                ),
                if (_query.isEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _followingUsers.length,
                      itemBuilder: (ctx, i) {
                        final user = _followingUsers[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text(user.userName[0].toUpperCase())),
                          title: Text(user.userName),
                          subtitle: Text(user.email),
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (ctx, i) {
                        final user = _searchResults[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text(user.userName[0].toUpperCase())),
                          title: Text(user.userName),
                          subtitle: Text(user.email),
                          trailing: ElevatedButton(
                            child: const Text('Seguir'),
                            onPressed: () => _followUser(user.id!),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
