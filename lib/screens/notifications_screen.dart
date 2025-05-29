//lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/notification_provider.dart';
import '../models/notification.dart' as model;

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
                    leading: CircleAvatar(
                      child: Text(
                        noti.fromUserName.isNotEmpty
                          ? noti.fromUserName[0].toUpperCase()
                          : '?',
                      ),
                    ),
                    title: Text(noti.title),
                    subtitle: Text(noti.timeFormatted),
                    trailing: _buildTrailing(noti),
                    onTap: () {
                      prov.markRead(noti);
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

  Widget? _buildTrailing(model.NotificationItem noti) {
    if ((noti.type == 'like' || noti.type == 'comment') &&
        noti.postMediaUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          noti.postMediaUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }

    if (!noti.read) {
      return const Icon(Icons.circle, size: 10, color: Colors.red);
    }
    return null;
  }
}
