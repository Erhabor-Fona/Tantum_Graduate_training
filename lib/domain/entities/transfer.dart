/// A destination bank the customer can transfer to.
class Bank {
  final String code;
  final String name;
  const Bank({required this.code, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) =>
      Bank(code: json['code'] as String? ?? '', name: json['name'] as String? ?? '');
}

/// The resolved owner of a destination account number.
class ResolvedAccount {
  final String accountNumber;
  final String accountName;
  final Bank bank;
  const ResolvedAccount({
    required this.accountNumber,
    required this.accountName,
    required this.bank,
  });
}

/// What the customer wants to send.
class TransferRequest {
  final Bank bank;
  final String accountNumber;
  final String accountName;
  final double amount;
  final String narration;

  const TransferRequest({
    required this.bank,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    this.narration = '',
  });

  Map<String, dynamic> toJson() => {
        'bankCode': bank.code,
        'accountNumber': accountNumber,
        'amount': amount,
        'narration': narration,
      };
}

/// Result of a submitted transfer, rendered by the success screen.
class TransferReceipt {
  final String reference;
  final TransferRequest request;
  final double fee;
  final DateTime date;
  final String fromAccount;

  const TransferReceipt({
    required this.reference,
    required this.request,
    required this.date,
    this.fee = 50,
    this.fromAccount = '7099887766',
  });

  double get total => request.amount + fee;
}

/// What the transfer result screen renders: either a completed receipt or a
/// declined attempt with the reason.
///
/// Keeping success and failure in one type means the result screen has a
/// single argument contract and one code path to branch on.
class TransferOutcome {
  final TransferReceipt receipt;
  final String? failureReason;

  const TransferOutcome.success(this.receipt) : failureReason = null;
  const TransferOutcome.failure(this.receipt, String reason) : failureReason = reason;

  bool get succeeded => failureReason == null;
}
