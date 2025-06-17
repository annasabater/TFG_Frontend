//widgets/UserCard.dart

import 'package:flutter/material.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onDelete;

  const UserCard({super.key, required this.user, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.92)
          : Theme.of(context).colorScheme.surface,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(color: Colors.white24, width: 1.2)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Text(
              user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          title: Text(
            user.userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email, size: 16),
                  const SizedBox(width: 4),
                  Text(user.email),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.badge, size: 16),
                  const SizedBox(width: 4),
                  Text(user.role),
                ],
              ),
            ],
          ),
          trailing: onDelete != null
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                )
              : null,
        ),
      ),
    );
  }
}
