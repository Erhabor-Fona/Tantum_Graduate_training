import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/support_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/callout.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/tatum_scaffold.dart';

/// Create Service Request — the three-step stepper from the designs:
/// Request Details → Review → Confirmation.
class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  static const _steps = ['Request\nDetails', 'Review', 'Confirmation'];

  int _step = 0;
  String? _category;
  String? _issueType;
  String? _attachment;

  final _reference = TextEditingController();
  final _description = TextEditingController();
  String? _descriptionError;

  @override
  void dispose() {
    _reference.dispose();
    _description.dispose();
    super.dispose();
  }

  void _next() {
    final deps = context.read<Dependencies>();
    if (_step == 0) {
      setState(() {
        _descriptionError =
            deps.validator.required(_description.text, field: 'A description');
      });
      if (_category == null || _issueType == null) {
        context.showMessage('Choose a category and an issue type.',
            isError: true);
        return;
      }
      if (_descriptionError != null) return;
    }
    setState(() => _step++);
  }

  Future<void> _submit() async {
    final token = context.read<AuthProvider>().authToken;
    final created = await context.read<SupportProvider>().create(
          token,
          category: _category!,
          issueType: _issueType!,
          description: _description.text.trim(),
          transactionReference:
              _reference.text.trim().isEmpty ? null : _reference.text.trim(),
          attachmentName: _attachment,
        );

    if (!mounted) return;
    if (created == null) {
      context.showMessage('We could not submit your request.', isError: true);
      return;
    }
    setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    final support = context.watch<SupportProvider>();

    return TatumScaffold(
      title: 'Create Service Request',
      onBack: _step == 0 ? null : () => setState(() => _step--),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md),
            child: _Stepper(steps: _steps, current: _step),
          ),
          const Divider(height: 1),
          Expanded(
            child: switch (_step) {
              0 => _detailsStep(support),
              1 => _reviewStep(support),
              _ => _confirmationStep(),
            },
          ),
        ],
      ),
    );
  }

  Widget _detailsStep(SupportProvider support) => ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _Dropdown(
            label: 'Select Category',
            value: _category,
            items: SupportProvider.categories,
            icon: Icons.receipt_long_outlined,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Dropdown(
            label: 'Select Issue Type',
            value: _issueType,
            items: SupportProvider.issueTypes,
            icon: Icons.error_outline,
            onChanged: (v) => setState(() => _issueType = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Transaction Reference (Optional)',
            hint: 'TRF0524202412345678',
            controller: _reference,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Description',
            hint: 'Please describe your issue in detail...',
            controller: _description,
            maxLines: 4,
            maxLength: 500,
            errorText: _descriptionError,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() => _descriptionError = null),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AttachmentBox(
            fileName: _attachment,
            onTap: () => setState(() => _attachment =
                _attachment == null ? 'Receipt.pdf' : null),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Callout(
            message:
                'Our support team will review your request and get back to you as soon as possible.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(label: 'Continue', onPressed: _next),
          const SizedBox(height: AppSpacing.xl),
        ],
      );

  Widget _reviewStep(SupportProvider support) => ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Review your request',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          _ReviewRow(label: 'Category', value: _category ?? '—'),
          _ReviewRow(label: 'Issue Type', value: _issueType ?? '—'),
          if (_reference.text.trim().isNotEmpty)
            _ReviewRow(label: 'Reference', value: _reference.text.trim()),
          _ReviewRow(label: 'Description', value: _description.text.trim()),
          if (_attachment != null)
            _ReviewRow(label: 'Attachment', value: _attachment!),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Submit Request',
            isLoading: support.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Edit Details',
            onPressed: () => setState(() => _step = 0),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      );

  Widget _confirmationStep() {
    final theme = Theme.of(context);
    final request = context.read<SupportProvider>().active;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
                color: AppColors.successTint, shape: BoxShape.circle),
            child: const Icon(Icons.check,
                size: 40, color: AppColors.success),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Request Submitted',
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your request ${request?.id ?? ''} has been received. '
          'Our team will respond as soon as possible.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        PrimaryButton(
          label: 'View Request',
          onPressed: () => Navigator.pushReplacementNamed(
              context, AppRoutes.requestDetails),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Back to Support',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final List<String> steps;
  final int current;

  const _Stepper({required this.steps, required this.current});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i <= current ? AppColors.accent : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: i < current
                      ? const Icon(Icons.check,
                          size: 15, color: AppColors.white)
                      : Text('${i + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: i <= current
                                ? AppColors.white
                                : AppColors.textSecondary,
                          )),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        i == current ? FontWeight.w700 : FontWeight.w400,
                    color: i <= current
                        ? AppColors.navy
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 22),
                  color: i < current ? AppColors.accent : AppColors.border,
                ),
              ),
          ],
        ],
      );
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.expand_more),
            hint: Text('Select an option',
                style: Theme.of(context).textTheme.bodyMedium),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: AppColors.accent),
            ),
            items: [
              for (final item in items)
                DropdownMenuItem(value: item, child: Text(item)),
            ],
            onChanged: onChanged,
          ),
        ],
      );
}

class _AttachmentBox extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;

  const _AttachmentBox({required this.fileName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Attachment (Optional)', style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
            ),
            child: Column(
              children: [
                Icon(fileName == null ? Icons.attach_file : Icons.description,
                    color: fileName == null
                        ? AppColors.textSecondary
                        : AppColors.success),
                const SizedBox(height: AppSpacing.xs),
                Text(fileName ?? 'Tap to attach file',
                    style: theme.textTheme.bodyMedium),
                Text(
                  fileName == null ? 'JPG, PNG, PDF (Max 5MB)' : 'Tap to remove',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: theme.textTheme.bodySmall
                  ?.copyWith(letterSpacing: 0.8, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
