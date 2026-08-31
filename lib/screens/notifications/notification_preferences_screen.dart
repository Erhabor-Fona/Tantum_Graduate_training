import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_spacing.dart';
import '../../domain/entities/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/tatum_scaffold.dart';

/// Notification Preferences — Push, Email and SMS toggle groups.
///
/// The groups are declared as data below, so adding a preference is a
/// one-line change rather than new widget code (OCP).
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  /// Section title -> (preference key, row label).
  static const Map<String, List<(String, String)>> _sections = {
    'Push Notifications': [
      (NotificationPreferences.pushTransactionAlerts, 'Transaction Alerts'),
      (NotificationPreferences.pushSecurityAlerts, 'Security Alerts'),
      (NotificationPreferences.pushAccountActivity, 'Account Activity'),
    ],
    'Email Notifications': [
      (NotificationPreferences.emailMonthlyStatements, 'Monthly Statements'),
      (NotificationPreferences.emailPromotions, 'Promotions & Offers'),
      (NotificationPreferences.emailNews, 'News & Updates'),
    ],
    'SMS Notifications': [
      (NotificationPreferences.smsOtpSecurity, 'OTP & Security'),
      (NotificationPreferences.smsTransactionAlerts, 'Transaction Alerts'),
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().authToken;
      context.read<NotificationProvider>().loadPreferences(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final token = context.read<AuthProvider>().authToken;

    return TatumScaffold(
      title: 'Notification Preferences',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          for (final section in _sections.entries)
            SettingsSection(
              title: section.key,
              children: [
                for (final (key, label) in section.value)
                  SettingsToggleTile(
                    label: label,
                    value: provider.preferences.isOn(key),
                    onChanged: (value) =>
                        provider.togglePreference(token, key, value),
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
