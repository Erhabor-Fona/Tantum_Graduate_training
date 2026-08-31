import '../entities/transfer.dart';

/// Moves money to another account.
abstract interface class TransferRepository {
  Future<List<Bank>> fetchBanks();
  Future<ResolvedAccount> resolveAccount({required Bank bank, required String accountNumber});
  Future<TransferReceipt> submitTransfer(String token, TransferRequest request);
}
