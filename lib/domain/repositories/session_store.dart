import '../entities/user.dart';

/// Persistence contract for the signed-in session and device preferences.
///
/// ISP: kept separate from [AuthRepository] because widgets that only read the
/// theme flag must not be forced to depend on login and OTP methods.
/// DIP: `SharedPreferencesSessionStore` is one implementation; an encrypted
/// or in-memory store can replace it without touching a provider.
abstract interface class SessionStore {
  Future<void> saveToken(String token);
  Future<String?> readToken();

  Future<void> saveUser(User user);
  Future<User?> readUser();

  Future<void> saveDarkMode(bool enabled);
  Future<bool> readDarkMode();

  Future<void> saveRememberedIdentifier(String? identifier);
  Future<String?> readRememberedIdentifier();

  Future<void> clearSession();
}
