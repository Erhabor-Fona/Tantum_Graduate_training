enum AccountStatus { active, dormant, restricted }

/// A bank account belonging to a [User].
class Account {
  final String id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String bvnMasked;
  final String currency;
  final String dateOpened;
  final AccountStatus status;

  const Account({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    this.bvnMasked = '**** **** 3456',
    this.currency = 'NGN',
    this.dateOpened = '12 Jan 2023',
    this.status = AccountStatus.active,
  });

  String get statusLabel => switch (status) {
        AccountStatus.active => 'ACTIVE',
        AccountStatus.dormant => 'DORMANT',
        AccountStatus.restricted => 'RESTRICTED',
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id']?.toString() ?? '',
        accountNumber: json['accountNumber'] as String? ?? '',
        accountType: json['accountType'] as String? ?? 'Savings Account',
        balance: (json['balance'] as num? ?? 0).toDouble(),
        bvnMasked: json['bvnMasked'] as String? ?? '**** **** 3456',
        currency: json['currency'] as String? ?? 'NGN',
        dateOpened: json['dateOpened'] as String? ?? '',
        status: AccountStatus.values.firstWhere(
          (s) => s.name == (json['status'] as String? ?? 'active'),
          orElse: () => AccountStatus.active,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountNumber': accountNumber,
        'accountType': accountType,
        'balance': balance,
        'bvnMasked': bvnMasked,
        'currency': currency,
        'dateOpened': dateOpened,
        'status': status.name,
      };
}
