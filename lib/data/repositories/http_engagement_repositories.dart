import '../../core/network/api_client.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/support_repository.dart';

class HttpNotificationRepository implements NotificationRepository {
  final ApiClient _client;
  const HttpNotificationRepository(this._client);

  @override
  Future<List<AppNotification>> fetchNotifications(String token) async {
    final body = await _client.get('/notifications', token: token);
    return ((body['notifications'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  @override
  Future<void> markAsRead(String token, String id) =>
      _client.post('/notifications/$id/read', const {}, token: token);

  @override
  Future<NotificationPreferences> fetchPreferences(String token) async =>
      NotificationPreferences.fromJson(
          await _client.get('/notifications/preferences', token: token));

  @override
  Future<void> savePreferences(String token, NotificationPreferences preferences) =>
      _client.put('/notifications/preferences', preferences.toJson(), token: token);
}

class HttpSupportRepository implements SupportRepository {
  final ApiClient _client;
  const HttpSupportRepository(this._client);

  SupportRequest _parse(Map<String, dynamic> json) => SupportRequest(
        id: json['id'] as String? ?? '',
        category: json['category'] as String? ?? '',
        issueType: json['issueType'] as String? ?? '',
        description: json['description'] as String? ?? '',
        transactionReference: json['transactionReference'] as String?,
        attachmentName: json['attachmentName'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        status: RequestStatus.parse(json['status'] as String?),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        resolutionNote: json['resolutionNote'] as String?,
        resolvedAt: DateTime.tryParse(json['resolvedAt'] as String? ?? ''),
        timeline: ((json['timeline'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map((e) => RequestEvent(
                  status: RequestStatus.parse(e['status'] as String?),
                  at: DateTime.tryParse(e['at'] as String? ?? ''),
                  note: e['note'] as String?,
                ))
            .toList(),
      );

  @override
  Future<List<SupportRequest>> fetchRequests(String token) async {
    final body = await _client.get('/support/requests', token: token);
    return ((body['requests'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(_parse)
        .toList();
  }

  @override
  Future<SupportRequest> fetchRequest(String token, String id) async =>
      _parse(await _client.get('/support/requests/$id', token: token));

  @override
  Future<SupportRequest> createRequest(
    String token, {
    required String category,
    required String issueType,
    required String description,
    String? transactionReference,
    String? attachmentName,
  }) async =>
      _parse(await _client.post(
        '/support/requests',
        {
          'category': category,
          'issueType': issueType,
          'description': description,
          'transactionReference': transactionReference,
          'attachmentName': attachmentName,
        },
        token: token,
      ));
}
