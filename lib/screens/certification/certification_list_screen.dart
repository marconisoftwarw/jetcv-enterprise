import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/certification.dart';
import '../../services/certification_service.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';
import 'create_certification_screen.dart';

class CertificationListScreen extends StatefulWidget {
  const CertificationListScreen({super.key});

  @override
  State<CertificationListScreen> createState() =>
      _CertificationListScreenState();
}

class _CertificationListScreenState extends State<CertificationListScreen>
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
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          l10n.getString('certifier_dashboard'),
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: isTablet ? 24 : 20,
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
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 16 : 14,
          ),
          tabs: [
            Tab(text: l10n.getString('issued_certifications')),
            Tab(text: l10n.getString('drafts_in_progress')),
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
        label: Text(l10n.getString('new_certification')),
      ),
    );
  }

  Widget _buildIssuedCertificationsTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    final certifications = [
      {
        'title': 'Certificazione Flutter Developer',
        'organization': 'TechCorp Academy',
              'description': 'Certificazione avanzata ',
        'status': l10n.getString('completed'),
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
        'description': 'Certificazione avanzata ',
        'status': l10n.getString('completed'),
        'date': '7/7/2025',
        'certifiedCount': 2,
        'image': 'https://via.placeholder.com/80',
        'avatars': [
          'https://via.placeholder.com/32',
          'https://via.placeholder.com/32',
        ],
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 2 : 1;
        final childAspectRatio = isDesktop ? 2.5 : 1.0;

        return GridView.builder(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: certifications.length,
          itemBuilder: (context, index) {
            final cert = certifications[index];
            return _buildCertificationCard(cert, l10n, isTablet);
          },
        );
      },
    );
  }

  Widget _buildDraftsTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
              Icons.edit_note,
              size: isTablet ? 80 : 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: isTablet ? 24 : 16),
                        Text(
              l10n.getString('no_drafts_available'),
                          style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlack,
                          ),
              textAlign: TextAlign.center,
                        ),
            SizedBox(height: isTablet ? 12 : 8),
                        Text(
              l10n.getString('drafts_will_appear_here'),
                          style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: isTablet ? 16 : 14,
              ),
              textAlign: TextAlign.center,
                        ),
                      ],
                    ),
      ),
    );
  }

  Widget _buildCertificationCard(
    Map<String, dynamic> cert,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return LinkedInCard(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 12 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: isTablet ? 50 : 40,
                  height: isTablet ? 50 : 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(cert['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
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
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlack,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 16 : 12,
                              vertical: isTablet ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cert['status'],
                              style: TextStyle(
                                color: AppTheme.successGreen,
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        cert['organization'],
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        cert['description'],
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: AppTheme.primaryBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: isTablet ? 20 : 16,
                ),
              ],
            ),
            SizedBox(height: isTablet ? 8 : 4),
            Row(
              children: [
                Text(
                  '${l10n.getString('certified')}:',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: isTablet ? 8 : 6),
                ...(cert['avatars'] as List<String>).map((avatar) {
                  return Padding(
                    padding: EdgeInsets.only(right: isTablet ? 2 : 1),
                    child: CircleAvatar(
                      radius: isTablet ? 10 : 8,
                      backgroundImage: NetworkImage(avatar),
                    ),
                  );
                }).toList(),
                const Spacer(),
              Row(
                children: [
                    Icon(
                      Icons.calendar_today,
                      size: isTablet ? 14 : 12,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(width: isTablet ? 2 : 1),
                    Text(
                      cert['date'],
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
