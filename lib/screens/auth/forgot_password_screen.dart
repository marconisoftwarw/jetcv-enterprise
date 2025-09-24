import 'package:flutter/material.dart';
import '../../services/password_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/page_with_floating_language.dart';
import '../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error
    });

    try {
      // Create localized messages for better UX
      final localizedMessages = {
        'resetEmailSent': AppLocalizations.of(
          context,
        )!.getString('reset_email_sent'),
        'userNotFound': 'Nessun account trovato con questo indirizzo email.',
        'multipleUsersFound':
            'Errore interno: più account trovati con questo email.',
        'validationError': 'Indirizzo email non valido.',
        'emailServiceError':
            'Servizio email temporaneamente non disponibile. Riprova più tardi.',
        'genericError':
            'Errore durante l\'invio dell\'email. Riprova più tardi.',
        'networkError':
            'Errore di connessione. Verifica la tua connessione internet e riprova.',
      };

      final result = await PasswordService.sendPasswordResetEmail(
        email: _emailController.text.trim(),
        localizedMessages: localizedMessages,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _emailSent = true;
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result['message'] ?? 'Errore sconosciuto';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Errore di connessione. Verifica la tua connessione internet e riprova.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_emailSent) {
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
                            Icons.mark_email_read,
                            color: AppTheme.successGreen,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Success Message
                        Text(
                          l10n.getString('reset_email_sent'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          l10n.getString('reset_email_sent_message'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textGray),
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
                                  l10n.getString('forgot_password'),
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
                                  l10n.getString('forgot_password_description'),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppTheme.textGray),
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
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.errorRed),
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
                            const SizedBox(height: 32),

                            // Send Reset Email Button
                            NeonButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              text: l10n.getString('send_reset_email'),
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
    );
  }
}
