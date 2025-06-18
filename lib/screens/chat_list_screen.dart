// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/users_provider.dart';
import '../models/user.dart';
import '../widgets/language_selector.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProvider>().initData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final convIds = provider.conversationUserIds;
    final convUsers = provider.users.where((u) => convIds.contains(u.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => GoRouter.of(context).go('/chat/search'),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : convUsers.isEmpty
              ? const Center(child: Text('Aún no tienes conversaciones.'))
              : ListView.separated(
                  itemCount: convUsers.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final user = convUsers[i];
                    return Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.92)
                          : Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: Theme.of(context).brightness == Brightness.dark
                            ? const BorderSide(color: Colors.white24, width: 1.2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            user.userName.isNotEmpty
                                ? user.userName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(user.userName),
                        subtitle: Text(user.email),
                        onTap: () => GoRouter.of(context).go('/chat/${user.id}'),
                      ),
                    );
                  },
                ),
    );
  }
}
