import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/account/account_information_screen.dart';
import '../screens/account/account_limits_screen.dart';
import '../screens/airtime/airtime_home_screen.dart';
import '../screens/airtime/buy_airtime_screen.dart';
import '../screens/airtime/purchase_result_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_otp_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/reset_success_screen.dart';
import '../screens/common/not_found_screen.dart';
import '../screens/dashboard/home_shell.dart';
import '../screens/notifications/notification_detail_screen.dart';
import '../screens/notifications/notification_preferences_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_settings_screen.dart';
import '../screens/profile/security_settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/support/create_request_screen.dart';
import '../screens/support/request_details_screen.dart';
import '../screens/support/request_status_screen.dart';
import '../screens/support/support_home_screen.dart';
import '../screens/transactions/new_transfer_screen.dart';
import '../screens/transactions/transaction_details_screen.dart';
import '../screens/transactions/transaction_history_screen.dart';
import '../screens/transactions/transfer_result_screen.dart';

/// Named routes plus a guard for authenticated areas
/// (Week 3, Session 7 + Week 5, Session 15).
///
/// SRP: this class maps a route name to a screen. It builds no UI itself.
class AppRoutes {
  AppRoutes._();

  // Onboarding & auth
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-password/success';
  static const String resetOtpScreen = '/reset-password-otp';

  // Core
  static const String home = '/home';
  static const String accountInformation = '/account';
  static const String accountLimits = '/account/limits';

  // Transactions
  static const String transactionHistory = '/transactions';
  static const String transactionDetails = '/transactions/details';
  static const String newTransfer = '/transfer';
  static const String transferResult = '/transfer/result';

  // Airtime & data
  static const String airtimeHome = '/airtime';
  static const String buyAirtime = '/airtime/buy';
  static const String purchaseResult = '/airtime/result';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notifications/detail';
  static const String notificationPreferences = '/notifications/preferences';

  // Support
  static const String support = '/support';
  static const String createRequest = '/support/create';
  static const String requestDetails = '/support/request';
  static const String requestStatus = '/support/status';

  // Profile
  static const String profile = '/profile';
  static const String securitySettings = '/profile/security';
  static const String editProfile = '/profile/edit';

  /// Routes that require a valid session.
  static const Set<String> protected = {
    home,
    accountInformation,
    accountLimits,
    transactionHistory,
    transactionDetails,
    newTransfer,
    transferResult,
    airtimeHome,
    buyAirtime,
    purchaseResult,
    notifications,
    notificationDetail,
    notificationPreferences,
    support,
    createRequest,
    requestDetails,
    requestStatus,
    profile,
    securitySettings,
    editProfile,
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? splash;

    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        // A one-shot read: the guard runs when the route is pushed, not on
        // every AuthProvider notification. `watch` here would rebuild the
        // route and loop.
        if (protected.contains(name) && !context.read<AuthProvider>().isLoggedIn) {
          return const LoginScreen();
        }
        return _screenFor(name, settings.arguments);
      },
    );
  }

  static Widget _screenFor(String name, Object? args) => switch (name) {
        splash => const SplashScreen(),
        welcome => const WelcomeScreen(),
        register => const RegisterScreen(),
        otp => const OtpScreen(),
    resetOtpScreen => const ResetOtpScreen(),
        login => const LoginScreen(),
        forgotPassword => const ForgotPasswordScreen(),
        resetPassword => ResetPasswordScreen(
          otp: (args as Map<String, dynamic>)['otp'] as String,
        ),
        resetSuccess => const ResetSuccessScreen(),
        home => const HomeShell(),
        accountInformation => const AccountInformationScreen(),
        accountLimits => const AccountLimitsScreen(),
        transactionHistory => const TransactionHistoryScreen(),
        transactionDetails => const TransactionDetailsScreen(),
        newTransfer => const NewTransferScreen(),
        transferResult => const TransferResultScreen(),
        airtimeHome => const AirtimeHomeScreen(),
        buyAirtime => const BuyAirtimeScreen(),
        purchaseResult => const PurchaseResultScreen(),
        notifications => const NotificationsScreen(),
        notificationDetail => const NotificationDetailScreen(),
        notificationPreferences => const NotificationPreferencesScreen(),
        support => const SupportHomeScreen(),
        createRequest => const CreateRequestScreen(),
        requestDetails => const RequestDetailsScreen(),
        requestStatus => const RequestStatusScreen(),
        profile => const ProfileSettingsScreen(),
        securitySettings => const SecuritySettingsScreen(),
        editProfile => const EditProfileScreen(),

        _ => const NotFoundScreen(),
      };

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => const NotFoundScreen());
}
