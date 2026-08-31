import 'package:flutter/foundation.dart';

import '../core/error/app_exception.dart';
import '../domain/entities/bank_transaction.dart';
import '../domain/entities/transaction_status.dart';
import '../domain/repositories/transaction_repository.dart';
import 'view_state.dart';

/// The tabs on the redesigned Transaction History screen.
enum HistoryFilter {
  all('All'),
  pending('Pending'),
  successful('Successful'),
  failed('Failed');

  final String label;
  const HistoryFilter(this.label);
}

/// Owns the transaction list plus the search and filter applied to it.
///
/// SRP: filtering is a pure function of the loaded list — the provider never
/// re-queries the repository when a chip is tapped.
class TransactionProvider extends ChangeNotifier with AsyncState {
  final TransactionRepository _repository;
  TransactionProvider(this._repository);

  List<BankTransaction> _all = const [];
  HistoryFilter _filter = HistoryFilter.all;
  String _query = '';

  List<BankTransaction> get all => _all;
  HistoryFilter get filter => _filter;
  String get query => _query;

  List<BankTransaction> get recent => _all.take(5).toList();

  List<BankTransaction> get visible {
    Iterable<BankTransaction> list = _all;

    list = switch (_filter) {
      HistoryFilter.all => list,
      HistoryFilter.pending => list.where((t) => t.status == TransactionStatus.pending),
      HistoryFilter.successful => list.where((t) => t.status == TransactionStatus.successful),
      HistoryFilter.failed => list.where((t) => t.status == TransactionStatus.failed),
    };

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.narration.toLowerCase().contains(q) ||
          t.reference.toLowerCase().contains(q));
    }
    return list.toList();
  }

  /// Groups the visible list by day for the sectioned list view.
  Map<DateTime, List<BankTransaction>> get grouped {
    final map = <DateTime, List<BankTransaction>>{};
    for (final tx in visible) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  Future<void> load(String token) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      _all = await _repository.fetchTransactions(token);
      setState(_all.isEmpty ? ViewState.empty : ViewState.success);
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
    } catch (_) {
      setState(ViewState.error, error: 'We could not load your transactions.');
    }
    notifyListeners();
  }

  void applyFilter(HistoryFilter value) {
    _filter = value;
    notifyListeners();
  }

  void search(String value) {
    _query = value;
    notifyListeners();
  }

  /// Adds a freshly completed transaction to the top of the list.
  void prepend(BankTransaction transaction) {
    _all = [transaction, ..._all];
    setState(ViewState.success);
    notifyListeners();
  }

  void reset() {
    _all = const [];
    _filter = HistoryFilter.all;
    _query = '';
    setState(ViewState.idle);
    notifyListeners();
  }
}
