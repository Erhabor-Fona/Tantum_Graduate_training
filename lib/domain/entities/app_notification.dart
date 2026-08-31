/// Category of an in-app notification. Drives the tile icon and tint.
enum NotificationKind {
  transaction,
  security,
  promo,
  balance;

  static NotificationKind parse(String? raw) => NotificationKind.values.firstWhere(
        (k) => k.name == raw,
        orElse: () => NotificationKind.transaction,
      );
}

/// A single entry on the Notifications screen.
class AppNotification {
  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final String? actionLabel;
  final Map<String, String> details;
  final double? amount;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    this.actionLabel,
    this.details = const {},
    this.amount,
  });

  AppNotification markRead() => AppNotification(
        id: id,
        kind: kind,
        title: title,
        body: body,
        date: date,
        isRead: true,
        actionLabel: actionLabel,
        details: details,
        amount: amount,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id']?.toString() ?? '',
        kind: NotificationKind.parse(json['kind'] as String?),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        isRead: json['isRead'] as bool? ?? false,
        actionLabel: json['actionLabel'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        details: (json['details'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? const {},
      );
}

/// The toggles on the Notification Preferences screen.
///
/// Stored as a flat map so a new preference can be added without changing
/// the entity's shape (OCP).
class NotificationPreferences {
  final Map<String, bool> values;
  const NotificationPreferences(this.values);

  static const pushTransactionAlerts = 'push.transactionAlerts';
  static const pushSecurityAlerts = 'push.securityAlerts';
  static const pushAccountActivity = 'push.accountActivity';
  static const emailMonthlyStatements = 'email.monthlyStatements';
  static const emailPromotions = 'email.promotions';
  static const emailNews = 'email.news';
  static const smsOtpSecurity = 'sms.otpSecurity';
  static const smsTransactionAlerts = 'sms.transactionAlerts';

  static const NotificationPreferences defaults = NotificationPreferences({
    pushTransactionAlerts: true,
    pushSecurityAlerts: true,
    pushAccountActivity: false,
    emailMonthlyStatements: true,
    emailPromotions: false,
    emailNews: false,
    smsOtpSecurity: true,
    smsTransactionAlerts: true,
  });

  bool isOn(String key) => values[key] ?? false;

  NotificationPreferences toggle(String key, bool value) =>
      NotificationPreferences({...values, key: value});

  Map<String, dynamic> toJson() => values;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(json.map((k, v) => MapEntry(k, v == true)));
}
