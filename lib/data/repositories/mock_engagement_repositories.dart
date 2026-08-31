import '../../core/error/app_exception.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/support_repository.dart';
import '../sources/mock_data.dart';
import 'mock_delay.dart';

class MockNotificationRepository with MockLatency implements NotificationRepository {
  late List<AppNotification> _items = MockData.notifications();
  NotificationPreferences _prefs = NotificationPreferences.defaults;

  @override
  Future<List<AppNotification>> fetchNotifications(String token) async {
    await settle(600);
    return List.unmodifiable(_items);
  }

  @override
  Future<void> markAsRead(String token, String id) async {
    await settle(150);
    _items = _items.map((n) => n.id == id ? n.markRead() : n).toList();
  }

  @override
  Future<NotificationPreferences> fetchPreferences(String token) async {
    await settle(300);
    return _prefs;
  }

  @override
  Future<void> savePreferences(String token, NotificationPreferences preferences) async {
    await settle(250);
    _prefs = preferences;
  }
}

class MockSupportRepository with MockLatency implements SupportRepository {
  late List<SupportRequest> _requests = MockData.supportRequests();

  @override
  Future<List<SupportRequest>> fetchRequests(String token) async {
    await settle(600);
    return List.unmodifiable(_requests);
  }

  @override
  Future<SupportRequest> fetchRequest(String token, String id) async {
    await settle(400);
    final match = _requests.where((r) => r.id == id);
    if (match.isEmpty) throw const NotFoundException('That request could not be found.');
    return match.first;
  }

  @override
  Future<SupportRequest> createRequest(
    String token, {
    required String category,
    required String issueType,
    required String description,
    String? transactionReference,
    String? attachmentName,
  }) async {
    await settle();
    final now = DateTime.now();
    final created = SupportRequest(
      id: 'SR-${now.year}-${now.millisecondsSinceEpoch % 10000}',
      category: category,
      issueType: issueType,
      description: description,
      transactionReference: transactionReference,
      attachmentName: attachmentName,
      createdAt: now,
      status: RequestStatus.received,
      timeline: [
        RequestEvent(status: RequestStatus.received, at: now, note: 'Your request has been received.'),
        const RequestEvent(status: RequestStatus.underReview),
        const RequestEvent(status: RequestStatus.resolved),
      ],
    );
    _requests = [created, ..._requests];
    return created;
  }
}
