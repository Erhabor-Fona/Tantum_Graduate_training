import '../entities/app_notification.dart';

/// In-app notification feed and delivery preferences.
abstract interface class NotificationRepository {
  Future<List<AppNotification>> fetchNotifications(String token);
  Future<void> markAsRead(String token, String id);
  Future<NotificationPreferences> fetchPreferences(String token);
  Future<void> savePreferences(String token, NotificationPreferences preferences);
}
