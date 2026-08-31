import 'transaction_status.dart';

/// Maps a human label ("Successful") back to a [TransactionStatus].
///
/// Kept beside the enum rather than inside a widget so every screen that needs
/// this conversion shares one implementation.
extension TransactionStatusX on TransactionStatus {
  static TransactionStatus parseLabel(String label) =>
      TransactionStatus.values.firstWhere(
        (s) => s.label.toLowerCase() == label.toLowerCase().trim(),
        orElse: () => TransactionStatus.successful,
      );
}
