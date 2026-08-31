/// A single transaction limit row on the Account Limits screen.
class AccountLimit {
  final String name;
  final double limit;
  final double used;

  const AccountLimit({required this.name, required this.limit, this.used = 0});

  double get remaining => (limit - used).clamp(0, limit);
  double get progress => limit == 0 ? 0 : (used / limit).clamp(0, 1);

  factory AccountLimit.fromJson(Map<String, dynamic> json) => AccountLimit(
        name: json['name'] as String? ?? '',
        limit: (json['limit'] as num? ?? 0).toDouble(),
        used: (json['used'] as num? ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'limit': limit, 'used': used};
}
