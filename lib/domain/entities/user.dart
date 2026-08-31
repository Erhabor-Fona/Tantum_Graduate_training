/// A Tatum Bank customer. Immutable value object (SRP: identity data only).
class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? dateOfBirth;
  final String? address;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.address,
    this.avatarUrl,
  });

  String get firstName => fullName.trim().split(' ').first;
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'T';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  User copyWith({String? fullName, String? email, String? phone, String? avatarUrl}) => User(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dateOfBirth: dateOfBirth,
        address: address,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        dateOfBirth: json['dateOfBirth'] as String?,
        address: json['address'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'address': address,
        'avatarUrl': avatarUrl,
      };
}
