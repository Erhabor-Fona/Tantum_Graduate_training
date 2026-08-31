import 'package:flutter/foundation.dart';

import '../core/error/app_exception.dart';
import '../domain/entities/support_request.dart';
import '../domain/repositories/support_repository.dart';
import 'view_state.dart';

/// Owns the support ticket list and the create-request flow.
class SupportProvider extends ChangeNotifier with AsyncState {
  final SupportRepository _repository;
  SupportProvider(this._repository);

  List<SupportRequest> _requests = const [];
  SupportRequest? _active;

  List<SupportRequest> get requests => _requests;
  SupportRequest? get active => _active;
  SupportRequest? get mostRecent => _requests.isEmpty ? null : _requests.first;

  static const categories = ['Transactions', 'Account', 'Cards', 'Loans', 'Airtime & Data'];
  static const issueTypes = [
    'Failed Transaction',
    'Duplicate Charge',
    'Wrong Amount',
    'Delayed Credit',
    'Card Not Working',
    'Other',
  ];

  Future<void> load(String token) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      _requests = await _repository.fetchRequests(token);
      setState(_requests.isEmpty ? ViewState.empty : ViewState.success);
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
    }
    notifyListeners();
  }

  void select(SupportRequest request) {
    _active = request;
    notifyListeners();
  }

  Future<SupportRequest?> create(
    String token, {
    required String category,
    required String issueType,
    required String description,
    String? transactionReference,
    String? attachmentName,
  }) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      final created = await _repository.createRequest(
        token,
        category: category,
        issueType: issueType,
        description: description,
        transactionReference: transactionReference,
        attachmentName: attachmentName,
      );
      _requests = [created, ..._requests];
      _active = created;
      setState(ViewState.success);
      notifyListeners();
      return created;
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _requests = const [];
    _active = null;
    setState(ViewState.idle);
    notifyListeners();
  }
}
