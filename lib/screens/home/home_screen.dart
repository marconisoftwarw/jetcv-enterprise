import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/global_hamburger_menu.dart';
import '../../services/user_type_service.dart';
import '../../l10n/app_localizations.dart';

import '../certification/create_certification_screen.dart';
import '../certification/certification_list_screen.dart';
import '../profile/user_profile_screen.dart';
import '../admin/legal_entity_management_screen.dart';
import '../settings/user_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Controlla se ci sono argomenti passati per impostare l'indice selezionato
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['selectedIndex'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = args!['selectedIndex'] as int;
        });
      });
    }
  }

  void _onDestinationSelected(int index) {
    final authProvider = context.read<AuthProvider>();
    final userType = authProvider.userType;

    // Aggiorna l'indice selezionato per mostrare il contenuto nella UI di destra
    setState(() {
      _selectedIndex = index;
    });

    // Naviga basandosi sul tipo di utente
    switch (userType ?? AppUserType.user) {
      case AppUserType.admin:
        _handleAdminNavigation(index);
        break;
      case AppUserType.legalEntity:
        _handleLegalEntityNavigation(index);
        break;
      case AppUserType.certifier:
        _handleCertifierNavigation(index);
        break;
      case AppUserType.user:
        _handleUserNavigation(index);
        break;
      default:
        _handleUserNavigation(index);
        break;
    }
  }

  void _handleAdminNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        // Rimani nella home
        break;
      case 1: // Certifications
        // Rimani nella home
        break;
      case 2: // Legal Entities
        // Rimani nella home
        break;
      case 3: // Settings
        // Rimani nella home
        break;
      case 4: // Profile
        // Rimani nella home
        break;
    }
  }

  void _handleLegalEntityNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        // Rimani nella home
        break;
      case 1: // My Certifications
        // Rimani nella home
        break;
      case 2: // Settings
        // Rimani nella home
        break;
      case 3: // Profile
        // Rimani nella home
        break;
    }
  }

  void _handleCertifierNavigation(int index) {
    switch (index) {
      case 0: // Certifications
        // Rimani nella home
        break;
      case 1: // Settings
        // Rimani nella home
        break;
      case 2: // Profile
        // Rimani nella home
        break;
    }
  }

  void _handleUserNavigation(int index) {
    switch (index) {
      case 0: // Profile
        // Rimani nella home
        break;
      case 1: // Settings
        // Rimani nella home
        break;
    }
  }

  void _validateAndResetSelectedIndex(AppUserType userType) {
    int maxIndex;
    switch (userType) {
      case AppUserType.admin:
        maxIndex = 4; // 5 items (0-4)
        break;
      case AppUserType.legalEntity:
        maxIndex = 2; // 3 items (0-2)
        break;
      case AppUserType.certifier:
        maxIndex = 2; // 3 items (0-2)
        break;
      case AppUserType.user:
        maxIndex = 1; // 2 items (0-1)
        break;
      default:
        maxIndex = 1;
        break;
    }

    if (_selectedIndex > maxIndex) {
      setState(() {
        _selectedIndex = 0; // Reset to first item
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Reset selectedIndex if it's out of range for current user type
        final currentUserType = authProvider.userType ?? AppUserType.user;
        _validateAndResetSelectedIndex(currentUserType);

        return Scaffold(
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
                    'JetCV',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          body: Stack(
            children: [
              Row(
                children: [
                  // Navigation Rail - Solo su desktop o quando espanso su mobile
                  if (MediaQuery.of(context).size.width > 768 ||
                      _isMenuExpanded)
                    Container(
                      width: MediaQuery.of(context).size.width > 768
                          ? 280
                          : 260,
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
                      child: GlobalHamburgerMenu(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onDestinationSelected,
                        isExpanded: _isMenuExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _isMenuExpanded = expanded;
                          });
                        },
                        context: context,
                        userType: authProvider.userType,
                      ),
                    ),

                  // Main Content
                  Expanded(
                    child: _buildContent(
                      authProvider.userType ?? AppUserType.user,
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
      },
    );
  }

  Widget _buildContent(AppUserType userType) {
    // Mostra il contenuto basato sul tipo di utente e sull'indice selezionato
    switch (userType ?? AppUserType.user) {
      case AppUserType.admin:
        return _buildAdminContent();
      case AppUserType.legalEntity:
        return _buildLegalEntityContent();
      case AppUserType.certifier:
        return _buildCertifierContent();
      case AppUserType.user:
        return _buildUserContent();
      default:
        return _buildUserContent();
    }
  }

  Widget _buildAdminContent() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return _DashboardContent(l10n: l10n);
      case 1:
        return const CertificationListScreen();
      case 2:
        return _buildLegalEntitiesManagementContent(l10n);
      case 3:
        return const UserSettingsScreen(hideMenu: true);
      case 4:
        return const UserProfileScreen(hideMenu: true);
      default:
        return _DashboardContent(l10n: l10n);
    }
  }

  Widget _buildLegalEntityContent() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return _DashboardContent(l10n: l10n);
      case 1:
        return _buildLegalEntitiesManagementContent(l10n);
      case 2:
        return const UserProfileScreen(hideMenu: true);
      default:
        return _DashboardContent(l10n: l10n);
    }
  }

  Widget _buildCertifierContent() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return _DashboardContent(l10n: l10n);
      case 1:
        return const CertificationListScreen();
      case 2:
        return const UserProfileScreen(hideMenu: true);
      default:
        return _DashboardContent(l10n: l10n);
    }
  }

  Widget _buildUserContent() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return const UserProfileScreen(hideMenu: true);
      case 1:
        return const UserSettingsScreen(hideMenu: true);
      default:
        return const UserProfileScreen(hideMenu: true);
    }
  }

  Widget _buildLegalEntitiesManagementContent(AppLocalizations l10n) {
    return const LegalEntityManagementScreen(hideMenu: true);
  }

  Widget _buildSettingsContent(AppLocalizations l10n) {
    return const UserSettingsScreen(hideMenu: true);
  }
}

