import 'package:flutter/foundation.dart';

import '../core/error/app_exception.dart';
import '../domain/entities/transfer.dart';
import '../domain/repositories/transfer_repository.dart';
import 'view_state.dart';

/// Drives the New Transfer form: bank list, name resolution and submission.
class TransferProvider extends ChangeNotifier with AsyncState {
  final TransferRepository _repository;
  TransferProvider(this._repository);

  List<Bank> _banks = const [];
  Bank? _selectedBank;
  ResolvedAccount? _resolved;
  bool _resolving = false;

  List<Bank> get banks => _banks;
  Bank? get selectedBank => _selectedBank;
  ResolvedAccount? get resolved => _resolved;
  bool get resolving => _resolving;
  bool get canSubmit => _selectedBank != null && _resolved != null;

  Future<void> loadBanks() async {
    if (_banks.isNotEmpty) return;
    try {
      _banks = await _repository.fetchBanks();
      notifyListeners();
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
      notifyListeners();
    }
  }

  void selectBank(Bank bank) {
    _selectedBank = bank;
    _resolved = null;
    notifyListeners();
  }

  /// Looks up the account name once a full 10-digit number is entered.
  Future<void> resolve(String accountNumber) async {
    if (_selectedBank == null || accountNumber.length != 10) {
      if (_resolved != null) {
        _resolved = null;
        notifyListeners();
      }
      return;
    }
    _resolving = true;
    notifyListeners();
    try {
      _resolved = await _repository.resolveAccount(
        bank: _selectedBank!,
        accountNumber: accountNumber,
      );
    } on AppException {
      _resolved = null;
    } finally {
      _resolving = false;
      notifyListeners();
    }
  }

  /// Returns the receipt on success; throws [AppException] on failure so the
  /// screen can route to the dedicated failure page.
  Future<TransferReceipt> submit(
    String token, {
    required double amount,
    required String narration,
  }) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      final receipt = await _repository.submitTransfer(
        token,
        TransferRequest(
          bank: _selectedBank!,
          accountNumber: _resolved!.accountNumber,
          accountName: _resolved!.accountName,
          amount: amount,
          narration: narration,
        ),
      );
      setState(ViewState.success);
      notifyListeners();
      return receipt;
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
      notifyListeners();
      rethrow;
    }
  }

  void reset() {
    _selectedBank = null;
    _resolved = null;
    setState(ViewState.idle);
    notifyListeners();
  }
}
