import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/certification.dart';
import '../../services/certification_service.dart';
import '../../services/certification_edge_service.dart';
import '../../services/certification_service_v2.dart';
import '../../services/certification_category_service.dart';
import '../../services/location_service.dart';
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

  // Dati delle certificazioni
  List<Map<String, dynamic>> _draftCertifications = [];
  List<Map<String, dynamic>> _pendingCertifications = [];
  bool _isLoading = false;
  Map<String, String> _categoryNames = {};
  Map<String, String> _locationNames = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🏁 CertificationListScreen initState called');
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    print('📞 CertificationListScreen ready');
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    print('🚀 _loadCertifications called in CertificationListScreen!');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Carica i nomi delle categorie e luoghi in parallelo
      print('📋 Loading category names...');
      _categoryNames = await CertificationCategoryService.getCategoryNames();
      _locationNames = {}; // Non più necessario
      print(
        '📋 Loaded ${_categoryNames.length} categories and ${_locationNames.length} locations',
      );

      // Prima testa la connessione alla Edge Function
      print('🧪 Testing certifications Edge Function connection...');
      final connectionOk = await CertificationServiceV2.testConnection();

      if (!connectionOk) {
        print('⚠️ Edge Function not available, using mock data for testing');
        _loadMockData();
        return;
      }

      print('✅ Edge Function connection OK, loading certifications...');

      // Carica certificazioni in bozza (status: draft)
      print('📝 Loading draft certifications...');
      final draftResult = await CertificationServiceV2.getCertifications(
        status: 'draft',
        limit: 50,
        offset: 0,
      );

      print('📝 Draft certifications: ${draftResult?['data']?.length ?? 0}');

      // Usa solo le certificazioni draft (pending non esiste nell'enum certification_status)
      final allDraftAndPending = draftResult?['data'] ?? [];

      if (mounted) {
        setState(() {
          _draftCertifications = List<Map<String, dynamic>>.from(
            allDraftAndPending,
          );
          _pendingCertifications = []; // Non più necessario
          _isLoading = false;
        });
        print(
          '✅ State updated with ${_draftCertifications.length} draft certifications',
        );
      }
    } catch (e) {
      print('💥 Error loading certifications: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore nel caricamento delle certificazioni: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _loadMockData() {
    print('📝 Loading mock data for testing in CertificationListScreen...');

    final mockDrafts = [
      {
        'id_certification': 'cert-001',
        'serial_number': 'ABC12-DEF34',
        'status': 'draft',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'n_users': 1,
        'id_certification_category': 'tech-skills',
      },
      {
        'id_certification': 'cert-002',
        'serial_number': 'GHI56-JKL78',
        'status': 'draft',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'n_users': 1,
        'id_certification_category': 'design-skills',
      },
    ];

    final mockPending = [
      {
        'id_certification': 'cert-003',
        'serial_number': 'MNO90-PQR12',
        'status': 'pending',
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 6))
            .toIso8601String(),
        'n_users': 2,
        'id_certification_category': 'soft-skills',
      },
    ];

    // Combina draft e pending in un unico array
    final allDraftAndPending = [...mockDrafts, ...mockPending];

    if (mounted) {
      setState(() {
        _draftCertifications = allDraftAndPending;
        _pendingCertifications = []; // Non più necessario
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 CertificationListScreen build called');
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
          tabs: [Tab(text: 'Bozze e In corso')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDraftsTab()],
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

  Widget _buildDraftsTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text('Errore nel caricamento', style: AppTheme.title2),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTheme.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCertifications,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    if (_draftCertifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Nessuna certificazione',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le certificazioni in bozza e in corso appariranno qui',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Text(
            'Bozze e In corso (${_draftCertifications.length})',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
            itemCount: _draftCertifications.length,
            itemBuilder: (context, index) {
              final cert = _draftCertifications[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildCertificationCard(cert, l10n, isTablet),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationCard(
    Map<String, dynamic> cert,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final status = cert['status'] ?? 'draft';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final createdAt =
        DateTime.tryParse(cert['created_at'] ?? '') ?? DateTime.now();
    final sentAt = cert['sent_at'] != null
        ? DateTime.tryParse(cert['sent_at'])
        : null;
    final nUsers = cert['n_users'] ?? 0;
    final serialNumber = cert['serial_number'] ?? 'N/A';
    final categoryId = cert['id_certification_category'] ?? '';
    final locationId = cert['id_location'] ?? '';
    final categoryName = _categoryNames[categoryId] ?? 'Categoria sconosciuta';
    final locationName = _locationNames[locationId] ?? 'Luogo sconosciuto';

    return LinkedInCard(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to certification details
        },
        borderRadius: BorderRadius.circular(12),
        child: ClipRect(
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
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: AppTheme.primaryBlue,
                        size: isTablet ? 24 : 20,
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
                                  '$categoryName - $serialNumber',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
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
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 2 : 1),
                          Text(
                            'Utenti: $nUsers • Luogo: $locationName',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: isTablet ? 2 : 1),
                          Text(
                            'Status: $statusText',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
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
                SizedBox(height: isTablet ? 8 : 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Creata: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (sentAt != null) ...[
                  SizedBox(height: isTablet ? 2 : 1),
                  Row(
                    children: [
                      Icon(Icons.send, size: 16, color: AppTheme.textSecondary),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Inviata: ${sentAt.day}/${sentAt.month}/${sentAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sent':
        return AppTheme.successGreen;
      case 'closed':
        return AppTheme.textSecondary;
      case 'draft':
        return AppTheme.warningOrange;
      case 'pending':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'sent':
        return 'Inviata';
      case 'closed':
        return 'Chiusa';
      case 'draft':
        return 'Bozza';
      case 'pending':
        return 'In corso';
      default:
        return 'Sconosciuto';
    }
  }
}
