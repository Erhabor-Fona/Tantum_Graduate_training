import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../domain/entities/telco.dart';
import '../../providers/airtime_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/network_avatar.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tatum_scaffold.dart';
import '../../widgets/transaction_tile.dart';

/// Airtime Transactions & Quick Buy — network picker across the top, a search
/// box, and the recent airtime/data history.
class AirtimeHomeScreen extends StatefulWidget {
  const AirtimeHomeScreen({super.key});

  @override
  State<AirtimeHomeScreen> createState() => _AirtimeHomeScreenState();
}

class _AirtimeHomeScreenState extends State<AirtimeHomeScreen> {
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
    return context.read<AirtimeProvider>().initialise(token);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();
    final airtime = context.watch<AirtimeProvider>();

    return TatumScaffold(
      title: 'Buy Airtime',
      style: TatumAppBarStyle.brand,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('SELECT NETWORK',
              style: theme.textTheme.bodySmall
                  ?.copyWith(letterSpacing: 1, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final network in TelcoNetwork.values)
                GestureDetector(
                  onTap: () async {
                    await airtime.selectNetwork(network);
                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRoutes.buyAirtime);
                    }
                  },
                  child: Column(
                    children: [
                      NetworkAvatar(
                        network: network,
                        selected: network == airtime.network,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(network.label, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextField(
            controller: _search,
            onChanged: airtime.searchHistory,
            decoration: InputDecoration(
              hintText: 'Search history',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('RECENT AIRTIME TRANSACTIONS',
              style: theme.textTheme.bodySmall
                  ?.copyWith(letterSpacing: 1, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          StateSwitcher(
            state: airtime.state,
            errorMessage: airtime.errorMessage,
            onRetry: _load,
            emptyView: const EmptyView(
              title: 'No airtime purchases yet',
              message: 'Pick a network above to top up.',
              icon: Icons.phone_android_outlined,
            ),
            onSuccess: () => Column(
              children: [
                for (final tx in airtime.history)
                  TransactionTile(
                    transaction: tx,
                    money: deps.money,
                    dates: deps.dates,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.transactionDetails,
                        arguments: tx),
                  ),
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: _load,
                  child: const Text('VIEW MORE ACTIVITIES'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
