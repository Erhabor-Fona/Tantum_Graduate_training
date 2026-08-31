import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/support_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/info_row.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/status_badge.dart';

/// Profile & Settings M11 — yellow identity card, account information and the
/// settings menu.
class ProfileSettingsScreen extends StatelessWidget {
  final bool embedded;
  const ProfileSettingsScreen({super.key, this.embedded = false});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Tatum Bank?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.read<AccountProvider>().reset();
    context.read<TransactionProvider>().reset();
    context.read<NotificationProvider>().reset();
    context.read<SupportProvider>().reset();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final account = context.watch<AccountProvider>().account;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Identity card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.white,
                  child: Text(
                    user?.initials ?? 'T',
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.navy),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.navy)),
                      Text(user?.phone ?? '',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.navy)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 13, color: AppColors.white),
                        SizedBox(width: 5),
                        Text('Edit',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text('Account Information',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            rows: [
              InfoRow(
                label: 'Account Number',
                value: account?.accountNumber ?? '',
                copyable: true,
              ),
              InfoRow(label: 'Account Type', value: account?.accountType ?? ''),
              InfoRow(label: 'BVN', value: account?.bvnMasked ?? ''),
              InfoRow(
                label: 'Status',
                valueWidget: LabelPill(
                  label: 'Active',
                  color: AppColors.success,
                  background: AppColors.successTint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          SettingsSection(
            title: 'Settings',
            children: [
              SettingsTile(
                icon: Icons.shield_outlined,
                iconBackground: AppColors.infoTint,
                iconColor: AppColors.accent,
                label: 'Security & Privacy',
                onTap: () => Navigator.pushNamed(context, AppRoutes.securitySettings),
              ),
              SettingsTile(
                icon: Icons.notifications_none,
                iconBackground: AppColors.primaryTint,
                iconColor: AppColors.gold,
                label: 'Notification Preferences',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notificationPreferences),
              ),
              SettingsTile(
                icon: Icons.credit_card_outlined,
                iconBackground: AppColors.successTint,
                iconColor: AppColors.success,
                label: 'Linked Accounts',
                onTap: () => context.showMessage('Linked accounts are coming soon.'),
              ),
              SettingsTile(
                icon: Icons.headset_mic_outlined,
                iconBackground: AppColors.primaryTint,
                iconColor: AppColors.gold,
                label: 'Help & Support',
                onTap: () => Navigator.pushNamed(context, AppRoutes.support),
              ),
              SettingsTile(
                icon: Icons.info_outline,
                iconBackground: AppColors.infoTint,
                iconColor: AppColors.accent,
                label: 'About Tatum Bank',
                onTap: () => Navigator.pushNamed(context, AppRoutes.accountInformation),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.dangerTint,
                borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 18, color: AppColors.danger),
                  SizedBox(width: AppSpacing.sm),
                  Text('Log Out',
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
