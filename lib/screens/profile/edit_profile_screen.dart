import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/dependencies.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Edit Profile — Save Changes stays disabled until something actually
/// changes, which is the difference between the "Disabled" and enabled
/// designs.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  late String _originalName;
  late String _originalEmail;
  late String _originalPhone;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _originalName = user?.fullName ?? '';
    _originalEmail = user?.email ?? '';
    _originalPhone = user?.phone ?? '';
    _name = TextEditingController(text: _originalName);
    _email = TextEditingController(text: _originalEmail);
    _phone = TextEditingController(text: _originalPhone);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _name.text.trim() != _originalName ||
      _email.text.trim() != _originalEmail ||
      _phone.text.trim() != _originalPhone;

  Future<void> _save() async {
    final deps = context.read<Dependencies>();
    setState(() {
      _nameError = deps.validator.fullName(_name.text);
      _emailError = deps.validator.email(_email.text);
      _phoneError = deps.validator.phone(_phone.text);
    });
    if ([_nameError, _emailError, _phoneError].any((e) => e != null)) return;

    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final updated = await context.read<AccountProvider>().updateProfile(
          auth.authToken,
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (updated == null) {
      context.showMessage('We could not save your changes.', isError: true);
      return;
    }
    await auth.applyUpdatedUser(updated);
    if (!mounted) return;
    context.showMessage('Profile updated successfully.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryTint,
                  child: Text(
                    user?.initials ?? 'T',
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.navy),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2.5),
                    ),
                    child: const Icon(Icons.edit, size: 13, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => context.showMessage('Photo upload is coming soon.'),
              child: const Text('Change Photo'),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppTextField(
            label: 'Full Name',
            controller: _name,
            textCapitalization: TextCapitalization.words,
            errorText: _nameError,
            onChanged: (_) => setState(() => _nameError = null),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Email Address',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (_) => setState(() => _emailError = null),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Phone Number',
            controller: _phone,
            keyboardType: TextInputType.phone,
            errorText: _phoneError,
            onChanged: (_) => setState(() => _phoneError = null),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          PrimaryButton(
            label: 'Save Changes',
            isLoading: _saving,
            onPressed: _isDirty ? _save : null,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
