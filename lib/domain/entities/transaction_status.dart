/// Lifecycle state shared by transfers, bill payments and airtime purchases.
enum TransactionStatus {
  successful,
  pending,
  failed;

  String get label => switch (this) {
        TransactionStatus.successful => 'Successful',
        TransactionStatus.pending => 'Pending',
        TransactionStatus.failed => 'Failed',
      };

  static TransactionStatus parse(String? raw) => TransactionStatus.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => TransactionStatus.successful,
      );
}

enum TransactionDirection { credit, debit }

/// Grouping used by the history filter chips and tile icons.
enum TransactionCategory {
  transfer,
  bills,
  airtime,
  data,
  salary,
  refund;

  static TransactionCategory parse(String? raw) => TransactionCategory.values.firstWhere(
        (c) => c.name == raw,
        orElse: () => TransactionCategory.transfer,
      );
}
