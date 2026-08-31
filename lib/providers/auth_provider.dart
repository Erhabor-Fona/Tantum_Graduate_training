import 'package:flutter/foundation.dart';

import '../core/error/app_exception.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/session_store.dart';
import 'view_state.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Owns the signed-in session.
///
/// DIP: it holds an [AuthRepository] and a [SessionStore] — both interfaces —
/// so it works identically against mock data and a live API.
class AuthProvider extends ChangeNotifier with AsyncState {
  final AuthRepository _auth;
  final SessionStore _session;

  AuthProvider({required AuthRepository auth, required SessionStore session})
      : _auth = auth,
        _session = session;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _token;
  String? _otpDestination;
  String? _rememberedIdentifier;
  bool _darkMode = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String get authToken => _token ?? '';
  String? get otpDestination => _otpDestination;
  String? get rememberedIdentifier => _rememberedIdentifier;
  bool get isLoggedIn => _status == AuthStatus.authenticated && _token != null;
  bool get darkMode => _darkMode;

  /// Restores a previous session at startup.
  Future<void> bootstrap() async {
    _darkMode = await _session.readDarkMode();
    _rememberedIdentifier = await _session.readRememberedIdentifier();
    final token = await _session.readToken();
    final user = await _session.readUser();

    if (token != null && user != null) {
      _token = token;
      _user = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    return _run(() async {
      final session = await _auth.login(identifier: identifier, password: password);
      await _persist(session);
      await _session.saveRememberedIdentifier(rememberMe ? identifier : null);
      _rememberedIdentifier = rememberMe ? identifier : null;
    });
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _run(() async {
      final challenge = await _auth.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      _otpDestination = challenge.maskedDestination;
    });
  }

  Future<bool> verifyOtp(String code) async {
    return _run(() async {
      final session = await _auth.verifyOtp(code);
      await _persist(session);
    });
  }

  Future<bool> resendOtp() async {
    return _run(() async {
      final challenge = await _auth.resendOtp();
      _otpDestination = challenge.maskedDestination;
    });
  }

  Future<bool> requestPasswordReset(String identifier) =>
      _run(() => _auth.requestPasswordReset(identifier));

  Future<bool> resetPassword(String newPassword, String otp) => _run(
      () => _auth.resetPassword(token: otp ?? 'reset-token', newPassword: newPassword));

  Future<void> logout() async {
    await _session.clearSession();
    _token = null;
    _user = null;
    _otpDestination = null;
    _status = AuthStatus.unauthenticated;
    setState(ViewState.idle);
    notifyListeners();
  }

  /// Keeps the cached user in step after a profile edit.
  Future<void> applyUpdatedUser(User updated) async {
    _user = updated;
    await _session.saveUser(updated);
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    await _session.saveDarkMode(enabled);
    notifyListeners();
  }

  void clearError() {
    if (hasError) {
      setState(ViewState.idle);
      notifyListeners();
    }
  }

  Future<void> _persist(AuthSession session) async {
    _token = session.token;
    _user = session.user;
    _status = AuthStatus.authenticated;
    await _session.saveToken(session.token);
    await _session.saveUser(session.user);
  }

  /// Single place where exceptions become user-facing state.
  Future<bool> _run(Future<void> Function() action) async {
    setState(ViewState.loading);
    notifyListeners();
    try {
      await action();
      setState(ViewState.success);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      setState(ViewState.error, error: e.message);
      notifyListeners();
      return false;
    } catch (_) {
      setState(ViewState.error, error: 'Something went wrong. Please try again.');
      notifyListeners();
      return false;
    }
  }
}
