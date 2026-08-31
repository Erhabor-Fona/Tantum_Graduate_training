import 'package:flutter/foundation.dart';

import '../core/error/app_exception.dart';
import '../domain/entities/app_notification.dart';
import '../domain/repositories/notification_repository.dart';
import 'view_state.dart';

/// Owns the notification feed and the delivery preference toggles.
class NotificationProvider extends ChangeNotifier with AsyncState {
  final NotificationRepository _repository;
  NotificationProvider(this._repository);

  List<AppNotification> _items = const [];
  NotificationPreferences _preferences = NotificationPreferences.defaults;
  bool _savingPreferences = false;

  List<AppNotification> get items => _items;
  NotificationPreferences get preferences => _preferences;
  bool get savingPreferences => _savingPreferences;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Buckets the feed into TODAY / YESTERDAY / date sections.
  Map<String, List<AppNotification>> get grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final map = <String, List<AppNotification>>{};
    for (final n in _items) {
      final day = DateTime(n.date.year, n.date.month, n.date.day);
      final label = day == today
          ? 'TODAY'
          : day == today.subtract(const Duration(days: 1))
              ? 'YESTERDAY'
              : 'EARLIER';
      map.putIfAbsent(label, () => []).add(n);
    }
    return map;
  }

  Future<void> load(String token) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      _items = await _repository.fetchNotifications(token);
      setState(_items.isEmpty ? ViewState.empty : ViewState.success);
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
    }
    notifyListeners();
  }

  Future<void> markAsRead(String token, String id) async {
    _items = _items.map((n) => n.id == id ? n.markRead() : n).toList();
    notifyListeners();
    try {
      await _repository.markAsRead(token, id);
    } on AppException {
      // Optimistic update already applied; the next load reconciles.
    }
  }

  Future<void> loadPreferences(String token) async {
    try {
      _preferences = await _repository.fetchPreferences(token);
      notifyListeners();
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
      notifyListeners();
    }
  }

  Future<void> togglePreference(String token, String key, bool value) async {
    final previous = _preferences;
    _preferences = _preferences.toggle(key, value);
    _savingPreferences = true;
    notifyListeners();
    try {
      await _repository.savePreferences(token, _preferences);
    } on AppException catch (e) {
      _preferences = previous;
      setState(ViewState.error, error: e.message);
    } finally {
      _savingPreferences = false;
      notifyListeners();
    }
  }

  void reset() {
    _items = const [];
    setState(ViewState.idle);
    notifyListeners();
  }
}
