/// Base class for every error the app raises.
///
/// SRP: this hierarchy exists only to describe failures — it does not log,
/// display, or recover from them.
/// LSP: any subtype can be caught as [AppException] and rendered with
/// [message] without the caller knowing which subtype it received.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network and try again.']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  final String? field;
  const ValidationException(super.message, {this.field});
}

class InsufficientFundsException extends AppException {
  const InsufficientFundsException([super.message = "You don't have enough balance to complete this transfer."]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'We could not find what you were looking for.']);
}
