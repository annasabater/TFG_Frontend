// lib/provider/notification_provider.dart

import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _items = [];
  bool _loading = false;

  List<NotificationItem> get items => _items;
  bool get loading => _loading;
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> loadNotifications() async {
    _loading = true;
    notifyListeners();
    try {
      final raw = await NotificationService.getNotifications();
      _items = raw;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(NotificationItem noti) async {
    if (noti.read) return;
    await NotificationService.markAsRead(noti.id);
    noti.read = true;
    notifyListeners();
  }
}
