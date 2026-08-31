import '../../core/error/app_exception.dart';
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
import '../sources/mock_data.dart';
import 'mock_delay.dart';

class MockAccountRepository with MockLatency implements AccountRepository {
  User _user = MockData.user;

  @override
  Future<Account> fetchAccount(String token) async {
    await settle();
    return MockData.account;
  }

  @override
  Future<List<AccountLimit>> fetchLimits(String token) async {
    await settle(500);
    return MockData.limits;
  }

  @override
  Future<User> updateProfile(String token,
      {required String fullName, required String email, required String phone}) async {
    await settle(700);
    _user = _user.copyWith(fullName: fullName, email: email, phone: phone);
    return _user;
  }
}

class MockTransactionRepository with MockLatency implements TransactionRepository {
  @override
  Future<List<BankTransaction>> fetchTransactions(String token, {int limit = 50}) async {
    await settle();
    final all = MockData.transactions()..sort((a, b) => b.date.compareTo(a.date));
    return all.take(limit).toList();
  }

  @override
  Future<BankTransaction> fetchTransaction(String token, String id) async {
    await settle(400);
    final match = MockData.transactions().where((t) => t.id == id);
    if (match.isEmpty) throw const NotFoundException('That transaction could not be found.');
    return match.first;
  }
}

class MockTransferRepository with MockLatency implements TransferRepository {
  @override
  Future<List<Bank>> fetchBanks() async {
    await settle(300);
    return MockData.banks;
  }

  @override
  Future<ResolvedAccount> resolveAccount(
      {required Bank bank, required String accountNumber}) async {
    await settle(700);
    if (accountNumber.length != 10) {
      throw const ValidationException('Enter a 10-digit account number.');
    }
    // Deterministic demo name so the flow is repeatable in class.
    const names = ['John Doe', 'Jane Doe', 'Adaeze Okafor', 'Musa Bello', 'Chidi Nwosu'];
    final index = int.parse(accountNumber.substring(accountNumber.length - 1)) % names.length;
    return ResolvedAccount(
      accountNumber: accountNumber,
      accountName: names[index],
      bank: bank,
    );
  }

  @override
  Future<TransferReceipt> submitTransfer(String token, TransferRequest request) async {
    await settle();
    if (request.amount + 50 > MockData.account.balance) {
      throw const InsufficientFundsException();
    }
    return TransferReceipt(
      reference: 'TB/${DateTime.now().millisecondsSinceEpoch % 100000000}',
      request: request,
      date: DateTime.now(),
    );
  }
}

class MockAirtimeRepository with MockLatency implements AirtimeRepository {
  @override
  Future<List<DataPlan>> fetchDataPlans(TelcoNetwork network) async {
    await settle(400);
    return MockData.dataPlans(network);
  }

  @override
  Future<List<double>> fetchQuickAmounts(TelcoNetwork network) async {
    await settle(200);
    return MockData.quickAmounts;
  }

  @override
  Future<List<BankTransaction>> fetchAirtimeHistory(String token) async {
    await settle();
    return MockData.transactions()
        .where((t) =>
            t.category == TransactionCategory.airtime || t.category == TransactionCategory.data)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<PurchaseReceipt> purchase(String token, PurchaseRequest request) async {
    await settle();
    if (request.amount > MockData.account.balance) {
      throw const InsufficientFundsException(
          "We couldn't process your request at this time.");
    }
    // Demo failure hook: any amount ending in 99 fails, so trainees can
    // exercise the failure screen on demand.
    if (request.amount % 100 == 99) {
      throw const ServerException("We couldn't process your request at this time.");
    }
    return PurchaseReceipt(
      transactionId: '${DateTime.now().millisecondsSinceEpoch % 10000000000}',
      network: request.network,
      type: request.type,
      recipient: request.phoneNumber,
      amount: request.amount,
      planName: request.planName,
      date: DateTime.now(),
      reference: 'TXN-${DateTime.now().millisecondsSinceEpoch % 1000000000}',
    );
  }
}
