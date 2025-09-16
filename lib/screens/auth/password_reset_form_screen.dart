import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/page_with_floating_language.dart';
import '../../l10n/app_localizations.dart';

class PasswordResetFormScreen extends StatefulWidget {
  const PasswordResetFormScreen({super.key});

  @override
  State<PasswordResetFormScreen> createState() =>
      _PasswordResetFormScreenState();
}

class _PasswordResetFormScreenState extends State<PasswordResetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Debug: Form validation failed');
      return;
    }

    print('✅ Debug: Form validation passed');

    // Debug: controlla che i controller siano inizializzati
    print(
      '🔍 Debug: Email controller initialized: ${_emailController.hasListeners}',
    );
    print(
      '🔍 Debug: Old password controller initialized: ${_oldPasswordController.hasListeners}',
    );
    print(
      '🔍 Debug: New password controller initialized: ${_newPasswordController.hasListeners}',
    );

    // Controlla che i controller siano stati inizializzati
    if (!mounted) {
      print('❌ Debug: Widget not mounted');
      return;
    }

    // Controlla che i controller non siano null
    if (_emailController == null ||
        _oldPasswordController == null ||
        _newPasswordController == null) {
      print('❌ Debug: One or more controllers are null');
      return;
    }

    // Controlla che i valori non siano null o vuoti
    final email = _emailController.text.trim();
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    print('🔍 Debug: Email value: $email');
    print('🔍 Debug: Old password length: ${oldPassword.length}');
    print('🔍 Debug: New password length: ${newPassword.length}');

    if (email.isEmpty || oldPassword.isEmpty || newPassword.isEmpty) {
      print('❌ Debug: One or more fields are empty');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context);

    // Mostra loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryBlue),
            const SizedBox(height: 16),
            Text(
              l10n.getString('resetting_password'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    try {
      final success = await authProvider.resetPasswordWithOldPassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        Navigator.pop(context); // Chiudi loading dialog

        if (success) {
          // Mostra success dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.successGreen),
                  const SizedBox(width: 12),
                  Text(l10n.getString('password_reset_success')),
                ],
              ),
              content: Text(
                l10n.getString('password_reset_success_message'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Chiudi dialog
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.getString('go_to_login')),
                ),
              ],
            ),
          );
        } else {
          // Mostra error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.errorRed),
                  const SizedBox(width: 12),
                  Text(l10n.getString('password_reset_error')),
                ],
              ),
              content: Text(
                authProvider.errorMessage ??
                    l10n.getString('password_reset_error_message'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.getString('try_again')),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Chiudi loading dialog

        // Mostra error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorRed),
                const SizedBox(width: 12),
                Text(l10n.getString('password_reset_error')),
              ],
            ),
            content: Text(
              'Error: $e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(l10n.getString('try_again')),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PageWithFloatingLanguage(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: EnterpriseCard(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(
                              Icons.lock_reset,
                              color: AppTheme.primaryBlue,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.getString('reset_password'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.getString(
                                      'reset_password_form_description',
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppTheme.textGray),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        EnterpriseTextField(
                          controller: _emailController,
                          label: l10n.getString('email'),
                          hint: l10n.getString('enter_email'),
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.getString('email_required');
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return l10n.getString('email_invalid');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Old Password Field
                        EnterpriseTextField(
                          controller: _oldPasswordController,
                          label: l10n.getString('current_password'),
                          hint: l10n.getString('enter_current_password'),
                          obscureText: _obscureOldPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureOldPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureOldPassword = !_obscureOldPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.getString(
                                'current_password_required',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // New Password Field
                        EnterpriseTextField(
                          controller: _newPasswordController,
                          label: l10n.getString('new_password'),
                          hint: l10n.getString('enter_new_password'),
                          obscureText: _obscureNewPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.getString('new_password_required');
                            }
                            if (value.length < 6) {
                              return l10n.getString('password_min_length');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        EnterpriseTextField(
                          controller: _confirmPasswordController,
                          label: l10n.getString('confirm_new_password'),
                          hint: l10n.getString('confirm_new_password_hint'),
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.getString(
                                'confirm_password_required',
                              );
                            }
                            if (value != _newPasswordController.text) {
                              return l10n.getString('passwords_do_not_match');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Reset Password Button
                        NeonButton(
                          onPressed: _resetPassword,
                          text: l10n.getString('reset_password'),
                          isLoading: false,
                        ),
                        const SizedBox(height: 16),

                        // Back to Login Button
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            l10n.getString('back_to_login'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
