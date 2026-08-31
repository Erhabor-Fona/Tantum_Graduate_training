import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../domain/entities/account_limit.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/callout.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tatum_scaffold.dart';

/// Account Limits & KYC — the Limits and KYC tabs from the designs.
class AccountLimitsScreen extends StatefulWidget {
  const AccountLimitsScreen({super.key});

  @override
  State<AccountLimitsScreen> createState() => _AccountLimitsScreenState();
}

class _AccountLimitsScreenState extends State<AccountLimitsScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    final token = context.read<AuthProvider>().authToken;
    return context.read<AccountProvider>().load(token);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>();

    return TatumScaffold(
      title: 'Account Limits',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: _SegmentedTabs(
              labels: const ['Transaction Limits', 'KYC Level'],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: StateSwitcher(
              state: accounts.state,
              errorMessage: accounts.errorMessage,
              onRetry: _load,
              onSuccess: () => _tab == 0
                  ? _LimitsTab(limits: accounts.limits)
                  : const _KycTab(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitsTab extends StatelessWidget {
  final List<AccountLimit> limits;
  const _LimitsTab({required this.limits});

  @override
  Widget build(BuildContext context) {
    final deps = context.read<Dependencies>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        for (final limit in limits) ...[
          _LimitCard(limit: limit, money: deps.money),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.sm),
        Callout(
          tone: CalloutTone.warning,
          title: 'Increase your limits',
          message:
              'Upgrade your KYC level to raise your daily transfer and withdrawal limits.',
          icon: Icons.verified_user_outlined,
          actionLabel: 'UPGRADE KYC',
          onAction: () => context.showMessage('KYC upgrade is coming soon.'),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.tune,
                label: 'Manage Limits',
                onTap: () => context.showMessage('Limit management is coming soon.'),
              ),
            ),
            Expanded(
              child: QuickActionButton(
                icon: Icons.menu_book_outlined,
                label: 'Limits Guide',
                onTap: () => Navigator.pushNamed(context, AppRoutes.support),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _LimitCard extends StatelessWidget {
  final AccountLimit limit;
  final dynamic money;

  const _LimitCard({required this.limit, required this.money});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nearCap = limit.progress > 0.8;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(limit.name, style: theme.textTheme.titleSmall)),
              Text(money.format(limit.limit),
                  style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: limit.progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                  nearCap ? AppColors.danger : AppColors.success),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used ${money.format(limit.used)}',
                  style: theme.textTheme.bodySmall),
              Text('${money.format(limit.remaining)} left',
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _KycTab extends StatelessWidget {
  const _KycTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.successTint,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            children: [
              const Icon(Icons.verified_user,
                  size: 40, color: AppColors.success),
              const SizedBox(height: AppSpacing.md),
              Text('Tier 2 Verified', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('Your BVN and phone number have been verified.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final step in const [
          ('Phone Number', true),
          ('BVN Verification', true),
          ('Valid ID Document', true),
          ('Proof of Address', false),
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              step.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
              color: step.$2 ? AppColors.success : AppColors.textMuted,
            ),
            title: Text(step.$1),
            subtitle: Text(step.$2 ? 'Verified' : 'Required for Tier 3'),
          ),
        const SizedBox(height: AppSpacing.xl),
        Callout(
          tone: CalloutTone.info,
          title: 'Unlock Tier 3',
          message:
              'Upload a proof of address to remove your daily transfer cap entirely.',
          actionLabel: 'UPLOAD DOCUMENT',
          onAction: () => context.showMessage('Document upload is coming soon.'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Pill-style tab selector used on the limits screen.
class _SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selected ? AppColors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            i == selected ? FontWeight.w700 : FontWeight.w500,
                        color: i == selected
                            ? AppColors.navy
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
