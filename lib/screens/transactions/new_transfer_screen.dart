import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_config.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/error/app_exception.dart';
import '../../domain/entities/transfer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transfer_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/callout.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/tatum_scaffold.dart';

/// New Transfer Redesign — bank picker, account resolution, amount with the
/// daily limit hint, optional narration and the security tip.
class NewTransferScreen extends StatefulWidget {
  const NewTransferScreen({super.key});

  @override
  State<NewTransferScreen> createState() => _NewTransferScreenState();
}

class _NewTransferScreenState extends State<NewTransferScreen> {
  final _accountNumber = TextEditingController();
  final _amount = TextEditingController();
  final _narration = TextEditingController();

  String? _accountError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<TransferProvider>().loadBanks());
  }

  @override
  void dispose() {
    _accountNumber.dispose();
    _amount.dispose();
    _narration.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final deps = context.read<Dependencies>();
    final transfers = context.read<TransferProvider>();

    setState(() {
      _accountError = deps.validator.accountNumber(_accountNumber.text);
      _amountError = deps.validator
          .amount(_amount.text, max: AppConfig.dailyTransferLimit);
    });
    if (_accountError != null || _amountError != null) return;

    if (!transfers.canSubmit) {
      setState(() =>
          _accountError = 'Select a bank and enter a valid account number.');
      return;
    }

    final token = context.read<AuthProvider>().authToken;
    try {
      final receipt = await transfers.submit(
        token,
        amount: double.parse(_amount.text),
        narration: _narration.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.transferResult,
          arguments: receipt);
    } on AppException catch (e) {
      if (!mounted) return;
      // A failed transfer is a legitimate outcome, not a crash: route to the
      // dedicated failure screen with the reason from the domain layer.
      Navigator.pushNamed(context, AppRoutes.transferResult, arguments: {
        'failure': e.message,
        'amount': double.tryParse(_amount.text) ?? 0,
        'bank': transfers.selectedBank,
        'resolved': transfers.resolved,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deps = context.read<Dependencies>();
    final transfers = context.watch<TransferProvider>();

    return TatumScaffold(
      title: 'New Transfer',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _FieldLabel('SELECT BANK'),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _pickBank(transfers),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      transfers.selectedBank?.name ?? 'Choose destination bank',
                      style: TextStyle(
                        fontSize: 14,
                        color: transfers.selectedBank == null
                            ? AppColors.textSecondary
                            : AppColors.navy,
                        fontWeight: transfers.selectedBank == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'ACCOUNT NUMBER',
            hint: 'Enter 10-digit number',
            controller: _accountNumber,
            keyboardType: TextInputType.number,
            maxLength: 10,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: _accountError,
            suffix: transfers.resolving
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const Icon(Icons.info_outline,
                    size: 18, color: AppColors.textSecondary),
            onChanged: (value) {
              setState(() => _accountError = null);
              transfers.resolve(value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _FieldLabel('RECIPIENT NAME'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
            ),
            child: Text(
              transfers.resolved?.accountName ?? 'Account name will show here',
              style: TextStyle(
                fontSize: 14,
                fontWeight: transfers.resolved == null
                    ? FontWeight.w400
                    : FontWeight.w700,
                color: transfers.resolved == null
                    ? AppColors.textSecondary
                    : AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'AMOUNT',
            hint: '0.00',
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            prefixIcon: Icons.currency_exchange,
            errorText: _amountError,
            onChanged: (_) => setState(() => _amountError = null),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Daily Limit: ${deps.money.format(AppConfig.dailyTransferLimit)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'NARRATION (OPTIONAL)',
            hint: "What's this for?",
            controller: _narration,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Callout(
            title: 'Security Tip',
            message:
                "Always double-check the recipient's name before proceeding with the transfer.",
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Continue',
            isLoading: transfers.isLoading,
            background: AppColors.navy,
            foreground: AppColors.white,
            onPressed: _continue,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _pickBank(TransferProvider transfers) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => Column(
          children: [
            Text('Select Bank',
                style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: transfers.banks.length,
                itemBuilder: (_, i) {
                  final Bank bank = transfers.banks[i];
                  return ListTile(
                    title: Text(bank.name),
                    trailing: transfers.selectedBank?.code == bank.code
                        ? const Icon(Icons.check, color: AppColors.success)
                        : null,
                    onTap: () {
                      transfers.selectBank(bank);
                      transfers.resolve(_accountNumber.text);
                      Navigator.pop(sheetContext);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(letterSpacing: 1, fontWeight: FontWeight.w700),
      );
}