class _DashboardContent extends StatelessWidget {
  final AppLocalizations l10n;

  const _DashboardContent({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Container(
          color: AppTheme.offWhite,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                EnterpriseCard(
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.pureWhite,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Benvenuto, ${user.firstName}!',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gestisci le tue certificazioni e la tua azienda',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textGray,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Grafico delle certificazioni emesse
                Text(
                  l10n.getString('certifications_trend'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCertificationsChart(context, l10n),

                const SizedBox(height: 40),

                // Recent activity
                Text(
                  l10n.getString('recent_activity'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 20),
                _buildRecentActivityList(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCertificationsChart(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    // Dati di esempio per il grafico (negli ultimi 6 mesi)
    final List<FlSpot> spots = [
      const FlSpot(0, 5), // Gennaio
      const FlSpot(1, 8), // Febbraio
      const FlSpot(2, 12), // Marzo
      const FlSpot(3, 15), // Aprile
      const FlSpot(4, 18), // Maggio
      const FlSpot(5, 22), // Giugno
    ];

    return EnterpriseCard(
      child: Column(
        children: [
          // Header del grafico
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AppTheme.pureWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('issued_certifications'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.getString('last_6_months'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              // Statistiche rapide
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '22',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  Text(
                    l10n.getString('this_month'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Grafico
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppTheme.lightGray, strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(color: AppTheme.lightGray, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final style = TextStyle(
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = Text(
                              l10n.getString('month_jan'),
                              style: style,
                            );
                            break;
                          case 1:
                            text = Text(
                              l10n.getString('month_feb'),
                              style: style,
                            );
                            break;
                          case 2:
                            text = Text(
                              l10n.getString('month_mar'),
                              style: style,
                            );
                            break;
                          case 3:
                            text = Text(
                              l10n.getString('month_apr'),
                              style: style,
                            );
                            break;
                          case 4:
                            text = Text(
                              l10n.getString('month_may'),
                              style: style,
                            );
                            break;
                          case 5:
                            text = Text(
                              l10n.getString('month_jun'),
                              style: style,
                            );
                            break;
                          default:
                            text = Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppTheme.lightGray),
                ),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 25,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: AppTheme.primaryGradient,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppTheme.primaryBlue,
                          strokeWidth: 2,
                          strokeColor: AppTheme.pureWhite,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.3),
                          AppTheme.primaryBlue.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Legenda e statistiche aggiuntive
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.getString('total'),
                  '80',
                  Icons.verified,
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.getString('monthly_average'),
                  '13.3',
                  Icons.trending_up,
                  AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.getString('growth'),
                  '+340%',
                  Icons.show_chart,
                  AppTheme.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textGray,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    return EnterpriseCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nessuna attività recente',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'La tua attività apparirà qui una volta che inizierai a usare la piattaforma.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          NeonButton(
            text: 'Esplora Certificazioni',
            onPressed: () {
              // Navigate to certifications
            },
            isOutlined: true,
            neonColor: AppTheme.primaryBlue,
            height: 44,
          ),
        ],
      ),
    );
  }
}

class UserSettingsContent extends StatefulWidget {
  const UserSettingsContent({super.key});

  @override
  State<UserSettingsContent> createState() => _UserSettingsContentState();
}

class _UserSettingsContentState extends State<UserSettingsContent> {
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

    return Container(
      color: AppTheme.offWhite,
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

            // Sezione Lingua e Regione
            _buildLanguageRegionSection(l10n, isTablet),

            const SizedBox(height: 24),

            // Sezione Avanzate
            _buildAdvancedSection(l10n, isTablet),

            const SizedBox(height: 24),

            // Sezione Supporto
            _buildSupportSection(l10n, isTablet),
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
