import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/state_views.dart';
import '../../widgets/transaction_tile.dart';

/// Transaction History M10 — the navy balance card, search, the
/// All / Pending / Successful / Failed tabs and a date-sectioned list.
class TransactionHistoryScreen extends StatefulWidget {
  /// True when hosted inside [HomeShell]; hides the back button.
  final bool embedded;

  const TransactionHistoryScreen({super.key, this.embedded = false});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() {
    final token = context.read<AuthProvider>().authToken;
    return context.read<TransactionProvider>().load(token);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();
    final provider = context.watch<TransactionProvider>();
    final account = context.watch<AccountProvider>().account;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account?.accountType ?? 'Savings Account',
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            Text(account?.accountNumber ?? '—',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance,
                            color: AppColors.primary, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('AVAILABLE BALANCE',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(deps.money.format(account?.balance ?? 0),
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: AppColors.white, fontSize: 26)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: TextField(
              controller: _search,
              onChanged: provider.search,
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterTabs(
            selected: provider.filter,
            onSelected: provider.applyFilter,
          ),
          const Divider(height: 1),
          Expanded(
            child: StateSwitcher(
              state: provider.state,
              errorMessage: provider.errorMessage,
              onRetry: _load,
              emptyView: const EmptyView(
                title: 'No transactions yet',
                message: 'Your account activity will appear here.',
              ),
              onSuccess: () {
                final grouped = provider.grouped;
                if (grouped.isEmpty) {
                  return const EmptyView(
                    title: 'Nothing matches that search',
                    message: 'Try a different keyword or filter.',
                    icon: Icons.search_off,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          child: Text(
                            deps.dates.groupHeader(entry.key),
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6),
                          ),
                        ),
                        for (final tx in entry.value)
                          TransactionTile(
                            transaction: tx,
                            money: deps.money,
                            dates: deps.dates,
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.transactionDetails,
                                arguments: tx),
                          ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: TextButton(
                          onPressed: _load,
                          child: const Text('View More Activities'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, TransactionProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in HistoryFilter.values)
              RadioListTile<HistoryFilter>(
                value: f,
                groupValue: provider.filter,
                title: Text(f.label),
                onChanged: (v) {
                  if (v != null) provider.applyFilter(v);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;

  const _FilterTabs({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          children: [
            for (final f in HistoryFilter.values)
              GestureDetector(
                onTap: () => onSelected(f),
                child: Container(
                  margin: const EdgeInsets.only(right: AppSpacing.xl),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2.5,
                        color: f == selected
                            ? AppColors.navy
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          f == selected ? FontWeight.w700 : FontWeight.w500,
                      color: f == selected
                          ? AppColors.navy
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
