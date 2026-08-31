/// Shared constants for the Tatum Bank application.
///
/// Keeping base URLs, keys, and app-wide values in one place makes it easy
/// to switch environments (dev / staging / production) without touching
/// feature code — see Week 5, Session 14 (Environment configuration).
class AppConstants {
  AppConstants._();

  static const String appName = 'Tatum Bank';
  static const String tagline = 'All-in-One Banking, All for You';

  /// Base URL for the REST API.
  /// Point this at your backend. When [useMockApi] is true the app runs
  /// fully offline against an in-memory mock — perfect for the classroom.
  static const String apiBaseUrl = 'https://api.tatumbank.example.com/v1';
  static const bool useMockApi = true;

  // SharedPreferences keys (Week 4, Session 12 — Local Data Storage).
  static const String kAuthToken = 'auth_token';
  static const String kLoggedInUser = 'logged_in_user';
  static const String kRememberMe = 'remember_me';
  static const String kDarkMode = 'dark_mode';
  static const String kAccountId    = 'account_id';


  // Assets.
  static const String logoSvg = 'assets/images/tatum_logo.svg';
  static const String logoMarkSvg = 'assets/images/logo_mark.svg';
  static const String boyHeroSvg = 'assets/images/boy_hero.svg';

  // Timings.
  static const Duration splashDuration = Duration(seconds: 5);
  static const int otpResendSeconds = 59;
  static const int otpLength = 6;

  static const String billerCategoryTelco = 'TeleCommunication';

}
