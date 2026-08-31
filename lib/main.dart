import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tatum_bank/screens/auth/reset_otp_screen.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'app/dependencies.dart';
import 'providers/account_provider.dart';
import 'providers/airtime_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/support_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/transfer_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Build the object graph once, at the very edge of the app.
  runApp(TatumBankApp(dependencies: Dependencies.resolve()));
}

/// Root widget. Wires the injected [Dependencies] into the provider tree so
/// no screen ever constructs a repository for itself.
class TatumBankApp extends StatelessWidget {
  final Dependencies dependencies;

  const TatumBankApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dependencies>.value(value: dependencies),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            auth: dependencies.authRepository,
            session: dependencies.sessionStore,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(dependencies.accountRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(dependencies.transactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TransferProvider(dependencies.transferRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AirtimeProvider(dependencies.airtimeRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(dependencies.notificationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SupportProvider(dependencies.supportRepository),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          title: 'Tatum Bank',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: auth.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: AppRoutes.onUnknownRoute,
          //home: ResetOtpScreen(),
        ),
      ),
    );
  }
}
