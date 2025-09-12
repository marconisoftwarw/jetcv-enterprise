import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../l10n/app_localizations.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
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

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(
          l10n.getString('settings'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        surfaceTintColor: AppTheme.pureWhite,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: Icon(Icons.save_rounded, color: AppTheme.successGreen),
            tooltip: l10n.getString('save_settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
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

            // Sezione Lingua e Regione
            _buildLanguageRegionSection(l10n, isTablet),

            const SizedBox(height: 24),

            // Sezione Avanzate
            _buildAdvancedSection(l10n, isTablet),

            const SizedBox(height: 24),

            // Sezione Supporto
            _buildSupportSection(l10n, isTablet),

            const SizedBox(height: 32),

            // Sezione Account
            _buildAccountSection(l10n, isTablet),
          ],
        ),
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
                      user?.displayName ?? l10n.getString('user'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? l10n.getString('no_email'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGray,
                      ),
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
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        user?.roleDisplayName ?? l10n.getString('user'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
              return Column(
                children: [
                  _buildThemeSelector(
                    l10n,
                    themeProvider,
                    ThemeMode.light,
                    Icons.light_mode_rounded,
                    l10n.getString('light_mode'),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeSelector(
                    l10n,
                    themeProvider,
                    ThemeMode.dark,
                    Icons.dark_mode_rounded,
                    l10n.getString('dark_mode'),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeSelector(
                    l10n,
                    themeProvider,
                    ThemeMode.system,
                    Icons.brightness_auto_rounded,
                    l10n.getString('system_theme'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    AppLocalizations l10n,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String title,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return InkWell(
      onTap: () => themeProvider.setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textGray,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
          ],
        ),
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
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
          _buildSwitchTile(
            l10n.getString('email_notifications'),
            l10n.getString('email_notifications_desc'),
            _emailNotifications,
            Icons.email_outlined,
            (value) => setState(() => _emailNotifications = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            l10n.getString('push_notifications'),
            l10n.getString('push_notifications_desc'),
            _pushNotifications,
            Icons.notifications_outlined,
            (value) => setState(() => _pushNotifications = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            l10n.getString('sms_notifications'),
            l10n.getString('sms_notifications_desc'),
            _smsNotifications,
            Icons.sms_outlined,
            (value) => setState(() => _smsNotifications = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            l10n.getString('marketing_emails'),
            l10n.getString('marketing_emails_desc'),
            _marketingEmails,
            Icons.campaign_outlined,
            (value) => setState(() => _marketingEmails = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
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
      ),
    );
  }

  Widget _buildPrivacySecuritySection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
          _buildActionTile(
            l10n.getString('change_password'),
            l10n.getString('change_password_desc'),
            Icons.lock_outline,
            AppTheme.primaryBlue,
            _changePassword,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('two_factor_auth'),
            l10n.getString('two_factor_auth_desc'),
            Icons.security_outlined,
            AppTheme.successGreen,
            _setupTwoFactorAuth,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('active_sessions'),
            l10n.getString('active_sessions_desc'),
            Icons.devices_outlined,
            AppTheme.warningOrange,
            _manageActiveSessions,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('privacy_policy'),
            l10n.getString('privacy_policy_desc'),
            Icons.privacy_tip_outlined,
            AppTheme.textGray,
            _viewPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRegionSection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.getString('language_region'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionTile(
            l10n.getString('language'),
            l10n.getString('language_desc'),
            Icons.language_outlined,
            AppTheme.primaryBlue,
            _showLanguageSelector,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('timezone'),
            l10n.getString('timezone_desc'),
            Icons.access_time_outlined,
            AppTheme.successGreen,
            _changeTimeZone,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('date_format'),
            l10n.getString('date_format_desc'),
            Icons.calendar_today_outlined,
            AppTheme.warningOrange,
            _changeDateFormat,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.textGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.getString('advanced'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            l10n.getString('auto_sync'),
            l10n.getString('auto_sync_desc'),
            _autoSync,
            Icons.sync_outlined,
            (value) => setState(() => _autoSync = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            l10n.getString('location_services'),
            l10n.getString('location_services_desc'),
            _locationServices,
            Icons.location_on_outlined,
            (value) => setState(() => _locationServices = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            l10n.getString('analytics'),
            l10n.getString('analytics_desc'),
            _analytics,
            Icons.analytics_outlined,
            (value) => setState(() => _analytics = value),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('cache_storage'),
            l10n.getString('cache_storage_desc'),
            Icons.storage_outlined,
            AppTheme.primaryBlue,
            _manageCacheStorage,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('backup_restore'),
            l10n.getString('backup_restore_desc'),
            Icons.backup_outlined,
            AppTheme.successGreen,
            _manageBackupRestore,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
          _buildActionTile(
            l10n.getString('help_center'),
            l10n.getString('help_center_desc'),
            Icons.help_outline,
            AppTheme.primaryBlue,
            _openHelpCenter,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('contact_support'),
            l10n.getString('contact_support_desc'),
            Icons.support_agent_outlined,
            AppTheme.successGreen,
            _contactSupport,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('report_bug'),
            l10n.getString('report_bug_desc'),
            Icons.bug_report_outlined,
            AppTheme.warningOrange,
            _reportBug,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('rate_app'),
            l10n.getString('rate_app_desc'),
            Icons.star_outline,
            AppTheme.warningOrange,
            _rateApp,
          ),
        ],
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
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
          _buildActionTile(
            l10n.getString('export_data'),
            l10n.getString('export_data_desc'),
            Icons.download_outlined,
            AppTheme.primaryBlue,
            _exportData,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            l10n.getString('delete_account'),
            l10n.getString('delete_account_desc'),
            Icons.delete_forever_outlined,
            AppTheme.errorRed,
            _deleteAccount,
          ),
          const SizedBox(height: 20),
          NeonButton(
            onPressed: _signOut,
            text: l10n.getString('sign_out'),
            icon: Icons.logout_rounded,
            isOutlined: true,
            neonColor: AppTheme.errorRed,
          ),
        ],
      ),
    );
  }

  // Metodi per le azioni
  void _saveSettings() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.pureWhite),
            const SizedBox(width: 8),
            Text(l10n.getString('settings_saved')),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _changePassword() {
    // TODO: Implementare cambio password con Supabase
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('change_password'),
    );
  }

  void _setupTwoFactorAuth() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('two_factor_auth'),
    );
  }

  void _manageActiveSessions() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('active_sessions'),
    );
  }

  void _viewPrivacyPolicy() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('privacy_policy'),
    );
  }

  void _showLanguageSelector() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.getString('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('🇮🇹', 'Italiano', const Locale('it', 'IT')),
            _buildLanguageOption('🇬🇧', 'English', const Locale('en', 'US')),
            _buildLanguageOption('🇩🇪', 'Deutsch', const Locale('de', 'DE')),
            _buildLanguageOption('🇫🇷', 'Français', const Locale('fr', 'FR')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, Locale locale) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      onTap: () {
        context.read<LocaleProvider>().setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  void _changeTimeZone() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('timezone'),
    );
  }

  void _changeDateFormat() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('date_format'),
    );
  }

  void _manageCacheStorage() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('cache_storage'),
    );
  }

  void _manageBackupRestore() {
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('backup_restore'),
    );
  }

  void _openHelpCenter() {
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
}
