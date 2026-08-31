import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Finds values in a JSON response whose exact shape is not documented.
///
/// WHY THIS EXISTS
/// ---------------
/// The TatumConnect OpenAPI document declares `200` with **no response
/// schema** for `/Auth/login`, `/Auth/verify-registration` and `/Auth/me`.
/// The location of the JWT is therefore not contractual: it may arrive as
///
///     { "token": "…" }
///     { "data": { "token": "…" } }
///     { "data": { "accessToken": "…" } }
///     { "success": true, "data": { "jwt": "…" } }
///
/// Reading one hard-coded path is what previously stored an empty token and
/// left every authenticated call unauthorised. [findToken] instead searches
/// the whole decoded tree, so the app works with whichever shape the server
/// actually returns — and logs the path it found, or the entire tree when it
/// finds nothing.
class JsonProbe {
  JsonProbe._();

  static void _log(String m) {
    if (kDebugMode) developer.log(m, name: 'API');
  }

  /// Keys that hold a JWT, most specific first.
  static const tokenKeys = [
    'accessToken',
    'access_token',
    'token',
    'jwt',
    'idToken',
    'id_token',
    'authToken',
    'auth_token',
    'bearerToken',
  ];

  /// First plausible token string anywhere in [node].
  ///
  /// A value qualifies when it sits under one of [tokenKeys] and is at least
  /// 20 characters — long enough to exclude flags like `"token": "none"`.
  static String? findToken(dynamic node) {
    final hit = _search(node, tokenKeys, minLength: 20, path: r'$');
    if (hit == null) {
      _log('⚠️  NO TOKEN FOUND. Searched: ${tokenKeys.join(", ")}');
      _log('    Full response tree:\n${_encode(node)}');
      return null;
    }
    _log('✓ token found at ${hit.path} (${hit.value.length} chars)');
    return hit.value;
  }

  /// The user/profile object anywhere in [node].
  static Map<String, dynamic>? findUser(dynamic node) {
    if (node is Map<String, dynamic>) {
      for (final key in ['user', 'profile', 'customer']) {
        final v = node[key];
        if (v is Map<String, dynamic> && v.isNotEmpty) return v;
      }
      // A bare object carrying user-ish fields is itself the user.
      if (node.containsKey('email') &&
          (node.containsKey('firstName') ||
              node.containsKey('lastName') ||
              node.containsKey('fullName') ||
              node.containsKey('id'))) {
        return node;
      }
      for (final v in node.values) {
        final nested = findUser(v);
        if (nested != null) return nested;
      }
    }
    if (node is List) {
      for (final v in node) {
        final nested = findUser(v);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  /// First string under any of [keys], at any depth.
  static String? findString(dynamic node, List<String> keys) =>
      _search(node, keys, minLength: 1, path: r'$')?.value;

  // ── internals ───────────────────────────────────────────────────────────
  static _Hit? _search(
    dynamic node,
    List<String> keys, {
    required int minLength,
    required String path,
  }) {
    if (node is Map<String, dynamic>) {
      for (final key in keys) {
        final v = node[key];
        if (v is String && v.length >= minLength) return _Hit('$path.$key', v);
      }
      for (final entry in node.entries) {
        final hit = _search(entry.value, keys,
            minLength: minLength, path: '$path.${entry.key}');
        if (hit != null) return hit;
      }
    }
    if (node is List) {
      for (var i = 0; i < node.length; i++) {
        final hit =
            _search(node[i], keys, minLength: minLength, path: '$path[$i]');
        if (hit != null) return hit;
      }
    }
    return null;
  }

  static String _encode(dynamic node) {
    try {
      return const JsonEncoder.withIndent('  ').convert(node);
    } catch (_) {
      return node.toString();
    }
  }
}

class _Hit {
  final String path;
  final String value;
  const _Hit(this.path, this.value);
}
