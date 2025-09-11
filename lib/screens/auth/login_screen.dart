import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/page_with_floating_language.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _forgotPassword() {
    final l10n = AppLocalizations.of(context);
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.getString('please_enter_email'))),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.getString('reset_password')),
        content: Text(
          '${l10n.getString('password_reset_sent')} ${_emailController.text.trim()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.getString('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.resetPassword(_emailController.text.trim());

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.getString('password_reset_sent')),
                  ),
                );
              }
            },
            child: Text(l10n.getString('send')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return PageWithFloatingLanguage(
      child: Scaffold(
        backgroundColor: AppTheme.offWhite,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop
                    ? 500
                    : isTablet
                    ? 400
                    : double.infinity,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isTablet ? 40 : 20),

                      // Logo and Title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.verified_user,
                                size: 50,
                                color: AppTheme.pureWhite,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).getString('welcome_back'),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).getString('sign_in_to_account'),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textGray,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login Form Container
                      EnterpriseCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Email Field
                            EnterpriseTextField(
                              controller: _emailController,
                              label: AppLocalizations.of(
                                context,
                              ).getString('email'),
                              hint: AppLocalizations.of(
                                context,
                              ).getString('enter_email'),
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  ).getString('email_required');
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return AppLocalizations.of(
                                    context,
                                  ).getString('email_invalid');
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password Field
                            EnterprisePasswordField(
                              controller: _passwordController,
                              label: AppLocalizations.of(
                                context,
                              ).getString('password'),
                              hint: AppLocalizations.of(
                                context,
                              ).getString('enter_password'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  ).getString('password_required');
                                }
                                if (value.length <
                                    AppConfig.minPasswordLength) {
                                  return AppLocalizations.of(
                                    context,
                                  ).getString('password_min_length');
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: AppTheme.primaryBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).getString('remember_me'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppTheme.textGray,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _forgotPassword,
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).getString('forgot_password'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Sign In Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return NeonButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _signInWithEmail,
                                  text: authProvider.isLoading
                                      ? AppLocalizations.of(
                                          context,
                                        ).getString('signing_in')
                                      : AppLocalizations.of(
                                          context,
                                        ).getString('sign_in'),
                                  isLoading: authProvider.isLoading,
                                  neonColor: AppTheme.successGreen,
                                  height: 56,
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: AppTheme.borderGray),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).getString('or'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textGray,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: AppTheme.borderGray),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Google Sign In Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return NeonButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _signInWithGoogle,
                                  text: AppLocalizations.of(
                                    context,
                                  ).getString('sign_in_with_google'),
                                  icon: Icons.g_mobiledata,
                                  isLoading: authProvider.isLoading,
                                  isOutlined: true,
                                  neonColor: AppTheme.primaryBlue,
                                  height: 56,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).getString('dont_have_account'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textGray),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: Text(
                              AppLocalizations.of(context).getString('sign_up'),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.successGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      // Error Message
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: EnterpriseCard(
                                backgroundColor: AppTheme.errorRed.withValues(
                                  alpha: 0.05,
                                ),
                                borderColor: AppTheme.errorRed.withValues(
                                  alpha: 0.2,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppTheme.errorRed,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppTheme.errorRed,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: AppTheme.errorRed,
                                        size: 20,
                                      ),
                                      onPressed: authProvider.clearError,
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Bottom padding to prevent overflow
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20,
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
