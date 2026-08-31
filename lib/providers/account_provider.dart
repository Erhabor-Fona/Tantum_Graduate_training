import 'package:flutter/foundation.dart';

import '../core/error/app_exception.dart';
import '../domain/entities/account.dart';
import '../domain/entities/account_limit.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/account_repository.dart';
import 'view_state.dart';

/// Holds the account summary shown on the dashboard and account screens.
class AccountProvider extends ChangeNotifier with AsyncState {
  final AccountRepository _repository;
  AccountProvider(this._repository);

  Account? _account;
  List<AccountLimit> _limits = const [];
  bool _balanceHidden = false;

  Account? get account => _account;
  List<AccountLimit> get limits => _limits;
  bool get balanceHidden => _balanceHidden;
  double get balance => _account?.balance ?? 0;

  Future<void> load(String token) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchAccount(token),
        _repository.fetchLimits(token),
      ]);
      _account = results[0] as Account;
      _limits = results[1] as List<AccountLimit>;
      setState(ViewState.success);
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
    } catch (_) {
      setState(ViewState.error, error: 'We could not load your account.');
    }
    notifyListeners();
  }

  Future<User?> updateProfile(
    String token, {
    required String fullName,
    required String email,
    required String phone,
  }) async {
    try {
      return await _repository.updateProfile(
        token,
        fullName: fullName,
        email: email,
        phone: phone,
      );
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
      notifyListeners();
      return null;
    }
  }

  void toggleBalanceVisibility() {
    _balanceHidden = !_balanceHidden;
    notifyListeners();
  }

  void reset() {
    _account = null;
    _limits = const [];
    setState(ViewState.idle);
    notifyListeners();
  }
}
