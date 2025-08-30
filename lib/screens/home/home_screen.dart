import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';

import '../certification/create_certification_screen.dart';
import '../certification/certification_list_screen.dart';
import '../admin/legal_entity_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Controllo sicuro per verificare se l'utente è admin basato sul database
        final isAdmin = authProvider.isCurrentUserAdmin;

        return Scaffold(
          body: Row(
            children: [
              // Navigation Rail
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: _buildNavigationDestinations(isAdmin),
              ),

              // Main Content
              Expanded(child: _buildContent(isAdmin)),
            ],
          ),
        );
      },
    );
  }

  List<NavigationRailDestination> _buildNavigationDestinations(bool isAdmin) {
    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.business),
        label: Text('My Company'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.verified_user),
        label: Text('Certifications'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person),
        label: Text('Profile'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.settings),
        label: Text('Settings'),
      ),
    ];

    // Aggiungi menu admin se l'utente è amministratore
    if (isAdmin) {
      destinations.add(
        const NavigationRailDestination(
          icon: Icon(Icons.admin_panel_settings),
          label: Text('Legal Entities'),
        ),
      );
    }

    return destinations;
  }

  Widget _buildContent(bool isAdmin) {
    // Se l'utente non è admin, gli indici rimangono gli stessi
    if (!isAdmin) {
      switch (_selectedIndex) {
        case 0:
          return const _DashboardContent();
        case 1:
          return const CertificationListScreen();
        case 2:
          return const Center(child: Text('Certificazioni'));
        case 3:
          return const Center(child: Text('Profilo'));
        case 4:
          return const Center(child: Text('Impostazioni'));
        default:
          return const _DashboardContent();
      }
    }

    // Se l'utente è admin, l'ultimo indice (5) è per il pannello admin
    switch (_selectedIndex) {
      case 0:
        return const _DashboardContent();
      case 1:
        return const CertificationListScreen();
      case 2:
        return const Center(child: Text('Certificazioni'));
      case 3:
        return const Center(child: Text('Profilo'));
      case 4:
        return const Center(child: Text('Impostazioni'));
      case 5:
        return const LegalEntityManagementScreen();
      default:
        return const _DashboardContent();
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Benvenuto, ${user.firstName}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Quick actions
              _buildQuickActionsGrid(context),

              const SizedBox(height: 32),

              // Recent activity
              Text(
                'Attività Recente',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildRecentActivityList(),
            ],
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
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildQuickActionCard(
          context,
          'Complete Profile',
          'Fill in missing information',
          Icons.person_add,
          () {
            // Navigate to profile completion
          },
        ),
        _buildQuickActionCard(
          context,
          'Company Setup',
          'Configure your business',
          Icons.business,
          () {
            // Navigate to company setup
          },
        ),
        _buildQuickActionCard(
          context,
          'Get Certified',
          'Start certification process',
          Icons.verified_user,
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
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Color(AppConfig.primaryColorValue)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  'Nessuna attività recente',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'La tua attività apparirà qui una volta che inizierai a usare la piattaforma.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
