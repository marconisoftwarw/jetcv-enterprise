import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/dynamic_sidebar.dart';
import '../../services/user_type_service.dart';
import '../../l10n/app_localizations.dart';

import '../certification/create_certification_screen.dart';
import '../certification/certification_list_screen.dart';
import '../profile/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
      case 1: // Users
        Navigator.pushNamed(context, '/admin');
        break;
      case 2: // Certifications
        Navigator.pushNamed(context, '/certifications');
        break;
      case 3: // Legal Entities
        Navigator.pushNamed(context, '/legal-entities');
        break;
      case 4: // Analytics
        Navigator.pushNamed(context, '/analytics');
        break;
      case 5: // Settings
        Navigator.pushNamed(context, '/settings');
        break;
      case 6: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _handleLegalEntityNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        // Rimani nella home
        break;
      case 1: // My Certifications
        Navigator.pushNamed(context, '/certifications');
        break;
      case 2: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _handleCertifierNavigation(int index) {
    switch (index) {
      case 0: // Certifications
        Navigator.pushNamed(context, '/certifications');
        break;
      case 1: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _handleUserNavigation(int index) {
    switch (index) {
      case 0: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Controllo sicuro per verificare se l'utente è admin basato sul database
        // final user = authProvider.currentUser;
        // final isAdmin = user?.isAdminFromDatabase ?? false;

        return Scaffold(
          body: Row(
            children: [
              // Navigation Rail
              Container(
                width: 280,
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  border: Border(
                    right: BorderSide(color: AppTheme.borderGray, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: DynamicSidebar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                ),
              ),

              // Main Content
              Expanded(
                child: _buildContent(authProvider.userType ?? AppUserType.user),
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
        return const _DashboardContent();
      case 1:
        return Center(child: Text(l10n.getString('user_management')));
      case 2:
        return const CertificationListScreen();
      case 3:
        return Center(child: Text(l10n.getString('legal_entities_management')));
      case 4:
        return Center(child: Text(l10n.getString('analytics')));
      case 5:
        return Center(child: Text(l10n.getString('settings')));
      case 6:
        return const UserProfileScreen();
      default:
        return const _DashboardContent();
    }
  }

  Widget _buildLegalEntityContent() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return const _DashboardContent();
      case 1:
        return const CertificationListScreen();
      case 2:
        return const UserProfileScreen();
      default:
        return const _DashboardContent();
    }
  }

  Widget _buildCertifierContent() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return const CertificationListScreen();
      case 1:
        return const UserProfileScreen();
      default:
        return const CertificationListScreen();
    }
  }

  Widget _buildUserContent() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedIndex) {
      case 0:
        return const UserProfileScreen();
      default:
        return const UserProfileScreen();
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

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

                // Quick actions
                Text(
                  'Azioni Rapide',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 20),
                _buildQuickActionsGrid(context),

                const SizedBox(height: 40),

                // Recent activity
                Text(
                  'Attività Recente',
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

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: [
        _buildQuickActionCard(
          context,
          'Complete Profile',
          'Fill in missing information',
          Icons.person_add,
          AppTheme.successGreen,
          () {
            // Navigate to profile completion
          },
        ),
        _buildQuickActionCard(
          context,
          'Company Setup',
          'Configure your business',
          Icons.business,
          AppTheme.primaryBlue,
          () {
            // Navigate to company setup
          },
        ),
        _buildQuickActionCard(
          context,
          'Get Certified',
          'Start certification process',
          Icons.verified_user,
          AppTheme.purple,
          () {
            // Navigate to certification creation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCertificationScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return EnterpriseCard(
      isHoverable: true,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 32, color: accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
