import '../entities/account.dart';
import '../entities/account_limit.dart';
import '../entities/user.dart';

/// Reads and updates the customer's account profile.
abstract interface class AccountRepository {
  Future<Account> fetchAccount(String token);
  Future<List<AccountLimit>> fetchLimits(String token);
  Future<User> updateProfile(String token, {required String fullName, required String email, required String phone});
}
