import 'package:flutter/foundation.dart';

import '../core/error/app_exception.dart';
import '../domain/entities/bank_transaction.dart';
import '../domain/entities/data_plan.dart';
import '../domain/entities/purchase_request.dart';
import '../domain/entities/telco.dart';
import '../domain/repositories/airtime_repository.dart';
import 'view_state.dart';

/// Drives Buy Airtime & Data: network choice, plans, quick amounts, purchase.
class AirtimeProvider extends ChangeNotifier with AsyncState {
  final AirtimeRepository _repository;
  AirtimeProvider(this._repository);

  TelcoNetwork _network = TelcoNetwork.mtn;
  PurchaseType _type = PurchaseType.airtime;
  List<DataPlan> _plans = const [];
  DataPlan? _selectedPlan;
  List<double> _quickAmounts = const [500, 1000, 2000];
  double? _selectedAmount;
  List<BankTransaction> _history = const [];
  String _historyQuery = '';

  TelcoNetwork get network => _network;
  PurchaseType get type => _type;
  List<DataPlan> get plans => _plans;
  DataPlan? get selectedPlan => _selectedPlan;
  List<double> get quickAmounts => _quickAmounts;
  double? get selectedAmount => _selectedAmount;

  List<BankTransaction> get history {
    if (_historyQuery.trim().isEmpty) return _history;
    final q = _historyQuery.toLowerCase();
    return _history.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  Future<void> initialise(String token) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchQuickAmounts(_network),
        _repository.fetchAirtimeHistory(token),
      ]);
      _quickAmounts = results[0] as List<double>;
      _history = results[1] as List<BankTransaction>;
      setState(_history.isEmpty ? ViewState.empty : ViewState.success);
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
    }
    notifyListeners();
  }

  Future<void> selectNetwork(TelcoNetwork value) async {
    _network = value;
    _selectedPlan = null;
    notifyListeners();
    if (_type == PurchaseType.data) await loadPlans();
  }

  Future<void> selectType(PurchaseType value) async {
    _type = value;
    _selectedPlan = null;
    _selectedAmount = null;
    notifyListeners();
    if (value == PurchaseType.data) await loadPlans();
  }

  Future<void> loadPlans() async {
    try {
      _plans = await _repository.fetchDataPlans(_network);
      notifyListeners();
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
      notifyListeners();
    }
  }

  void selectPlan(DataPlan plan) {
    _selectedPlan = plan;
    _selectedAmount = plan.price;
    notifyListeners();
  }

  void selectAmount(double? amount) {
    _selectedAmount = amount;
    notifyListeners();
  }

  void searchHistory(String value) {
    _historyQuery = value;
    notifyListeners();
  }

  /// Returns a receipt, or throws so the caller can show the failure screen.
  Future<PurchaseReceipt> purchase(
    String token, {
    required String phoneNumber,
    required double amount,
  }) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      final receipt = await _repository.purchase(
        token,
        PurchaseRequest(
          network: _network,
          type: _type,
          phoneNumber: phoneNumber,
          amount: amount,
          planId: _selectedPlan?.id,
          planName: _selectedPlan?.name,
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
    _network = TelcoNetwork.mtn;
    _type = PurchaseType.airtime;
    _selectedPlan = null;
    _selectedAmount = null;
    _historyQuery = '';
    setState(ViewState.idle);
    notifyListeners();
  }
}
