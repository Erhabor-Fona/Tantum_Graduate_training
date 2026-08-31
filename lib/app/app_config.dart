/// Build-time configuration.
///
/// Flip [useMockApi] to false and point [apiBaseUrl] at a live server; no
/// screen, provider or repository interface changes are required, because the
/// composition root is the only place that reads these values.
class AppConfig {
  AppConfig._();

  static const bool useMockApi = false;
  static const String apiBaseUrl = 'https://tatumconnect-backend.onrender.com';

  static const Duration splashDuration = Duration(seconds: 3);
  static const int otpLength = 6;
  static const int otpResendSeconds = 59;
  static const double transferFee = 50;
  static const double dailyTransferLimit = 5000000;

  static const String logo = 'assets/images/tatum_logo.svg';
  static const String heroBoy = 'assets/images/boy_hero.svg';
  static const String logoMark = 'assets/images/logo_mark.svg';
  static const String appVersion = '7.5.0';
}
