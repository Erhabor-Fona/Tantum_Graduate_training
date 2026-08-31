import '../entities/bank_transaction.dart';
import '../entities/data_plan.dart';
import '../entities/purchase_request.dart';
import '../entities/telco.dart';

/// Buys airtime and data bundles.
abstract interface class AirtimeRepository {
  Future<List<DataPlan>> fetchDataPlans(TelcoNetwork network);
  Future<List<double>> fetchQuickAmounts(TelcoNetwork network);
  Future<List<BankTransaction>> fetchAirtimeHistory(String token);
  Future<PurchaseReceipt> purchase(String token, PurchaseRequest request);
}
