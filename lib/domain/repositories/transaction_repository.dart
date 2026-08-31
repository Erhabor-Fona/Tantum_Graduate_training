import '../entities/bank_transaction.dart';

/// Read-only access to transaction history.
///
/// ISP: transfers live in [TransferRepository] because the history screen has
/// no business being able to move money.
abstract interface class TransactionRepository {
  Future<List<BankTransaction>> fetchTransactions(String token, {int limit = 50});
  Future<BankTransaction> fetchTransaction(String token, String id);
}
