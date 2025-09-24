import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/password_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/page_with_floating_language.dart';
import '../../l10n/app_localizations.dart';

class PasswordResetWithTokenScreen extends StatefulWidget {
  const PasswordResetWithTokenScreen({super.key});

  @override
  State<PasswordResetWithTokenScreen> createState() => _PasswordResetWithTokenScreenState();
}

class _PasswordResetWithTokenScreenState extends State<PasswordResetWithTokenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _token;

  @override
  void initState() {
    super.initState();
    _extractTokenFromUrl();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _extractTokenFromUrl() {
    try {
      if (kIsWeb) {
        final uri = Uri.base;
        _token = uri.queryParameters['token'];
        debugPrint('🔐 PasswordResetWithTokenScreen: Extracted token from URL: ${_token?.substring(0, 10)}...');
      } else {
        // For mobile, we might need to handle this differently
        // For now, we'll assume the token is passed as a parameter
        debugPrint('🔐 PasswordResetWithTokenScreen: Running on mobile - token handling needed');
      }
    } catch (e) {
      debugPrint('❌ PasswordResetWithTokenScreen: Error extracting token: $e');
      setState(() {
        _errorMessage = 'Token non valido o mancante';
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_token == null || _token!.isEmpty) {
      setState(() {
        _errorMessage = 'Token di reset non valido';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final l10n = AppLocalizations.of(context);
      
      debugPrint('🔐 PasswordResetWithTokenScreen: Starting password reset with token');
      
      final result = await PasswordService.resetPassword(
        token: _token!,
        newPassword: _newPasswordController.text.trim(),
      );

      debugPrint('🔐 PasswordResetWithTokenScreen: Reset result: $result');

      if (mounted) {
        if (result['ok'] == true || result['success'] == true) {
          setState(() {
            _successMessage = l10n.getString('password_reset_success');
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result['message'] ?? 'Errore durante il reset della password';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ PasswordResetWithTokenScreen: Reset error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Errore di connessione. Verifica la tua connessione internet e riprova.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Show success screen
    if (_successMessage != null) {
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Success Icon
                        Center(
                          child: Icon(
                            Icons.check_circle,
                            color: AppTheme.successGreen,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Success Message
                        Text(
                          _successMessage!,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          l10n.getString('password_reset_success_message'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Go to Login Button
                        NeonButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          text: l10n.getString('go_to_login'),
                          isLoading: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Show error screen if no token
    if (_token == null || _token!.isEmpty) {
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error Icon
                        Center(
                          child: Icon(
                            Icons.error_outline,
                            color: AppTheme.errorRed,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Message
                        Text(
                          'Link non valido',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Il link di reset password non è valido o è scaduto. Richiedi un nuovo link.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Back to Login Button
                        NeonButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          text: l10n.getString('go_to_login'),
                          isLoading: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Main form screen
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
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Inserisci la tua nuova password',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Error message display
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.errorRed.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.errorRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                if (value.length < 8) {
                                  return 'La password deve essere di almeno 8 caratteri';
                                }
                                if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
                                  return 'La password deve contenere almeno: 1 minuscola, 1 maiuscola, 1 numero, 1 simbolo';
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
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.getString('confirm_password_required');
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
                              onPressed: _isLoading ? null : _resetPassword,
                              text: l10n.getString('reset_password'),
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Back to Login Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          l10n.getString('back_to_login'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}
