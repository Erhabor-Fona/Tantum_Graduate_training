import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/transaction_tile.dart';

/// Home Dashboard Redesign V2 — greeting header, yellow balance card,
/// quick actions, the invite banner and recent transactions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().authToken;
    await Future.wait([
      context.read<AccountProvider>().load(token),
      context.read<TransactionProvider>().load(token),
      context.read<NotificationProvider>().load(token),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final deps = context.read<Dependencies>();
    final account = context.watch<AccountProvider>();
    final transactions = context.watch<TransactionProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, AppSpacing.xxl),
            children: [
              _Header(name: user?.firstName ?? 'there'),
              const SizedBox(height: AppSpacing.xl),
              StateSwitcher(
                state: account.state,
                errorMessage: account.errorMessage,
                onRetry: _load,
                onSuccess: () => _BalanceCard(
                  accountNumber: account.account?.accountNumber ?? '',
                  accountType: account.account?.accountType ?? 'Savings Account',
                  balance: deps.money.format(account.balance),
                  hidden: account.balanceHidden,
                  onToggle: account.toggleBalanceVisibility,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _SectionHeading(
                title: 'Quick Actions',
                actionLabel: 'View All',
                onAction: () => Navigator.pushNamed(context, AppRoutes.airtimeHome),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionButton(
                    icon: Icons.swap_horiz,
                    label: 'Transfer Money',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.newTransfer),
                  ),
                  QuickActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Pay Bills',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bill payments are coming soon.')),
                    ),
                  ),
                  QuickActionButton(
                    icon: Icons.phone_android_outlined,
                    label: 'Buy Airtime',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.airtimeHome),
                  ),
                  QuickActionButton(
                    icon: Icons.grid_view_rounded,
                    label: 'More',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Get more out of Tatum',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13.5)),
              const SizedBox(height: AppSpacing.md),
              const _InviteBanner(),
              const SizedBox(height: AppSpacing.xxl),
              _SectionHeading(
                title: 'Recent Transactions',
                actionLabel: 'View All',
                onAction: () => Navigator.pushNamed(context, AppRoutes.transactionHistory),
              ),
              const SizedBox(height: AppSpacing.sm),
              StateSwitcher(
                state: transactions.state,
                errorMessage: transactions.errorMessage,
                onRetry: _load,
                emptyView: const EmptyView(
                  title: 'No transactions yet',
                  message: 'Your activity will show up here once you start banking.',
                ),
                onSuccess: () => Column(
                  children: [
                    for (final tx in transactions.recent)
                      TransactionTile(
                        transaction: tx,
                        money: deps.money,
                        dates: deps.dates,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.transactionDetails,
                          arguments: tx,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = context.watch<NotificationProvider>().unreadCount;
    final user = context.watch<AuthProvider>().user;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryTint,
          child: Text(
            user?.initials ?? 'T',
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.navy, fontSize: 15),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, $name \u{1F44B}',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 17)),
              Text('Welcome back! Check your status.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            child: const Icon(Icons.notifications_none, size: 24),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          icon: const Icon(Icons.settings_outlined, size: 22),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String accountNumber;
  final String accountType;
  final String balance;
  final bool hidden;
  final VoidCallback onToggle;

  const _BalanceCard({
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.hidden,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(accountType,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: AppColors.success, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ACCOUNT NUMBER',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy)),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: accountNumber));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                            const SnackBar(content: Text('Account number copied')));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(accountNumber,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy)),
                        const SizedBox(width: 5),
                        const Icon(Icons.copy_outlined, size: 14, color: AppColors.navy),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                hidden ? '\u20A6 \u2022\u2022\u2022\u2022\u2022\u2022' : balance,
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.navy),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text('Available Balance',
              style: TextStyle(fontSize: 13, color: AppColors.navy)),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.accountInformation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(46),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Account'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.airtimeHome),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.navy,
                    minimumSize: const Size.fromHeight(46),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Quick Actions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteBanner extends StatelessWidget {
  const _InviteBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite your friends',
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white)),
                SizedBox(height: 5),
                Text(
                  'Invite your friends to download and save on the Tatum app and start earning.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB9C4D4), height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.card_giftcard, size: 30, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeading({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16.5)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ),
        ],
      );
}
