import 'transaction_status.dart';

/// One row in the transaction history, and the subject of the details screen.
class BankTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionDirection direction;
  final TransactionStatus status;
  final TransactionCategory category;
  final DateTime date;

  final String transactionType;
  final String narration;
  final String reference;
  final String channel;
  final String? counterparty;
  final String? counterpartyAccount;
  final String? sessionId;
  final String? phoneNumber;
  final double fee;

  const BankTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.direction,
    required this.date,
    this.status = TransactionStatus.successful,
    this.category = TransactionCategory.transfer,
    this.transactionType = 'Bank Transfer',
    this.narration = '',
    this.reference = '',
    this.channel = 'Mobile App',
    this.counterparty,
    this.counterpartyAccount,
    this.sessionId,
    this.phoneNumber,
    this.fee = 0,
  });

  bool get isCredit => direction == TransactionDirection.credit;
  double get total => amount + fee;

  factory BankTransaction.fromJson(Map<String, dynamic> json) => BankTransaction(
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toDouble(),
        direction: (json['direction'] as String? ?? 'debit') == 'credit'
            ? TransactionDirection.credit
            : TransactionDirection.debit,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        status: TransactionStatus.parse(json['status'] as String?),
        category: TransactionCategory.parse(json['category'] as String?),
        transactionType: json['transactionType'] as String? ?? 'Bank Transfer',
        narration: json['narration'] as String? ?? '',
        reference: json['reference'] as String? ?? '',
        channel: json['channel'] as String? ?? 'Mobile App',
        counterparty: json['counterparty'] as String?,
        counterpartyAccount: json['counterpartyAccount'] as String?,
        sessionId: json['sessionId'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        fee: (json['fee'] as num? ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'direction': direction.name,
        'date': date.toIso8601String(),
        'status': status.name,
        'category': category.name,
        'transactionType': transactionType,
        'narration': narration,
        'reference': reference,
        'channel': channel,
        'counterparty': counterparty,
        'counterpartyAccount': counterpartyAccount,
        'sessionId': sessionId,
        'phoneNumber': phoneNumber,
        'fee': fee,
      };
}
