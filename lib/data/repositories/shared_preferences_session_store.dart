import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/session_store.dart';

/// [SessionStore] backed by SharedPreferences (Week 4, Session 12).
///
/// Note for trainees: the auth token is kept here for teaching purposes only.
/// A production banking app stores it in the platform keychain / keystore.
class SharedPreferencesSessionStore implements SessionStore {
  static const _kToken = 'tatum.auth_token';
  static const _kUser = 'tatum.user';
  static const _kDarkMode = 'tatum.dark_mode';
  static const _kRemembered = 'tatum.remembered_identifier';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static void _log(String message) {
    if (kDebugMode) developer.log(message, name: 'SESSION');
  }

  /// Refuses to persist an empty token, and reads the value back to prove it
  /// was written. A silent failure here is what makes a token "disappear"
  /// between login and the next authenticated request.
  @override
  Future<void> saveToken(String token) async {
    if (token.isEmpty) {
      _log('⚠️  refusing to save an EMPTY token');
      return;
    }
    final prefs = await _prefs;
    await prefs.setString(_kToken, token);

    final readBack = prefs.getString(_kToken);
    if (readBack == null || readBack.isEmpty) {
      _log('✗ token write FAILED — read-back was empty');
    } else {
      _log('✓ token saved (${readBack.length} chars)');
    }
  }

  @override
  Future<String?> readToken() async {
    final token = (await _prefs).getString(_kToken);
    _log(token == null || token.isEmpty
        ? '⚠️  readToken → EMPTY (not authenticated)'
        : '✓ readToken → ${token.length} chars');
    return (token == null || token.isEmpty) ? null : token;
  }

  @override
  Future<void> saveUser(User user) async =>
      (await _prefs).setString(_kUser, jsonEncode(user.toJson()));

  @override
  Future<User?> readUser() async {
    final raw = (await _prefs).getString(_kUser);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveDarkMode(bool enabled) async => (await _prefs).setBool(_kDarkMode, enabled);

  @override
  Future<bool> readDarkMode() async => (await _prefs).getBool(_kDarkMode) ?? false;

  @override
  Future<void> saveRememberedIdentifier(String? identifier) async {
    final prefs = await _prefs;
    if (identifier == null || identifier.isEmpty) {
      await prefs.remove(_kRemembered);
    } else {
      await prefs.setString(_kRemembered, identifier);
    }
  }

  @override
  Future<String?> readRememberedIdentifier() async => (await _prefs).getString(_kRemembered);

  @override
  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
  }
}
