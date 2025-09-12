import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/global_hamburger_menu.dart';
import '../../l10n/app_localizations.dart';

class UserSettingsScreen extends StatefulWidget {
  final bool hideMenu;

  const UserSettingsScreen({super.key, this.hideMenu = false});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  bool _isMenuExpanded = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _marketingEmails = false;
  bool _autoSync = true;
  bool _locationServices = true;
  bool _analytics = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    // Se hideMenu è true, restituisci solo il contenuto senza il menu
    if (widget.hideMenu) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con informazioni utente
            _buildUserHeader(l10n, isTablet),

            const SizedBox(height: 32),

            // Sezione Aspetto
            _buildAppearanceSection(l10n, isTablet),

            const SizedBox(height: 24),

            // Sezione Notifiche
            _buildNotificationsSection(l10n, isTablet),

            const SizedBox(height: 24),

            // Sezione Privacy e Sicurezza
            _buildPrivacySecuritySection(l10n, isTablet),

            const SizedBox(height: 24),

            // Sezione Supporto
            _buildSupportSection(l10n, isTablet),

            const SizedBox(height: 32),

            // Sezione Account
            _buildAccountSection(l10n, isTablet),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MediaQuery.of(context).size.width <= 768
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isMenuExpanded = !_isMenuExpanded;
                  });
                },
              ),
              title: Text(
                l10n.getString('settings'),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.save, color: AppTheme.primaryBlue),
                  onPressed: _saveSettings,
                  tooltip: l10n.getString('save_settings'),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Row(
            children: [
              // Navigation Rail - Solo su desktop o quando espanso su mobile
              if (MediaQuery.of(context).size.width > 768 || _isMenuExpanded)
                Container(
                  width: MediaQuery.of(context).size.width > 768 ? 280 : 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return GlobalHamburgerMenu(
                        selectedIndex: 4, // Impostazioni
                        onDestinationSelected: (index) {
                          setState(() {
                            _isMenuExpanded = false;
                          });
                          _handleNavigation(index);
                        },
                        isExpanded: _isMenuExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _isMenuExpanded = expanded;
                          });
                        },
                        context: context,
                        userType: authProvider.userType,
                      );
                    },
                  ),
                ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con informazioni utente
                      _buildUserHeader(l10n, isTablet),

            const SizedBox(height: 32),

                      // Sezione Aspetto
                      _buildAppearanceSection(l10n, isTablet),

                      const SizedBox(height: 24),

                      // Sezione Notifiche
                      _buildNotificationsSection(l10n, isTablet),

                      const SizedBox(height: 24),

                      // Sezione Privacy e Sicurezza
                      _buildPrivacySecuritySection(l10n, isTablet),

                      const SizedBox(height: 24),

                      // Sezione Supporto
                      _buildSupportSection(l10n, isTablet),

            const SizedBox(height: 32),

                      // Sezione Account
                      _buildAccountSection(l10n, isTablet),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Overlay scuro su mobile quando il menu è aperto
          if (MediaQuery.of(context).size.width <= 768 && _isMenuExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuExpanded = false;
                  });
                },
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(AppLocalizations l10n, bool isTablet) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return EnterpriseCard(
          child: Row(
            children: [
              // Avatar
              Container(
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user?.initials ?? 'U',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Utente',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@example.com',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.type?.name.toUpperCase() ?? 'USER',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.getString('appearance'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.getString('dark_mode'),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.getString('dark_mode_description'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeProvider.isDarkMode,
            onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: AppTheme.primaryBlue,
                    activeTrackColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.getString('notifications'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildNotificationToggle(
            l10n.getString('email_notifications'),
            l10n.getString('email_notifications_description'),
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            l10n.getString('push_notifications'),
            l10n.getString('push_notifications_description'),
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            l10n.getString('sms_notifications'),
            l10n.getString('sms_notifications_description'),
            _smsNotifications,
            (value) => setState(() => _smsNotifications = value),
          ),
          const SizedBox(height: 16),
          _buildNotificationToggle(
            l10n.getString('marketing_emails'),
            l10n.getString('marketing_emails_description'),
            _marketingEmails,
            (value) => setState(() => _marketingEmails = value),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryBlue,
          activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildPrivacySecuritySection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.getString('privacy_security'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPrivacyToggle(
            l10n.getString('auto_sync'),
            l10n.getString('auto_sync_description'),
            _autoSync,
            (value) => setState(() => _autoSync = value),
          ),
          const SizedBox(height: 16),
          _buildPrivacyToggle(
            l10n.getString('location_services'),
            l10n.getString('location_services_description'),
            _locationServices,
            (value) => setState(() => _locationServices = value),
          ),
          const SizedBox(height: 16),
          _buildPrivacyToggle(
            l10n.getString('analytics'),
            l10n.getString('analytics_description'),
            _analytics,
            (value) => setState(() => _analytics = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyToggle(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryBlue,
          activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildSupportSection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_center, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.getString('support'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportButton(
            l10n.getString('help_center'),
            Icons.help_outline,
            _helpCenter,
          ),
          const SizedBox(height: 12),
          _buildSupportButton(
            l10n.getString('contact_support'),
            Icons.support_agent,
            _contactSupport,
          ),
          const SizedBox(height: 12),
          _buildSupportButton(
            l10n.getString('report_bug'),
            Icons.bug_report,
            _reportBug,
          ),
          const SizedBox(height: 12),
          _buildSupportButton(
            l10n.getString('rate_app'),
            Icons.star_rate,
            _rateApp,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.getString('account'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAccountButton(
            l10n.getString('export_data'),
            Icons.download,
            _exportData,
          ),
          const SizedBox(height: 12),
          _buildAccountButton(
            l10n.getString('delete_account'),
            Icons.delete_forever,
            _deleteAccount,
            isDestructive: true,
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 20),
          _buildAccountButton(
            l10n.getString('sign_out'),
            Icons.logout,
            _signOut,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountButton(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppTheme.errorRed : AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDestructive ? AppTheme.errorRed : null,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    // Implementa il salvataggio delle impostazioni
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).getString('settings_saved')),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _helpCenter() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('help_center'),
    );
  }

  void _contactSupport() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('contact_support'),
    );
  }

  void _reportBug() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('report_bug'),
    );
  }

  void _rateApp() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('rate_app'),
    );
  }

  void _exportData() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('export_data'),
    );
  }

  void _deleteAccount() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('delete_account'),
    );
  }

  void _signOut() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.getString('sign_out')),
        content: Text(l10n.getString('sign_out_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.getString('cancel')),
          ),
          TextButton(
            onPressed: () async {
                Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: Text(l10n.getString('sign_out')),
          ),
        ],
      ),
    );
  }

  void _showFeatureInDevelopment(String feature) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.construction, color: AppTheme.pureWhite),
            const SizedBox(width: 8),
            Text('$feature - ${l10n.getString('feature_in_development')}'),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Certificazioni
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2: // Entità Legali
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 3: // Profilo
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 4: // Impostazioni
        // Rimani nella schermata corrente
        break;
    }
  }
}
