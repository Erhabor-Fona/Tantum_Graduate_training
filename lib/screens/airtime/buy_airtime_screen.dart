import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/error/app_exception.dart';
import '../../domain/entities/telco.dart';
import '../../providers/airtime_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/callout.dart';
import '../../widgets/network_avatar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/tatum_scaffold.dart';

/// Buy Airtime & Data Purchase — network row, the Airtime/Data segmented
/// control, recipient number, quick-amount chips (or data plans) and a
/// custom amount field.
class BuyAirtimeScreen extends StatefulWidget {
  const BuyAirtimeScreen({super.key});

  @override
  State<BuyAirtimeScreen> createState() => _BuyAirtimeScreenState();
}

class _BuyAirtimeScreenState extends State<BuyAirtimeScreen> {
  final _phone = TextEditingController();
  final _customAmount = TextEditingController();

  String? _phoneError;
  String? _amountError;

  @override
  void dispose() {
    _phone.dispose();
    _customAmount.dispose();
    super.dispose();
  }

  double? get _effectiveAmount {
    final airtime = context.read<AirtimeProvider>();
    if (_customAmount.text.trim().isNotEmpty) {
      return double.tryParse(_customAmount.text.trim());
    }
    return airtime.selectedAmount;
  }

  Future<void> _continue() async {
    final deps = context.read<Dependencies>();
    final airtime = context.read<AirtimeProvider>();
    final amount = _effectiveAmount;

    setState(() {
      _phoneError = deps.validator.phone(_phone.text);
      _amountError = amount == null || amount <= 0
          ? 'Choose or enter an amount.'
          : null;
    });
    if (_phoneError != null || _amountError != null) return;

    final token = context.read<AuthProvider>().authToken;
    try {
      final receipt = await airtime.purchase(
        token,
        phoneNumber: _phone.text.trim(),
        amount: amount!,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.purchaseResult,
          arguments: receipt);
    } on AppException catch (e) {
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.purchaseResult, arguments: {
        'failure': e.message,
        'amount': amount,
        'network': airtime.network,
        'recipient': _phone.text.trim(),
        'planName': airtime.selectedPlan?.name,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();
    final airtime = context.watch<AirtimeProvider>();
    final isData = airtime.type == PurchaseType.data;

    return TatumScaffold(
      title: 'Buy Airtime & Data',
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
                  onTap: () => airtime.selectNetwork(network),
                  child: Column(
                    children: [
                      NetworkAvatar(
                        network: network,
                        selected: network == airtime.network,
                        dimmed: network != airtime.network,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        network.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: network == airtime.network
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: network == airtime.network
                              ? AppColors.navy
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Service', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                _ServiceToggle(
                  selected: airtime.type,
                  onChanged: (value) {
                    _customAmount.clear();
                    airtime.selectType(value);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Phone Number', style: theme.textTheme.bodyMedium),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.contacts_outlined, size: 16),
                      label: const Text('Contacts',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 11,
                  onChanged: (_) => setState(() => _phoneError = null),
                  decoration: InputDecoration(
                    hintText: '0803 123 4567',
                    counterText: '',
                    errorText: _phoneError,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(isData ? 'Select Plan' : 'Amount',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),

                // Chips scroll horizontally so each one keeps its natural
                // width instead of being squeezed to fit the screen.
                //
                // The fixed height is required: a horizontal ListView has
                // unbounded height, which would throw inside this Column.
                SizedBox(
                  height: 46,
                  child: _ChipStrip(
                    itemCount: isData
                        ? airtime.plans.length
                        : airtime.quickAmounts.length,
                    builder: (index) {
                      if (isData) {
                        final plan = airtime.plans[index];
                        return _ChoiceChip(
                          label: plan.name,
                          sublabel: deps.money.format(plan.price),
                          selected: airtime.selectedPlan?.id == plan.id,
                          onTap: () {
                            _customAmount.clear();
                            airtime.selectPlan(plan);
                            setState(() => _amountError = null);
                          },
                        );
                      }

                      final amount = airtime.quickAmounts[index];
                      return _ChoiceChip(
                        label: deps.money.format(amount),
                        selected: airtime.selectedAmount == amount &&
                            _customAmount.text.isEmpty,
                        onTap: () {
                          _customAmount.clear();
                          airtime.selectAmount(amount);
                          setState(() => _amountError = null);
                        },
                      );
                    },
                    emptyMessage: isData
                        ? 'No data plans available for this network.'
                        : 'No quick amounts available.',
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _customAmount,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                  ],
                  onChanged: (_) {
                    airtime.selectAmount(null);
                    setState(() => _amountError = null);
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter custom amount',
                    filled: true,
                    fillColor: AppColors.surface,
                    errorText: _amountError,
                    prefixText: '${deps.money.symbol} ',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Callout(
            title: 'Need Help?',
            message:
            'Issues with your purchase? Our team is available 24/7 to assist you.',
            icon: Icons.help_outline,
            actionLabel: 'LEARN MORE',
            onAction: () => Navigator.pushNamed(context, AppRoutes.support),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Continue',
            icon: Icons.lock_outline,
            showChevron: true,
            isLoading: airtime.isLoading,
            onPressed: _continue,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// A horizontally scrolling strip of chips.
///
/// SRP: owns scrolling and spacing only — it does not know whether the chips
/// are amounts or data plans, so both branches of the form share it.
class _ChipStrip extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) builder;
  final String emptyMessage;

  const _ChipStrip({
    required this.itemCount,
    required this.builder,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          emptyMessage,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (context, index) => builder(index),
    );
  }
}

/// The Airtime | Data Bundle segmented control.
class _ServiceToggle extends StatelessWidget {
  final PurchaseType selected;
  final ValueChanged<PurchaseType> onChanged;

  const _ServiceToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final type in PurchaseType.values)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: type == selected
                      ? AppColors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: type == selected
                      ? const [
                    BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ]
                      : null,
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: type == selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: type == selected
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

/// A quick-amount or data-plan chip.
///
/// Lays its label and optional sublabel out horizontally and sizes itself to
/// its content, so a strip of chips scrolls rather than compressing.
class _ChoiceChip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryTint : AppColors.white,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.6 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              sublabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    ),
  );
}