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

    // Se non c'è email, mostra un dialog per inserirla
    if (_emailController.text.isEmpty) {
      _showForgotPasswordDialog();
      return;
    }

    // Se c'è già un'email, procedi direttamente
    _sendPasswordReset(_emailController.text.trim());
  }

  void _showForgotPasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Text(l10n.getString('reset_password')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.getString('reset_password_description'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
            ),
            const SizedBox(height: 20),
            EnterpriseTextField(
              controller: emailController,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.getString('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendPasswordReset(emailController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.getString('send')),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordReset(String email) async {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();

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
              l10n.getString('sending_reset_email'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    try {
      await authProvider.resetPassword(email);

      if (mounted) {
        Navigator.pop(context); // Chiudi loading dialog

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
                Text(l10n.getString('email_sent')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.getString('password_reset_sent_to'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warningOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.warningOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.getString('check_spam_folder'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.warningOrange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                child: Text(l10n.getString('got_it')),
              ),
            ],
          ),
        );
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
                Text(l10n.getString('error')),
              ],
            ),
            content: Text(
              '${l10n.getString('reset_password_failed')}: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.getString('ok')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showForgotPasswordDialog();
                },
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;

    return PageWithFloatingLanguage(
      child: Scaffold(
        backgroundColor: Colors.white,
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

  Widget _buildAirbnbHeader(AppLocalizations l10n, bool isTablet) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: false,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified_user,
                      size: 40,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.getString('welcome_back'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.getString('sign_in_to_account'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Email Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.getString('email'),
                hintText: l10n.getString('enter_email'),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
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
          ),

          const SizedBox(height: 16),

          // Password Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n.getString('password'),
                hintText: l10n.getString('enter_password'),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.getString('password_required');
                }
                if (value.length < AppConfig.minPasswordLength) {
                  return l10n.getString('password_min_length');
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 16),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    l10n.getString('remember_me'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              TextButton(
                onPressed: _forgotPassword,
                child: Text(
                  l10n.getString('forgot_password'),
                  style: TextStyle(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(AppLocalizations l10n, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _signInWithEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: authProvider.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                l10n.getString('sign_in'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.getString('or'),
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton(AppLocalizations l10n, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: authProvider.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata, color: Colors.red[600], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    l10n.getString('continue_with_google'),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSignUpLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.getString('dont_have_account'),
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            l10n.getString('sign_up'),
            style: TextStyle(
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
