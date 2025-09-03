import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

import '../../providers/locale_provider.dart';
import '../../widgets/linkedin_card.dart';

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
  bool _darkMode = false;
  bool _autoSync = true;
  bool _locationServices = true;
  bool _analytics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Impostazioni',
          style: AppTheme.title1.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Salva impostazioni',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sezione Notifiche
            _buildNotificationsSection(),

            const SizedBox(height: 32),

            // Sezione Preferenze App
            _buildAppPreferencesSection(),

            const SizedBox(height: 32),

            // Sezione Privacy e Sicurezza
            _buildPrivacySecuritySection(),

            const SizedBox(height: 32),

            // Sezione Lingua e Regione
            _buildLanguageRegionSection(),

            const SizedBox(height: 32),

            // Sezione Avanzate
            _buildAdvancedSection(),

            const SizedBox(height: 32),

            // Sezione Supporto
            _buildSupportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 16),
              Text('Notifiche', style: AppTheme.title1),
            ],
          ),
          const SizedBox(height: 24),

          // Email Notifications
          SwitchListTile(
            title: Text(
              'Notifiche Email',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Ricevi notifiche via email per attività importanti',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),

          const Divider(),

          // Push Notifications
          SwitchListTile(
            title: Text(
              'Notifiche Push',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Ricevi notifiche push sull\'app',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),

          const Divider(),

          // SMS Notifications
          SwitchListTile(
            title: Text(
              'Notifiche SMS',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Ricevi notifiche via SMS per eventi critici',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),

          const Divider(),

          // Marketing Emails
          SwitchListTile(
            title: Text(
              'Email Marketing',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Ricevi aggiornamenti su nuovi prodotti e servizi',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _marketingEmails,
            onChanged: (value) {
              setState(() {
                _marketingEmails = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferencesSection() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 16),
              Text('Preferenze App', style: AppTheme.title1),
            ],
          ),
          const SizedBox(height: 24),

          // Dark Mode
          SwitchListTile(
            title: Text(
              'Modalità Scura',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Attiva il tema scuro per l\'interfaccia',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),

          const Divider(),

          // Auto Sync
          SwitchListTile(
            title: Text(
              'Sincronizzazione Automatica',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Sincronizza automaticamente i dati in background',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _autoSync,
            onChanged: (value) {
              setState(() {
                _autoSync = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),

          const Divider(),

          // Location Services
          SwitchListTile(
            title: Text(
              'Servizi di Localizzazione',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Consenti l\'accesso alla posizione per le certificazioni',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _locationServices,
            onChanged: (value) {
              setState(() {
                _locationServices = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),

          const Divider(),

          // Analytics
          SwitchListTile(
            title: Text(
              'Analytics e Statistiche',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Condividi dati anonimi per migliorare l\'app',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            value: _analytics,
            onChanged: (value) {
              setState(() {
                _analytics = value;
              });
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySecuritySection() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 16),
              Text('Privacy e Sicurezza', style: AppTheme.title1),
            ],
          ),
          const SizedBox(height: 24),

          // Cambia Password
          ListTile(
            leading: Icon(Icons.lock, color: AppTheme.warningOrange),
            title: Text(
              'Cambia Password',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Aggiorna la password del tuo account',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changePassword,
          ),

          const Divider(),

          // Autenticazione a due fattori
          ListTile(
            leading: Icon(Icons.verified_user, color: AppTheme.successGreen),
            title: Text(
              'Autenticazione a Due Fattori',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Aggiungi un livello extra di sicurezza',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _setupTwoFactorAuth,
          ),

          const Divider(),

          // Sessione attiva
          ListTile(
            leading: Icon(Icons.devices, color: AppTheme.accentBlue),
            title: Text(
              'Sessioni Attive',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Gestisci i dispositivi connessi',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _manageActiveSessions,
          ),

          const Divider(),

          // Privacy Policy
          ListTile(
            leading: Icon(Icons.privacy_tip, color: AppTheme.secondaryBlue),
            title: Text(
              'Informativa Privacy',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Leggi la nostra politica sulla privacy',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _viewPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRegionSection() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return LinkedInCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.language, color: AppTheme.primaryBlue, size: 24),
                  const SizedBox(width: 16),
                  Text('Lingua e Regione', style: AppTheme.title1),
                ],
              ),
              const SizedBox(height: 24),

              // Selezione Lingua
              ListTile(
                leading: Icon(Icons.translate, color: AppTheme.accentBlue),
                title: Text(
                  'Lingua',
                  style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _getLanguageDisplayName(localeProvider.locale),
                  style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showLanguageSelector,
              ),

              const Divider(),

              // Fuso Orario
              ListTile(
                leading: Icon(Icons.access_time, color: AppTheme.warningOrange),
                title: Text(
                  'Fuso Orario',
                  style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Europa/Roma (UTC+1)',
                  style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changeTimeZone,
              ),

              const Divider(),

              // Formato Data
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: AppTheme.successGreen,
                ),
                title: Text(
                  'Formato Data',
                  style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'DD/MM/YYYY',
                  style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changeDateFormat,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSection() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 16),
              Text('Impostazioni Avanzate', style: AppTheme.title1),
            ],
          ),
          const SizedBox(height: 24),

          // Cache e Storage
          ListTile(
            leading: Icon(Icons.storage, color: AppTheme.warningOrange),
            title: Text(
              'Cache e Storage',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Gestisci lo spazio di archiviazione',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _manageCacheStorage,
          ),

          const Divider(),

          // Backup e Ripristino
          ListTile(
            leading: Icon(Icons.backup, color: AppTheme.successGreen),
            title: Text(
              'Backup e Ripristino',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Salva e ripristina i tuoi dati',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _manageBackupRestore,
          ),

          const Divider(),

          // Debug e Log
          ListTile(
            leading: Icon(Icons.bug_report, color: AppTheme.errorRed),
            title: Text(
              'Debug e Log',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Informazioni tecniche per il supporto',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _viewDebugLogs,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 16),
              Text('Supporto e Aiuto', style: AppTheme.title1),
            ],
          ),
          const SizedBox(height: 24),

          // Centro Aiuto
          ListTile(
            leading: Icon(Icons.help_center, color: AppTheme.accentBlue),
            title: Text(
              'Centro Aiuto',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Trova risposte alle domande frequenti',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openHelpCenter,
          ),

          const Divider(),

          // Contatta Supporto
          ListTile(
            leading: Icon(Icons.support_agent, color: AppTheme.successGreen),
            title: Text(
              'Contatta Supporto',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Richiedi assistenza dal nostro team',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _contactSupport,
          ),

          const Divider(),

          // Segnala Bug
          ListTile(
            leading: Icon(Icons.report_problem, color: AppTheme.warningOrange),
            title: Text(
              'Segnala Bug',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Aiutaci a migliorare l\'app',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _reportBug,
          ),

          const Divider(),

          // Valuta App
          ListTile(
            leading: Icon(Icons.star, color: AppTheme.warningOrange),
            title: Text(
              'Valuta l\'App',
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Dai la tua opinione sull\'app store',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _rateApp,
          ),
        ],
      ),
    );
  }

  // Metodi helper
  String _getLanguageDisplayName(Locale? locale) {
    switch (locale?.languageCode) {
      case 'it':
        return 'Italiano';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      default:
        return 'Italiano';
    }
  }

  // Metodi per le azioni
  void _saveSettings() {
    // TODO: Implementare il salvataggio delle impostazioni
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Impostazioni salvate con successo!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _changePassword() {
    // TODO: Implementare cambio password
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _setupTwoFactorAuth() {
    // TODO: Implementare 2FA
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _manageActiveSessions() {
    // TODO: Implementare gestione sessioni
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _viewPrivacyPolicy() {
    // TODO: Implementare visualizzazione privacy policy
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona Lingua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Italiano'),
              leading: const Text('🇮🇹'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(
                  const Locale('it', 'IT'),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: const Text('🇬🇧'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(
                  const Locale('en', 'US'),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Deutsch'),
              leading: const Text('🇩🇪'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(
                  const Locale('de', 'DE'),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Français'),
              leading: const Text('🇫🇷'),
              onTap: () {
                context.read<LocaleProvider>().setLocale(
                  const Locale('fr', 'FR'),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeTimeZone() {
    // TODO: Implementare cambio fuso orario
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _changeDateFormat() {
    // TODO: Implementare cambio formato data
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _manageCacheStorage() {
    // TODO: Implementare gestione cache
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _manageBackupRestore() {
    // TODO: Implementare backup e ripristino
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _viewDebugLogs() {
    // TODO: Implementare visualizzazione log debug
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _openHelpCenter() {
    // TODO: Implementare centro aiuto
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _contactSupport() {
    // TODO: Implementare contatto supporto
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _reportBug() {
    // TODO: Implementare segnalazione bug
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _rateApp() {
    // TODO: Implementare valutazione app
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }
}
