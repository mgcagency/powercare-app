// lib/features/presentation/notification/notification_provider.dart
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void setUnreadCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    if (_unreadCount != 0) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  // Reset for logout
  void reset() {
    _unreadCount = 0;
    notifyListeners();
  }
}