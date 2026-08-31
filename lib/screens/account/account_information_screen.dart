import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

/// Account Information Redesign — navy summary card, personal information
/// list, account information table, support section and the statement CTA.
class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() => _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AccountProvider>();
      if (provider.account == null) {
        provider.load(context.read<AuthProvider>().authToken);
      }
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Tatum Bank?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.read<AccountProvider>().reset();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final deps = context.read<Dependencies>();
    final provider = context.watch<AccountProvider>();
    final user = context.watch<AuthProvider>().user;
    final account = provider.account;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'limits') {
                Navigator.pushNamed(context, AppRoutes.accountLimits);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'limits', child: Text('Account Limits')),
            ],
          ),
        ],
      ),
      body: StateSwitcher(
        state: provider.state,
        errorMessage: provider.errorMessage,
        onRetry: () => provider.load(context.read<AuthProvider>().authToken),
        onSuccess: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Navy summary card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(account?.accountType ?? 'Savings Account',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ACCOUNT NUMBER',
                                style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 0.9,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB9C4D4))),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: account?.accountNumber ?? ''));
                                context.showMessage('Account number copied');
                              },
                              child: Row(
                                children: [
                                  Text(account?.accountNumber ?? '',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.white)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.copy_outlined,
                                      size: 14, color: Color(0xFFB9C4D4)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('AVAILABLE BALANCE',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB9C4D4))),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                provider.balanceHidden
                                    ? '\u20A6 \u2022\u2022\u2022\u2022\u2022\u2022'
                                    : deps.money.format(provider.balance),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: provider.toggleBalanceVisibility,
                                child: Icon(
                                  provider.balanceHidden
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 15,
                                  color: const Color(0xFFB9C4D4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text('Personal Information',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.md),
            _PersonalRow(
              icon: Icons.person_outline,
              tint: AppColors.infoTint,
              iconColor: AppColors.accent,
              label: 'FULL NAME',
              value: user?.fullName ?? '',
            ),
            _PersonalRow(
              icon: Icons.calendar_today_outlined,
              tint: AppColors.infoTint,
              iconColor: AppColors.accent,
              label: 'DATE OF BIRTH',
              value: user?.dateOfBirth ?? 'Not provided',
            ),
            _PersonalRow(
              icon: Icons.mail_outline,
              tint: AppColors.primaryTint,
              iconColor: AppColors.gold,
              label: 'EMAIL ADDRESS',
              value: user?.email ?? '',
            ),
            _PersonalRow(
              icon: Icons.phone_outlined,
              tint: AppColors.primaryTint,
              iconColor: AppColors.gold,
              label: 'PHONE NUMBER',
              value: user?.phone ?? '',
            ),
            _PersonalRow(
              icon: Icons.location_on_outlined,
              tint: AppColors.dangerTint,
              iconColor: AppColors.danger,
              label: 'RESIDENTIAL ADDRESS',
              value: user?.address ?? 'Not provided',
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text('Account Information',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.md),
            InfoCard(
              rows: [
                InfoRow(label: 'Account Type', value: account?.accountType ?? ''),
                InfoRow(label: 'BVN', value: account?.bvnMasked ?? ''),
                InfoRow(label: 'Currency', value: account?.currency ?? 'NGN'),
                InfoRow(label: 'Date Opened', value: account?.dateOpened ?? ''),
                InfoRow(
                  label: 'Account Status',
                  valueWidget: LabelPill(
                    label: account?.statusLabel ?? 'ACTIVE',
                    color: AppColors.success,
                    background: AppColors.successTint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text('SUPPORT', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.md),
            SettingsSection(
              title: '',
              children: [
                SettingsTile(
                  icon: Icons.chat_bubble_outline,
                  iconBackground: AppColors.infoTint,
                  iconColor: AppColors.accent,
                  label: 'Help & Support',
                  subtitle: 'Our contacts',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.support),
                ),
                SettingsTile(
                  icon: Icons.star_outline,
                  iconBackground: AppColors.primaryTint,
                  iconColor: AppColors.gold,
                  label: 'Rate the app',
                  subtitle: 'Tell us about your experience',
                  onTap: () => context.showMessage('Thanks! The store listing opens soon.'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SettingsSection(
              title: '',
              children: [
                SettingsTile(
                  icon: Icons.logout,
                  iconBackground: AppColors.dangerTint,
                  iconColor: AppColors.danger,
                  label: 'Log out',
                  onTap: _confirmLogout,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Text('Version ${AppConfig.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5)),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Download Account Statement',
              icon: Icons.download_outlined,
              showChevron: true,
              onPressed: () => context.showMessage('Your statement is being prepared.'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// One tappable row in the Personal Information list.
class _PersonalRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String label;
  final String value;

  const _PersonalRow({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9.5)),
                const SizedBox(height: 2),
                Text(value,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5, height: 1.35)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 19, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
