import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_limit.dart';
import '../../domain/entities/bank_transaction.dart';
import '../../domain/entities/data_plan.dart';
import '../../domain/entities/purchase_request.dart';
import '../../domain/entities/telco.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/airtime_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/transfer_repository.dart';

void _log(String tag, String message) {
  if (kDebugMode) developer.log(message, name: tag);
}

// ═══════════════════════════════════════════════════════════════════════════
// ACCOUNTS  —  GET /api/v1/Accounts
// ═══════════════════════════════════════════════════════════════════════════
class HttpAccountRepository implements AccountRepository {
  final ApiClient _client;
  HttpAccountRepository(this._client);

  /// Cached so [HttpAirtimeRepository] can reuse it as `accountId`.
  static String cachedAccountId = '';

  @override
  Future<Account> fetchAccount(String token) async {
    final body = await _client.get(
        '/api/v1/Accounts?PageNumber=1&PageSize=10', token: token);

    final rows = body.dataList;
    final json = rows.isNotEmpty ? rows.first : body.dataMap;
    if (json.isEmpty) {
      throw const NotFoundException('No account found for your profile.');
    }

    final account = _accountFrom(json);
    cachedAccountId = account.id;
    _log('ACCOUNT',
        '✓ ${account.accountNumber} (id ${account.id}) balance ${account.balance}');
    return account;
  }

  /// The API exposes no limits endpoint, so tier defaults are shown until it
  /// does. Returning data rather than throwing keeps the KYC screen usable.
  @override
  Future<List<AccountLimit>> fetchLimits(String token) async => const [
        AccountLimit(
            name: 'Daily Transfer Limit', limit: 1000000, used: 0),
        AccountLimit(
            name: 'Airtime & Data Limit', limit: 50000, used: 0),
        AccountLimit(
            name: 'Single Transaction Limit', limit: 200000, used: 0),
      ];

  @override
  Future<User> updateProfile(String token,
      {required String fullName,
      required String email,
      required String phone}) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    // PUT /api/v1/Users/profile — UpdateProfileRequestDto.
    // The DTO has no `email` field, so the address cannot be changed here;
    // the value passed in is echoed back so the UI stays consistent.
    final body = await _client.put(
      '/api/v1/Users/profile',
      {
        'firstName': parts.isNotEmpty ? parts.first : '',
        'lastName': parts.length > 1 ? parts.sublist(1).join(' ') : '',
        'phone': phone,
      },
      token: token,
    );
    final json = body.dataMap;
    final first = (json['firstName'] ?? '').toString();
    final last = (json['lastName'] ?? '').toString();
    return User(
      id: (json['id'] ?? '').toString(),
      fullName: '$first $last'.trim().isEmpty ? fullName : '$first $last'.trim(),
      email: (json['email'] ?? email).toString(),
      phone: (json['phone'] ?? phone).toString(),
    );
  }

  static Account _accountFrom(Map<String, dynamic> j) => Account(
        id: (j['id'] ?? j['accountId'] ?? '').toString(),
        accountNumber: (j['accountNumber'] ?? j['number'] ?? '').toString(),
        accountType:
            (j['accountType'] ?? j['type'] ?? 'Savings Account').toString(),
        balance: ((j['availableBalance'] ??
                j['balance'] ??
                j['currentBalance'] ??
                0) as num)
            .toDouble(),
        bvnMasked: (j['bvnMasked'] ?? '**** **** 3456').toString(),
        currency: (j['currency'] ?? 'NGN').toString(),
        dateOpened: (j['dateOpened'] ?? j['createdAt'] ?? '').toString(),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// TRANSACTIONS  —  GET /api/v1/transactions
// ═══════════════════════════════════════════════════════════════════════════
class HttpTransactionRepository implements TransactionRepository {
  final ApiClient _client;
  HttpTransactionRepository(this._client);

  @override
  Future<List<BankTransaction>> fetchTransactions(String token,
      {int limit = 50}) async {
    final query = StringBuffer('?PageNumber=1&PageSize=$limit');
    if (HttpAccountRepository.cachedAccountId.isNotEmpty) {
      query.write('&AccountId=${HttpAccountRepository.cachedAccountId}');
    }
    final body =
        await _client.get('/api/v1/transactions$query', token: token);
    final list = body.dataList.map(transactionFromApi).toList();
    _log('TXN', '✓ ${list.length} transactions');
    return list;
  }

  /// The API has no `GET /transactions/{id}`, so the row is selected from
  /// the list the history screen already loads.
  @override
  Future<BankTransaction> fetchTransaction(String token, String id) async {
    final all = await fetchTransactions(token, limit: 100);
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => throw const NotFoundException('That transaction is no longer available.'),
    );
  }
}

