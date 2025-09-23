import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/legal_entity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/legal_entity.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/global_hamburger_menu.dart';
import '../../widgets/appbar_language_dropdown.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/responsive_card.dart';
import '../../l10n/app_localizations.dart';

import 'create_legal_entity_screen.dart';
import 'legal_entity_list_screen.dart';
import '../certification/certifier_dashboard_screen.dart';
import 'certifier_dashboard_screen.dart';
import '../settings/user_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LegalEntityProvider>().loadLegalEntities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      showMenu: true,
      selectedIndex: _selectedIndex == 0
          ? 0
          : (_selectedIndex == 1
                ? 2
                : 3), // Dashboard, Entità Legali, o Certifiers
      onDestinationSelected: (index) {
        _handleNavigation(index);
      },
      // title: 'Admin Dashboard', // Rimosso
      // actions: [ // Rimosso
      //   const AppBarLanguageDropdown(),
      //   IconButton(
      //     onPressed: () => _showProfileMenu(context),
      //     icon: const Icon(Icons.account_circle),
      //     tooltip: 'Profile Menu',
      //   ),
      // ],
      // hideAppBar: false, // Rimosso - usa il default true
      child: Stack(
        children: [
          _buildContent(),
          if (_selectedIndex == 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateLegalEntityScreen(),
                  ),
                ),
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: AppTheme.pureWhite,
                elevation: 8,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardContent();
      case 1:
        return const LegalEntityListScreen();
      case 2:
        return const _UsersContent();
      case 3:
        return const _AnalyticsContent();
      // Rimosso case 4 - Settings
      default:
        return const _DashboardContent();
    }
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlack,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.accentGreen),
              title: Text(
                'Profilo',
                style: TextStyle(color: AppTheme.primaryBlack),
              ),
              onTap: () async {
                Navigator.pop(context);

                // Carica i dati dell'utente prima di navigare al profilo
                final authProvider = context.read<AuthProvider>();
                if (authProvider.isAuthenticated &&
                    authProvider.currentUser == null) {
                  // Mostra un indicatore di caricamento
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Caricamento profilo...',
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  try {
                    await authProvider.loadUserData();
                    if (mounted) {
                      Navigator.pop(context); // Chiudi il dialog di caricamento
                      Navigator.pushNamed(context, '/profile');
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // Chiudi il dialog di caricamento
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Errore nel caricamento del profilo: $e',
                          ),
                          backgroundColor: AppTheme.errorRed,
                        ),
                      );
                    }
                  }
                } else {
                  // I dati sono già caricati, naviga direttamente
                  Navigator.pushNamed(context, '/profile');
                }
              },
            ),
            // Rimosso menu Impostazioni
            ListTile(
              leading: Icon(Icons.logout, color: AppTheme.accentOrange),
              title: Text(
                'Sign Out',
                style: TextStyle(color: AppTheme.primaryBlack),
              ),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().signOut();

                // Navigate to public home after logout
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/public', (route) => false);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
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
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<LegalEntityProvider>(
      builder: (context, legalEntityProvider, child) {
        return SingleChildScrollView(
          padding: ResponsivePadding.screen(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              ResponsiveText(
                'Welcome back, Admin!',
                textType: TextType.titleLarge,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 4 : 8),
              ResponsiveText(
                'Here\'s what\'s happening with your platform today.',
                textType: TextType.bodyLarge,
                style: TextStyle(color: AppTheme.primaryBlack),
              ),

              SizedBox(
                height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32,
              ),

              // Statistics Cards
              ResponsiveBreakpoints.isMobile(context)
                  ? Column(
                      children: [
                        _buildStatCard(
                          context,
                          'Total Legal Entities',
                          legalEntityProvider.totalCount.toString(),
                          Icons.business,
                          AppTheme.primaryBlue,
                          '+12%',
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          context,
                          'Active Users',
                          '1,234',
                          Icons.people,
                          AppTheme.accentGreen,
                          '+8%',
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          context,
                          'Certifications',
                          '5,678',
                          Icons.verified,
                          AppTheme.purple,
                          '+15%',
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.business,
                                          color: AppTheme.pureWhite,
                                          size: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '+12%',
                                        style: TextStyle(
                                          color: AppTheme.accentGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    legalEntityProvider.totalCount.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Legal Entities',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlack,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.accentGradient,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.pending,
                                          color: AppTheme.primaryBlack,
                                          size: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '+5',
                                        style: TextStyle(
                                          color: AppTheme.accentOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    legalEntityProvider.pendingCount.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pending Approvals',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlack,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: AppTheme.pureWhite,
                                          size: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '+8%',
                                        style: TextStyle(
                                          color: AppTheme.accentGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    legalEntityProvider.approvedCount
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Approved',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlack,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.accentGradient,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.cancel,
                                          color: AppTheme.pureWhite,
                                          size: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '-2',
                                        style: TextStyle(
                                          color: AppTheme.accentOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    legalEntityProvider.rejectedCount
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rejected',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlack,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      isHoverable: true,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateLegalEntityScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.add_business,
                                  color: AppTheme.pureWhite,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Create Legal Entity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add a new legal entity to the platform',
                                style: TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      isHoverable: true,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LegalEntityListScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.list_alt,
                                  color: AppTheme.pureWhite,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'View All Entities',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Browse and manage all legal entities',
                                style: TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      isHoverable: true,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminCertifierDashboardScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.verified_user,
                                  color: AppTheme.pureWhite,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Certificazioni',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gestisci e crea certificazioni',
                                style: TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      isHoverable: true,
                      child: InkWell(
                        onTap: () {
                          // Navigate to user management
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.people,
                                  color: AppTheme.pureWhite,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Manage Users',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add, edit, and manage user accounts',
                                style: TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      isHoverable: true,
                      child: InkWell(
                        onTap: () {
                          // Show invitation dialog
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.email,
                                  color: AppTheme.pureWhite,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Send Invitations',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Invite new users to join the platform',
                                style: TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      isHoverable: true,
                      child: InkWell(
                        onTap: () {
                          // Analytics placeholder
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.analytics,
                                  color: AppTheme.pureWhite,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Analytics',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'View platform analytics',
                                style: TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent Activity
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),

              _buildRecentActivityList(legalEntityProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityList(LegalEntityProvider provider) {
    final recentEntities = provider.legalEntities.take(5).toList();

    if (recentEntities.isEmpty) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 48, color: AppTheme.primaryBlack),
                const SizedBox(height: 16),
                Text(
                  'No recent activity',
                  style: TextStyle(color: AppTheme.primaryBlack, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GlassCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentEntities.length,
        separatorBuilder: (context, index) =>
            Divider(color: AppTheme.mediumGray),
        itemBuilder: (context, index) {
          final entity = recentEntities[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(
                entity.status,
              ).withValues(alpha: 0.1),
              child: Icon(
                Icons.business,
                color: _getStatusColor(entity.status),
              ),
            ),
            title: Text(
              entity.legalName ?? 'Nome non specificato',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              entity.email ?? 'Email non specificata',
              style: TextStyle(color: AppTheme.primaryBlack, fontSize: 14),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(entity.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(entity.status).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                entity.statusDisplayName,
                style: TextStyle(
                  color: _getStatusColor(entity.status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {
              provider.selectLegalEntity(entity);
              // Navigate to entity details
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(LegalEntityStatus status) {
    switch (status) {
      case LegalEntityStatus.pending:
        return AppTheme.accentOrange;
      case LegalEntityStatus.approved:
        return AppTheme.accentGreen;
      case LegalEntityStatus.rejected:
        return AppTheme.accentOrange;
    }
  }
}

class _UsersContent extends StatelessWidget {
  const _UsersContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage user accounts and permissions across the platform.',
            style: TextStyle(color: AppTheme.primaryBlack, fontSize: 16),
          ),
          const SizedBox(height: 32),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.people, size: 64, color: AppTheme.primaryBlack),
                    const SizedBox(height: 16),
                    Text(
                      'User Management Coming Soon',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Advanced user management features will be available in the next update.',
                      style: TextStyle(
                        color: AppTheme.primaryBlack,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track platform performance and user engagement metrics.',
            style: TextStyle(color: AppTheme.primaryBlack, fontSize: 16),
          ),
          const SizedBox(height: 32),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 64,
                      color: AppTheme.primaryBlack,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analytics Coming Soon',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comprehensive analytics and reporting features will be available in the next update.',
                      style: TextStyle(
                        color: AppTheme.primaryBlack,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Rimosso _SettingsContent - menu impostazioni rimosso

Widget _buildStatCard(
  BuildContext context,
  String title,
  String value,
  IconData icon,
  Color color,
  String change,
) {
  return ResponsiveCard(
    child: Padding(
      padding: ResponsivePadding.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.pureWhite,
                  size: ResponsiveBreakpoints.isMobile(context) ? 16 : 20,
                ),
              ),
              const Spacer(),
              Text(
                change,
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: ResponsiveBreakpoints.isMobile(context) ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
          ResponsiveText(
            value,
            textType: TextType.titleLarge,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 2 : 4),
          ResponsiveText(
            title,
            textType: TextType.bodyMedium,
            style: TextStyle(color: AppTheme.primaryBlack),
          ),
        ],
      ),
    ),
  );
}
