import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json_probe.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// [AuthRepository] backed by the live TatumConnect API.
///
/// Endpoint map (from the OpenAPI document):
///
///   POST /api/v1/Auth/register                {email,password,firstName,lastName,phone}
///   POST /api/v1/Auth/verify-registration     {email,otp}
///   POST /api/v1/Auth/resend-registration-otp {email}
///   POST /api/v1/Auth/login                   {email,password}
///   GET  /api/v1/Auth/me
///   POST /api/v1/Auth/reset-password-start    {email}
///   POST /api/v1/Auth/reset-password          {email,otp,newPassword}
///
/// LSP: this behaves exactly like [MockAuthRepository] from the caller's
/// point of view — same return types, same [AppException] family on failure —
/// so `AuthProvider` cannot tell which one it holds.
class HttpAuthRepository implements AuthRepository {
  final ApiClient _client;
  HttpAuthRepository(this._client);

  static void _log(String m) {
    if (kDebugMode) developer.log(m, name: 'AUTH');
  }

  /// The interface's `verifyOtp(code)` and `resetPassword(...)` do not carry
  /// an email, but the API requires one. These hold the address (and the
  /// password, for the auto-login below) between the calls of a single flow.
  String _pendingEmail = '';
  String _pendingPassword = '';

  // ── Login ───────────────────────────────────────────────────────────────
  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    _log('login → $identifier');
    final body = await _client.post('/api/v1/Auth/login', {
      'email': identifier.trim(),
      'password': password,
    });

    return _sessionFrom(
      body,
      fallbackEmail: identifier.trim(),
      context: 'login',
    );
  }

  // ── Register → OTP ──────────────────────────────────────────────────────
  @override
  Future<OtpChallenge> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    // RegisterRequestDto takes firstName and lastName separately.
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    _log('register → $email ($firstName / $lastName)');
    await _client.post('/api/v1/Auth/register', {
      'email': email.trim(),
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone.trim(),
    });

    // Remembered so verifyOtp/resendOtp can supply the email the API needs.
    _pendingEmail = email.trim();
    _pendingPassword = password;

    return OtpChallenge(maskedDestination: _mask(email.trim()));
  }

  /// POST /api/v1/Auth/verify-registration.
  ///
  /// The endpoint returns `200` with no documented body, so it may not issue
  /// a token. When it does not, the account is now active and we log in with
  /// the password captured during [register] — the caller always receives a
  /// usable [AuthSession] rather than one holding an empty token.
  @override
  Future<AuthSession> verifyOtp(String code) async {
    if (_pendingEmail.isEmpty) {
      throw const ValidationException(
          'Start registration again — we lost track of your email address.');
    }

    _log('verify-registration → $_pendingEmail');
    final body = await _client.post('/api/v1/Auth/verify-registration', {
      'email': _pendingEmail,
      'otp': code.trim(),
    });

    final token = JsonProbe.findToken(body);
    if (token != null && token.isNotEmpty) {
      _log('verification returned a token directly');
      return _sessionFrom(body, fallbackEmail: _pendingEmail, context: 'verify');
    }

    if (_pendingPassword.isEmpty) {
      throw const AuthException(
          'Your account is verified. Please log in to continue.');
    }

    _log('verification issued no token — logging in to obtain one');
    final session =
        await login(identifier: _pendingEmail, password: _pendingPassword);
    _pendingPassword = '';
    return session;
  }

  @override
  Future<OtpChallenge> resendOtp() async {
    if (_pendingEmail.isEmpty) {
      throw const ValidationException(
          'Start registration again — we lost track of your email address.');
    }
    _log('resend-registration-otp → $_pendingEmail');
    await _client.post(
        '/api/v1/Auth/resend-registration-otp', {'email': _pendingEmail});
    return OtpChallenge(maskedDestination: _mask(_pendingEmail));
  }

  // ── Password reset ──────────────────────────────────────────────────────
  /// POST /api/v1/Auth/reset-password-start — emails a reset OTP.
  @override
  Future<void> requestPasswordReset(String identifier) async {
    _log('reset-password-start → $identifier');
    await _client.post(
        '/api/v1/Auth/reset-password-start', {'email': identifier.trim()});
    _pendingEmail = identifier.trim();
  }

  /// POST /api/v1/Auth/reset-password.
  ///
  /// `ResetPasswordRequestDto` is `{ email, otp, newPassword }`. The
  /// interface's `token` parameter carries the OTP from the email.
  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (_pendingEmail.isEmpty) {
      throw const ValidationException(
          'Request a new reset code — we lost track of your email address.');
    }
    _log('reset-password → $_pendingEmail');
    await _client.post('/api/v1/Auth/reset-password', {
      'email': _pendingEmail,
      'otp': token.trim(),
      'newPassword': newPassword,
    });
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  /// Builds an [AuthSession] from an undocumented auth response.
  ///
  /// Throws rather than returning an empty token, so a shape mismatch fails
  /// loudly here instead of silently breaking every later request.
  Future<AuthSession> _sessionFrom(
    Map<String, dynamic> body, {
    required String fallbackEmail,
    required String context,
  }) async {
    final token = JsonProbe.findToken(body);
    if (token == null || token.isEmpty) {
      _log('✗ $context succeeded but no token was present in the response');
      throw const AuthException(
        'Signed in, but the server did not return an access token. '
        'Check the API log for the response shape.',
      );
    }

    // The user may be embedded in the auth response; if not, ask /Auth/me.
    var userJson = JsonProbe.findUser(body);
    if (userJson == null) {
      _log('no user in $context response — calling /api/v1/Auth/me');
      try {
        final me = await _client.get('/api/v1/Auth/me', token: token);
        userJson = JsonProbe.findUser(me) ?? me.dataMap;
      } on AppException catch (e) {
        _log('/Auth/me failed (${e.message}) — using a minimal profile');
        userJson = null;
      }
    }

    return AuthSession(
      token: token,
      user: _userFrom(userJson, fallbackEmail: fallbackEmail),
    );
  }

  /// Maps the API's `firstName`/`lastName` onto the domain's `fullName`.
  static User _userFrom(Map<String, dynamic>? json, {required String fallbackEmail}) {
    if (json == null || json.isEmpty) {
      return User(id: '', fullName: '', email: fallbackEmail, phone: '');
    }
    final first = (json['firstName'] ?? '').toString().trim();
    final last = (json['lastName'] ?? '').toString().trim();
    final combined = '$first $last'.trim();
    final fullName =
        combined.isNotEmpty ? combined : (json['fullName'] ?? '').toString();

    return User(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      fullName: fullName,
      email: (json['email'] ?? fallbackEmail).toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      dateOfBirth: json['dateOfBirth'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  static String _mask(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts.first.length < 2) return email;
    return '${parts.first[0]}${'*' * (parts.first.length - 1)}@${parts[1]}';
  }
}