/// Maps an API transaction onto the domain entity.
///
/// Shared by the transaction and airtime repositories so both produce
/// identical objects from the same payload.
BankTransaction transactionFromApi(Map<String, dynamic> j) {
  final rawType =
      (j['type'] ?? j['direction'] ?? j['transactionType'] ?? '')
          .toString()
          .toLowerCase();
  final isCredit = rawType.contains('credit') ||
      rawType.contains('inflow') ||
      rawType.contains('deposit');

  final rawCategory = (j['category'] ?? j['productCategory'] ?? '')
      .toString()
      .toLowerCase();
  final category = switch (rawCategory) {
    'airtime' => TransactionCategory.airtime,
    'data' => TransactionCategory.data,
    'transfer' => TransactionCategory.transfer,
    _ => TransactionCategory.bills,
  };

  return BankTransaction(
    id: (j['id'] ?? j['transactionId'] ?? '').toString(),
    title: (j['description'] ??
            j['narration'] ??
            j['productName'] ??
            j['billerName'] ??
            'Transaction')
        .toString(),
    amount: ((j['amount'] ?? j['totalAmount'] ?? 0) as num).toDouble(),
    direction:
        isCredit ? TransactionDirection.credit : TransactionDirection.debit,
    status: TransactionStatus.parse(
        (j['status'] ?? 'successful').toString().toLowerCase()),
    category: category,
    date: DateTime.tryParse(
            (j['createdAt'] ?? j['date'] ?? j['transactionDate'] ?? '')
                .toString()) ??
        DateTime.now(),
    transactionType: (j['productName'] ?? 'Purchase').toString(),
    narration: (j['narration'] ?? j['description'] ?? '').toString(),
    reference: (j['reference'] ?? '').toString(),
    channel: 'Mobile App',
    phoneNumber: j['phoneNumber'] as String?,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// TRANSFERS — not exposed by this backend yet.
// ═══════════════════════════════════════════════════════════════════════════
class HttpTransferRepository implements TransferRepository {
  final ApiClient _client;
  HttpTransferRepository(this._client);

  static const _unavailable = ServerException(
      'Bank transfers are not available on this server yet.');

  @override
  Future<List<Bank>> fetchBanks() async => throw _unavailable;

  @override
  Future<ResolvedAccount> resolveAccount({
    required Bank bank,
    required String accountNumber,
  }) async =>
      throw _unavailable;

  @override
  Future<TransferReceipt> submitTransfer(
          String token, TransferRequest request) async =>
      throw _unavailable;
}

// ═══════════════════════════════════════════════════════════════════════════
// AIRTIME & DATA
//
// The API models purchases as Billers → Products → Items:
//
//   GET  /api/Products/billers?category=TeleCommunication
//   GET  /api/Products/billers/{billerId}/products
//   GET  /api/Products/{productId}/items
//   POST /api/v1/transactions/purchase
//
// The domain speaks in [TelcoNetwork] and [PurchaseType], so this class
// translates between the two and caches the lookups.
// ═══════════════════════════════════════════════════════════════════════════
class HttpAirtimeRepository implements AirtimeRepository {
  final ApiClient _client;
  HttpAirtimeRepository(this._client);

  /// network → billerId
  final Map<TelcoNetwork, String> _billerIds = {};
  /// "billerId|Airtime" → productId
  final Map<String, String> _productIds = {};

  static const List<double> _quickAmounts = [100, 200, 500, 1000, 2000];

  @override
  Future<List<double>> fetchQuickAmounts(TelcoNetwork network) async =>
      _quickAmounts;

  @override
  Future<List<DataPlan>> fetchDataPlans(TelcoNetwork network) async {
    final productId = await _productIdFor(network, PurchaseType.data);
    if (productId == null) {
      _log('PRODUCT', '⚠️  no Data product for ${network.label}');
      return const [];
    }

    final body = await _client
        .get('/api/Products/$productId/items?PageNumber=1&PageSize=100');
    final plans = body.dataList
        .map((j) => DataPlan(
              id: (j['id'] ?? '').toString(),
              network: network,
              name: (j['name'] ?? j['title'] ?? '').toString(),
              price: ((j['amount'] ?? j['price'] ?? 0) as num).toDouble(),
              validity:
                  (j['description'] ?? j['validity'] ?? '').toString(),
            ))
        .toList();
    _log('PRODUCT', '✓ ${plans.length} data plans for ${network.label}');
    return plans;
  }

  @override
  Future<List<BankTransaction>> fetchAirtimeHistory(String token) async {
    final query = StringBuffer('?PageNumber=1&PageSize=50');
    if (HttpAccountRepository.cachedAccountId.isNotEmpty) {
      query.write('&AccountId=${HttpAccountRepository.cachedAccountId}');
    }
    final body =
        await _client.get('/api/v1/transactions$query', token: token);
    return body.dataList
        .map(transactionFromApi)
        .where((t) =>
            t.category == TransactionCategory.airtime ||
            t.category == TransactionCategory.data)
        .toList();
  }

  /// POST /api/v1/transactions/purchase — ProductPurchaseRequestDto.
  ///
  /// Airtime sends `amount` with a null `productItemId`.
  /// Data sends the chosen `productItemId` and its price as `amount`.
  @override
  Future<PurchaseReceipt> purchase(
      String token, PurchaseRequest request) async {
    final productId = await _productIdFor(request.network, request.type);
    if (productId == null) {
      throw NotFoundException(
          '${request.network.label} does not offer ${request.type.label} yet.');
    }

    final accountId = HttpAccountRepository.cachedAccountId;
    if (accountId.isEmpty) {
      throw const ValidationException(
          'We could not find your account. Pull down on the dashboard to reload, then try again.');
    }

    _log('TXN',
        'purchase → ${request.network.label} ${request.type.label} '
        '₦${request.amount} to ${request.phoneNumber}');

    final body = await _client.post(
      '/api/v1/transactions/purchase',
      {
        'accountId': accountId,
        'productId': productId,
        'productItemId': request.planId,
        'amount': request.amount,
        'fields': {'phoneNumber': request.phoneNumber},
      },
      token: token,
    );

    final j = body.dataMap;
    final status = (j['status'] ?? 'Successful').toString().toLowerCase();
    if (status == 'failed' || status == 'cancelled') {
      throw ServerException(
          (j['message'] ?? 'The purchase was declined.').toString());
    }

    return PurchaseReceipt(
      transactionId: (j['id'] ?? j['transactionId'] ?? '').toString(),
      network: request.network,
      type: request.type,
      recipient: request.phoneNumber,
      amount: ((j['amount'] ?? request.amount) as num).toDouble(),
      planName: request.planName,
      date: DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      reference: (j['reference'] ?? '').toString(),
    );
  }

  // ── lookup helpers ──────────────────────────────────────────────────────

  /// Resolves the biller whose name matches [network], caching the result.
  Future<String?> _billerIdFor(TelcoNetwork network) async {
    if (_billerIds.containsKey(network)) return _billerIds[network];

    var body = await _client.get(
        '/api/Products/billers?category=TeleCommunication&PageNumber=1&PageSize=100');
    var rows = body.dataList;

    // Fall back to the unfiltered list if the category filter matches nothing.
    if (rows.isEmpty) {
      _log('PRODUCT', 'no TeleCommunication billers — retrying unfiltered');
      body = await _client
          .get('/api/Products/billers?PageNumber=1&PageSize=100');
      rows = body.dataList;
    }

    _log('PRODUCT',
        '✓ ${rows.length} billers: ${rows.map((r) => r['name']).join(", ")}');

    final needle = network.label.toLowerCase();
    for (final row in rows) {
      final name = (row['name'] ?? '').toString().toLowerCase();
      // "MTN" matches "MTN Nigeria"; "9mobile" matches "9Mobile".
      if (name.contains(needle) || needle.contains(name)) {
        final id = (row['id'] ?? '').toString();
        _billerIds[network] = id;
        return id;
      }
    }
    _log('PRODUCT', '⚠️  no biller matched ${network.label}');
    return null;
  }

  /// Resolves the Airtime or Data product under [network]'s biller.
  Future<String?> _productIdFor(
      TelcoNetwork network, PurchaseType type) async {
    final billerId = await _billerIdFor(network);
    if (billerId == null) return null;

    final wanted = type == PurchaseType.data ? 'data' : 'airtime';
    final cacheKey = '$billerId|$wanted';
    if (_productIds.containsKey(cacheKey)) return _productIds[cacheKey];

    final body = await _client.get(
        '/api/Products/billers/$billerId/products?PageNumber=1&PageSize=100');
    final rows = body.dataList;
    _log('PRODUCT',
        '✓ ${rows.length} products for ${network.label}: '
        '${rows.map((r) => r['name']).join(", ")}');

    for (final row in rows) {
      final category = (row['category'] ?? '').toString().toLowerCase();
      final name = (row['name'] ?? '').toString().toLowerCase();
      if (category == wanted || name.contains(wanted)) {
        final id = (row['id'] ?? '').toString();
        _productIds[cacheKey] = id;
        return id;
      }
    }
    return null;
  }
}
