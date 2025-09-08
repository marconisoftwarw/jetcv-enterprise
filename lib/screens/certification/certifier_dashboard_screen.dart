import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../l10n/app_localizations.dart';
import 'create_certification_screen.dart';
import 'certification_category_management_screen.dart';
import 'certification_information_management_screen.dart';

class CertifierDashboardScreen extends StatefulWidget {
  const CertifierDashboardScreen({super.key});

  @override
  State<CertifierDashboardScreen> createState() =>
      _CertifierDashboardScreenState();
}

class _CertifierDashboardScreenState extends State<CertifierDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          'Dashboard Certificatori',
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlack,
          labelColor: AppTheme.primaryBlack,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Certificazioni Emesse'),
            Tab(text: 'Bozze e In Corso'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildIssuedCertificationsTab(), _buildDraftsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCertificationScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.pureWhite,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('Nuova Certificazione'),
      ),
    );
  }

  Widget _buildIssuedCertificationsTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Management Cards
          Text(
            'Gestione',
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          
          Row(
            children: [
              Expanded(
                child: _buildManagementCard(
                  'Categorie',
                  'Gestisci le categorie di certificazione',
                  Icons.category_outlined,
                  AppTheme.primaryBlue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CertificationCategoryManagementScreen(
                          idLegalEntity: 'placeholder', // TODO: Get from context
                        ),
                      ),
                    );
                  },
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: _buildManagementCard(
                  'Informazioni',
                  'Gestisci i campi di informazione',
                  Icons.info_outline,
                  AppTheme.successGreen,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CertificationInformationManagementScreen(
                          idLegalEntity: 'placeholder', // TODO: Get from context
                        ),
                      ),
                    );
                  },
                  isTablet,
                ),
              ),
            ],
          ),
          
          SizedBox(height: isTablet ? 32 : 24),
          
          // Certifications List
          Text(
            'Certificazioni Emesse',
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          
          ..._buildCertificationsList(isTablet),
        ],
      ),
    );
  }

  List<Widget> _buildCertificationsList(bool isTablet) {
    final certifications = [
      {
        'title': 'Certificazione Flutter Developer',
        'organization': 'TechCorp Academy',
        'description': 'Certificazione avanzata per sviluppatori Flutter',
        'status': 'Completata',
        'date': '22/7/2025',
        'certifiedCount': 3,
        'image': 'https://via.placeholder.com/80',
        'avatars': [
          'https://via.placeholder.com/32',
          'https://via.placeholder.com/32',
          'https://via.placeholder.com/32',
        ],
      },
      {
        'title': 'Certificazione UX/UI Design',
        'organization': 'Design Institute',
        'description': 'Certificazione per designer digitali',
        'status': 'Completata',
        'date': '7/7/2025',
        'certifiedCount': 2,
        'image': 'https://via.placeholder.com/80',
        'avatars': [
          'https://via.placeholder.com/32',
          'https://via.placeholder.com/32',
        ],
      },
    ];

    return certifications.map((cert) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildCertificationCard(cert),
      );
    }).toList();
  }

  Widget _buildManagementCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isTablet,
  ) {
    return LinkedInCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(Icons.edit_note, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Nessuna bozza disponibile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Le tue bozze e certificazioni in corso appariranno qui',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationCard(Map<String, dynamic> cert) {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(cert['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cert['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cert['status'],
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cert['organization'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cert['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Certificati:',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              ...(cert['avatars'] as List<String>).map((avatar) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(avatar),
                  ),
                );
              }).toList(),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cert['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
