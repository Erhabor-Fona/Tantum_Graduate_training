import 'telco.dart';

/// What the customer asked to buy. Passed from the form to the repository.
///
/// SRP: carries intent only; it neither validates nor executes the purchase.
class PurchaseRequest {
  final TelcoNetwork network;
  final PurchaseType type;
  final String phoneNumber;
  final double amount;
  final String? planId;
  final String? planName;

  const PurchaseRequest({
    required this.network,
    required this.type,
    required this.phoneNumber,
    required this.amount,
    this.planId,
    this.planName,
  });

  Map<String, dynamic> toJson() => {
        'network': network.name,
        'type': type.name,
        'phoneNumber': phoneNumber,
        'amount': amount,
        'planId': planId,
        'planName': planName,
      };
}

/// Outcome of a purchase, rendered by the success or failure screen.
class PurchaseReceipt {
  final String transactionId;
  final TelcoNetwork network;
  final PurchaseType type;
  final String recipient;
  final double amount;
  final String? planName;
  final DateTime date;
  final String reference;

  const PurchaseReceipt({
    required this.transactionId,
    required this.network,
    required this.type,
    required this.recipient,
    required this.amount,
    required this.date,
    this.planName,
    this.reference = '',
  });

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) => PurchaseReceipt(
        transactionId: json['transactionId'] as String? ?? '',
        network: TelcoNetwork.parse(json['network'] as String?),
        type: json['type'] == 'data' ? PurchaseType.data : PurchaseType.airtime,
        recipient: json['recipient'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toDouble(),
        planName: json['planName'] as String?,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        reference: json['reference'] as String? ?? '',
      );
}

/// What the purchase result screen renders: a completed purchase, or a
/// declined attempt with the reason.
class PurchaseOutcome {
  final PurchaseReceipt receipt;
  final String? failureReason;

  const PurchaseOutcome.success(this.receipt) : failureReason = null;
  const PurchaseOutcome.failure(this.receipt, String reason) : failureReason = reason;

  bool get succeeded => failureReason == null;
}
