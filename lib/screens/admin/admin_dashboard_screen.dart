import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/legal_entity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/legal_entity.dart';

import '../../config/app_theme.dart';

import '../../widgets/linkedin_card.dart';

import 'create_legal_entity_screen.dart';
import 'legal_entity_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LegalEntityProvider>().loadLegalEntities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: AppTheme.title1.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showProfileMenu(context),
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile Menu',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.white,
              border: Border(
                right: BorderSide(color: AppTheme.borderGrey, width: 1),
              ),
            ),
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppTheme.white,
              selectedIconTheme: const IconThemeData(
                color: AppTheme.primaryBlue,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppTheme.textSecondary,
              ),
              selectedLabelTextStyle: AppTheme.body2.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: AppTheme.body2.copyWith(
                color: AppTheme.textSecondary,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business),
                  label: Text('Legal Entities'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics),
                  label: Text('Analytics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateLegalEntityScreen(),
                ),
              ),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
              elevation: 4,
              child: const Icon(Icons.add),
            )
          : null,
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
      case 4:
        return const _SettingsContent();
      default:
        return const _DashboardContent();
    }
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
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
                color: AppTheme.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.primaryBlue),
              title: Text('Profilo', style: AppTheme.body1),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.secondaryBlue),
              title: Text('Impostazioni', style: AppTheme.body1),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppTheme.errorRed),
              title: Text('Sign Out', style: AppTheme.body1),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<LegalEntityProvider>(
      builder: (context, legalEntityProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text('Welcome back, Admin!', style: AppTheme.headline2),
              const SizedBox(height: 8),
              Text(
                'Here\'s what\'s happening with your platform today.',
                style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
              ),

              const SizedBox(height: 32),

              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: LinkedInMetricCard(
                      title: 'Total Legal Entities',
                      value: legalEntityProvider.totalCount.toString(),
                      icon: Icons.business,
                      iconColor: AppTheme.primaryBlue,
                      change: '+12%',
                      isPositive: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinkedInMetricCard(
                      title: 'Pending Approvals',
                      value: legalEntityProvider.pendingCount.toString(),
                      icon: Icons.pending,
                      iconColor: AppTheme.warningOrange,
                      change: '+5',
                      isPositive: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinkedInMetricCard(
                      title: 'Approved',
                      value: legalEntityProvider.approvedCount.toString(),
                      icon: Icons.check_circle,
                      iconColor: AppTheme.successGreen,
                      change: '+8%',
                      isPositive: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinkedInMetricCard(
                      title: 'Rejected',
                      value: legalEntityProvider.rejectedCount.toString(),
                      icon: Icons.cancel,
                      iconColor: AppTheme.errorRed,
                      change: '-2',
                      isPositive: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Text('Quick Actions', style: AppTheme.title1),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: LinkedInActionCard(
                      title: 'Create Legal Entity',
                      description: 'Add a new legal entity to the platform',
                      icon: Icons.add_business,
                      iconColor: AppTheme.primaryBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateLegalEntityScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinkedInActionCard(
                      title: 'View All Entities',
                      description: 'Browse and manage all legal entities',
                      icon: Icons.list_alt,
                      iconColor: AppTheme.successGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LegalEntityListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: LinkedInActionCard(
                      title: 'Manage Users',
                      description: 'Add, edit, and manage user accounts',
                      icon: Icons.people,
                      iconColor: AppTheme.secondaryBlue,
                      onTap: () {
                        // Navigate to user management
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinkedInActionCard(
                      title: 'Send Invitations',
                      description: 'Invite new users to join the platform',
                      icon: Icons.email,
                      iconColor: AppTheme.accentBlue,
                      onTap: () {
                        // Show invitation dialog
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent Activity
              Text('Recent Activity', style: AppTheme.title1),
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
      return LinkedInCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: 16),
              Text(
                'No recent activity',
                style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return LinkedInCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentEntities.length,
        separatorBuilder: (context, index) =>
            Divider(color: AppTheme.borderGrey),
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
              style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              entity.email ?? 'Email non specificata',
              style: AppTheme.body2,
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
                style: AppTheme.caption.copyWith(
                  color: _getStatusColor(entity.status),
                  fontWeight: FontWeight.w600,
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
        return Colors.orange;
      case LegalEntityStatus.approved:
        return Colors.green;
      case LegalEntityStatus.rejected:
        return Colors.red;
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
          Text('User Management', style: AppTheme.headline2),
          const SizedBox(height: 8),
          Text(
            'Manage user accounts and permissions across the platform.',
            style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          LinkedInCard(
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.people, size: 64, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'User Management Coming Soon',
                    style: AppTheme.title1.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Advanced user management features will be available in the next update.',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
          Text('Analytics & Insights', style: AppTheme.headline2),
          const SizedBox(height: 8),
          Text(
            'Track platform performance and user engagement metrics.',
            style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          LinkedInCard(
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.analytics, size: 64, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Analytics Coming Soon',
                    style: AppTheme.title1.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comprehensive analytics and reporting features will be available in the next update.',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Settings', style: AppTheme.headline2),
          const SizedBox(height: 8),
          Text(
            'Configure platform settings and preferences.',
            style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          LinkedInCard(
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.settings, size: 64, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Settings Coming Soon',
                    style: AppTheme.title1.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Advanced platform configuration options will be available in the next update.',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
