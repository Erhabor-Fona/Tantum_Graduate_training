import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/settings_tile.dart';

/// Security & Privacy — the Security, Account and Privacy groups.
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometric = true;
  bool _twoFactor = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Security & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          SettingsSection(
            title: 'Security',
            children: [
              SettingsTile(
                icon: Icons.shield_outlined,
                iconBackground: AppColors.infoTint,
                iconColor: AppColors.accent,
                label: 'Change Password',
                onTap: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
              ),
              SettingsTile(
                icon: Icons.pin_outlined,
                iconBackground: AppColors.infoTint,
                iconColor: AppColors.accent,
                label: 'Change Transaction PIN',
                onTap: () => context.showMessage('PIN management is coming soon.'),
              ),
              SettingsToggleTile(
                icon: Icons.fingerprint,
                iconBackground: AppColors.primaryTint,
                iconColor: AppColors.gold,
                label: 'Biometric Authentication',
                value: _biometric,
                onChanged: (v) => setState(() => _biometric = v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SettingsSection(
            title: 'Account',
            children: [
              SettingsToggleTile(
                icon: Icons.notifications_none,
                iconBackground: AppColors.primaryTint,
                iconColor: AppColors.gold,
                label: 'Two-Factor Authentication',
                value: _twoFactor,
                onChanged: (v) => setState(() => _twoFactor = v),
              ),
              SettingsTile(
                icon: Icons.devices_outlined,
                iconBackground: AppColors.infoTint,
                iconColor: AppColors.accent,
                label: 'Device Management',
                onTap: () => context.showMessage('Device management is coming soon.'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SettingsSection(
            title: 'Privacy',
            children: [
              SettingsTile(
                icon: Icons.lock_outline,
                iconBackground: AppColors.primaryTint,
                iconColor: AppColors.gold,
                label: 'Privacy Policy',
                onTap: () => context.showMessage('Opening the privacy policy soon.'),
              ),
              SettingsTile(
                icon: Icons.visibility_outlined,
                iconBackground: AppColors.successTint,
                iconColor: AppColors.success,
                label: 'Data Sharing',
                onTap: () => context.showMessage('Data sharing controls are coming soon.'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SettingsSection(
            title: 'Appearance',
            children: [
              SettingsToggleTile(
                icon: Icons.dark_mode_outlined,
                iconBackground: AppColors.surfaceTint,
                label: 'Dark Mode',
                value: auth.darkMode,
                onChanged: (v) => context.read<AuthProvider>().setDarkMode(v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
