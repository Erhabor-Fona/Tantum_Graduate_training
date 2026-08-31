import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../error/app_exception.dart';

/// Abstraction over HTTP.
///
/// DIP: repositories depend on this contract, never on `package:http`.
/// Swapping to Dio, or to a recording client in tests, requires no repository
/// change.
abstract interface class ApiClient {
  Future<Map<String, dynamic>> get(String path, {String? token});
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {String? token});
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {String? token});
  Future<void> delete(String path, {String? token});
}

/// Concrete [ApiClient] backed by `package:http`.
///
/// Two behaviours matter beyond plain transport:
///
/// 1. **Full debug logging.** Every call prints the base URL, endpoint,
///    headers, request body, status code and response body under the `API`
///    log tag, so a failing request can be diagnosed from the console alone.
///
/// 2. **Envelope normalisation.** TatumConnect wraps most payloads as
///    `{ success, message, data, errors, meta }`, but some endpoints return a
///    bare object, a bare array, or an empty 200. Because this interface is
///    declared to return `Map<String, dynamic>`, a bare array is wrapped as
///    `{'data': [...]}` so callers always receive a map.
class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client _client;

  HttpApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 45);

  // ── logging ─────────────────────────────────────────────────────────────
  static void _log(String message) {
    if (kDebugMode) developer.log(message, name: 'API');
  }

  static String _pretty(Object? value) {
    if (value == null) return '(none)';
    if (value is String && value.isEmpty) return '(empty body)';
    try {
      final decoded = value is String ? jsonDecode(value) : value;
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      final s = value.toString();
      return s.length > 2000 ? '${s.substring(0, 2000)}…(truncated)' : s;
    }
  }

  /// Authorization is truncated so a token never lands in a shared log.
  static String _prettyHeaders(Map<String, String> headers) {
    final copy = Map<String, String>.from(headers);
    final auth = copy['Authorization'];
    if (auth != null) {
      copy['Authorization'] = auth.length > 26
          ? '${auth.substring(0, 26)}…(${auth.length} chars total)'
          : '(${auth.length} chars)';
    }
    return _pretty(copy);
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  // ── verbs ───────────────────────────────────────────────────────────────
  @override
  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final res = await _send('GET', path, token, null,
        () => _client.get(_uri(path), headers: _headers(token)));
    return _decode(res);
  }

  @override
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
      {String? token}) async {
    final res = await _send('POST', path, token, body,
        () => _client.post(_uri(path),
            headers: _headers(token), body: jsonEncode(body)));
    return _decode(res);
  }

  @override
  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body,
      {String? token}) async {
    final res = await _send('PUT', path, token, body,
        () => _client.put(_uri(path),
            headers: _headers(token), body: jsonEncode(body)));
    return _decode(res);
  }

  @override
  Future<void> delete(String path, {String? token}) async {
    await _send('DELETE', path, token, null,
        () => _client.delete(_uri(path), headers: _headers(token)));
  }

  // ── core ────────────────────────────────────────────────────────────────
  Future<http.Response> _send(
    String method,
    String path,
    String? token,
    Map<String, dynamic>? body,
    Future<http.Response> Function() request,
  ) async {
    _log('');
    _log('┌──────────────────────────────────────────────────────────');
    _log('│ → $method $path');
    _log('│   BASE URL : $baseUrl');
    _log('│   ENDPOINT : $path');
    _log('│   FULL URL : ${_uri(path)}');
    _log('│   HEADERS  : ${_prettyHeaders(_headers(token))}');
    _log('│   BODY     : ${_pretty(body)}');

    final started = DateTime.now();
    http.Response res;
    try {
      res = await request().timeout(_timeout);
    } on SocketException catch (e) {
      _log('│ ✗ NETWORK  : $e');
      _log('└──────────────────────────────────────────────────────────');
      throw const NetworkException();
    } catch (e) {
      _log('│ ✗ FAILED   : $e');
      _log('└──────────────────────────────────────────────────────────');
      throw const NetworkException();
    }

    final ms = DateTime.now().difference(started).inMilliseconds;
    _log('│ ← STATUS   : ${res.statusCode}  (${ms}ms)');
    _log('│ ← RESPONSE : ${_pretty(res.body)}');
    _log('└──────────────────────────────────────────────────────────');
    return res;
  }

  Map<String, dynamic> _decode(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;

    dynamic decoded;
    if (res.body.isNotEmpty) {
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        decoded = null;
      }
    }

    // Always hand callers a Map, even when the server sent an array.
    final Map<String, dynamic> body = switch (decoded) {
      Map<String, dynamic> m => m,
      List<dynamic> l => <String, dynamic>{'data': l},
      _ => <String, dynamic>{},
    };

    if (ok) return body;

    final message = _errorMessage(body, res.statusCode);
    if (res.statusCode == 401 || res.statusCode == 403) throw AuthException(message);
    if (res.statusCode == 404) throw NotFoundException(message);
    if (res.statusCode == 422 || res.statusCode == 400) throw ValidationException(message);
    throw ServerException(message, statusCode: res.statusCode);
  }

  /// Pulls a readable message out of the several error shapes the API uses.
  static String _errorMessage(Map<String, dynamic> body, int status) {
    // { errors: [ { code, message } ] }
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map && first['message'] != null) return first['message'].toString();
      if (first is String) return first;
    }
    // ASP.NET validation: { errors: { Field: ["msg"] } }
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    for (final key in ['message', 'detail', 'title', 'error']) {
      final v = body[key];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return switch (status) {
      400 => 'That request was not valid. Please check your details.',
      401 => 'Your session has expired. Please log in again.',
      403 => 'You do not have permission to do that.',
      404 => 'We could not find what you were looking for.',
      409 => 'That record already exists.',
      >= 500 => 'The server had a problem. Please try again shortly.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}

/// Convenience readers for the `{ success, message, data }` envelope.
extension ApiEnvelope on Map<String, dynamic> {
  /// The payload — unwraps `data` when the envelope is present.
  dynamic get payload => containsKey('data') ? this['data'] : this;

  /// The payload as a map, or an empty map.
  Map<String, dynamic> get dataMap {
    final p = payload;
    return p is Map<String, dynamic> ? p : <String, dynamic>{};
  }

  /// The payload as a list of maps. Handles a bare array and the paged
  /// shapes `{ items: [...] }` / `{ results: [...] }`.
  List<Map<String, dynamic>> get dataList {
    final p = payload;
    if (p is List) return p.whereType<Map<String, dynamic>>().toList();
    if (p is Map<String, dynamic>) {
      for (final key in ['items', 'results', 'records', 'data']) {
        final v = p[key];
        if (v is List) return v.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
