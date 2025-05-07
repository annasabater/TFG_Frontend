import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/users_provider.dart';
import '../models/user.dart';
import 'package:go_router/go_router.dart';

class ChatSelectScreen extends StatelessWidget {
  const ChatSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final currentUser = provider.currentUser;
    final users = provider.users.where((u) => u.id != currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona un usuari')), 
      body: users.isEmpty
          ? const Center(child: Text('No hi ha altres usuaris disponibles.'))
          : ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?')),
                  title: Text(user.userName),
                  subtitle: Text(user.email),
                  onTap: () => context.go('/chat/${user.id}'),
                );
              },
            ),
    );
  }
} 