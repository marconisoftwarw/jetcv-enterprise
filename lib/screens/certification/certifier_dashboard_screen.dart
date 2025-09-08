import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../l10n/app_localizations.dart';
import '../../services/certification_edge_service.dart';
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

  // Dati delle certificazioni
  List<Map<String, dynamic>> _issuedCertifications = [];
  List<Map<String, dynamic>> _draftCertifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🏁 CertifierDashboardScreen initState called');
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    print('📞 Calling _loadCertifications from initState');
    _loadCertifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCertifications() async {
    print('🚀 _loadCertifications called!');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prima testa la connessione alla Edge Function
      print('🧪 Testing Edge Function connection...');
      final connectionOk = await CertificationEdgeService.testConnection();
      
      if (!connectionOk) {
        print('⚠️ Edge Function not available, using mock data for testing');
        _loadMockData();
        return;
      }

      print('✅ Edge Function connection OK, loading certifications...');

      // Carica certificazioni emesse (status: approved, closed)
      print('📋 Loading issued certifications...');
      final issuedResult = await CertificationEdgeService.getCertifications(
        status: 'approved',
        limit: 50,
        offset: 0,
      );

      // Carica bozze e in corso (status: draft, submitted)
      print('📝 Loading draft certifications...');
      final draftResult = await CertificationEdgeService.getCertifications(
        status: 'draft',
        limit: 50,
        offset: 0,
      );

      print('📊 Issued certifications: ${issuedResult?['data']?.length ?? 0}');
      print('📝 Draft certifications: ${draftResult?['data']?.length ?? 0}');

      if (mounted) {
        setState(() {
          _issuedCertifications = List<Map<String, dynamic>>.from(
            issuedResult?['data'] ?? [],
          );
          _draftCertifications = List<Map<String, dynamic>>.from(
            draftResult?['data'] ?? [],
          );
          _isLoading = false;
        });
        print('✅ State updated with ${_issuedCertifications.length} issued and ${_draftCertifications.length} draft certifications');
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
    print('📝 Loading mock data for testing...');
    
    final mockIssued = [
      {
        'id_certification': 'cert-001',
        'serial_number': 'ABC12-DEF34',
        'status': 'approved',
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'updated_t': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'n_users': 3,
        'id_certification_category': 'tech-skills',
      },
      {
        'id_certification': 'cert-002',
        'serial_number': 'GHI56-JKL78',
        'status': 'closed',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'updated_t': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'n_users': 2,
        'id_certification_category': 'design-skills',
      },
    ];

    final mockDrafts = [
      {
        'id_certification': 'cert-003',
        'serial_number': 'MNO90-PQR12',
        'status': 'draft',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'n_users': 1,
        'id_certification_category': 'soft-skills',
      },
    ];

    if (mounted) {
      setState(() {
        _issuedCertifications = mockIssued;
        _draftCertifications = mockDrafts;
        _isLoading = false;
        _errorMessage = null;
      });
    }
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
                  floatingActionButton: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          print('🧪 Manual test button pressed');
                          _loadCertifications();
                        },
                        backgroundColor: AppTheme.warningOrange,
                        foregroundColor: AppTheme.pureWhite,
                        elevation: 8,
                        heroTag: "test",
                        child: const Icon(Icons.refresh),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.extended(
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
                    ],
                  ),
    );
  }

  Widget _buildIssuedCertificationsTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

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
                        builder: (context) =>
                            const CertificationCategoryManagementScreen(
                              idLegalEntity:
                                  'placeholder', // TODO: Get from context
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
                        builder: (context) =>
                            const CertificationInformationManagementScreen(
                              idLegalEntity:
                                  'placeholder', // TODO: Get from context
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
            'Certificazioni Emesse (${_issuedCertifications.length})',
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          if (_issuedCertifications.isEmpty)
            _buildEmptyState(
              'Nessuna certificazione emessa',
              'Le certificazioni completate appariranno qui',
            )
          else
            ..._buildCertificationsList(_issuedCertifications, isTablet),
        ],
      ),
    );
  }

  List<Widget> _buildCertificationsList(
    List<Map<String, dynamic>> certifications,
    bool isTablet,
  ) {
    return certifications.map((cert) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildCertificationCard(cert, isTablet),
      );
    }).toList();
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
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
                child: Icon(icon, color: color, size: isTablet ? 24 : 20),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

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

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bozze e In Corso (${_draftCertifications.length})',
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          if (_draftCertifications.isEmpty)
            _buildEmptyState(
              'Nessuna bozza disponibile',
              'Le tue bozze e certificazioni in corso appariranno qui',
            )
          else
            ..._buildCertificationsList(_draftCertifications, isTablet),
        ],
      ),
    );
  }

  Widget _buildCertificationCard(Map<String, dynamic> cert, bool isTablet) {
    final status = cert['status'] ?? 'draft';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final createdAt =
        DateTime.tryParse(cert['created_at'] ?? '') ?? DateTime.now();
    final nUsers = cert['n_users'] ?? 0;

    return LinkedInCard(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to certification details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isTablet ? 60 : 50,
                    height: isTablet ? 60 : 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: AppTheme.primaryBlue,
                      size: isTablet ? 30 : 24,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Certificazione ${cert['serial_number'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
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
                        SizedBox(height: isTablet ? 6 : 4),
                        Text(
                          'Categoria: ${cert['id_certification_category'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        Text(
                          'Utenti: $nUsers',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
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
              SizedBox(height: isTablet ? 16 : 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Creata: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (cert['updated_t'] != null) ...[
                    Icon(Icons.update, size: 16, color: AppTheme.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      'Aggiornata: ${DateTime.tryParse(cert['updated_t'])?.day}/${DateTime.tryParse(cert['updated_t'])?.month}/${DateTime.tryParse(cert['updated_t'])?.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'closed':
        return AppTheme.successGreen;
      case 'submitted':
        return AppTheme.warningOrange;
      case 'draft':
        return AppTheme.textSecondary;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approvata';
      case 'closed':
        return 'Chiusa';
      case 'submitted':
        return 'Inviata';
      case 'draft':
        return 'Bozza';
      case 'rejected':
        return 'Rifiutata';
      default:
        return 'Sconosciuto';
    }
  }
}
