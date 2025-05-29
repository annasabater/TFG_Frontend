// lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/notification_provider.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notificacions')),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.items.isEmpty
              ? const Center(child: Text('No tens notificacions'))
              : ListView.builder(
                  itemCount: prov.items.length,
                  itemBuilder: (_, i) {
                    final noti = prov.items[i];
                    return ListTile(
                      title: Text(noti.message),
                      subtitle: Text(noti.createdAt.toLocal().toString()),
                      trailing: noti.read
                          ? null
                          : const Icon(Icons.circle, size: 10, color: Colors.red),
                      onTap: () {
                        // Marquem com a llegida
                        prov.markRead(noti);
                        // Naveguem segons tipus
                        switch (noti.type) {
                          case 'like':
                          case 'comment':
                            if (noti.postId != null) {
                              context.go('/posts/${noti.postId}');
                            }
                            break;
                          case 'follow':
                          case 'new_post':
                            context.go('/u/${noti.fromUserId}');
                            break;
                        }
                      },
                    );
                  },
                ),
    );
  }
}
