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
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/appbar_language_dropdown.dart';
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
  TabController? _tabController;
  int _selectedTabIndex = 0;

  // Dati delle certificazioni
  List<Map<String, dynamic>> _draftCertifications = [];
  List<Map<String, dynamic>> _sentCertifications = [];
  List<Map<String, dynamic>> _closedCertifications = [];
  bool _isLoading = false;
  Map<String, String> _categoryNames = {};
  Map<String, String> _locationNames = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🏁 CertificationListScreen initState called');

    try {
      _tabController = TabController(length: 2, vsync: this);
      _tabController!.addListener(() {
        if (mounted &&
            _tabController != null &&
            _tabController!.length > 0 &&
            _tabController!.index >= 0 &&
            _tabController!.index < _tabController!.length) {
          setState(() {
            _selectedTabIndex = _tabController!.index;
          });
        }
      });
      print('📞 CertificationListScreen TabController ready');
      _loadCertifications();
    } catch (e) {
      print('❌ Error initializing TabController: $e');
      _errorMessage = 'Error initializing interface: $e';
    }
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

      // Carica certificazioni inviate (status: sent)
      print('📤 Loading sent certifications...');
      final sentResult = await CertificationServiceV2.getCertifications(
        status: 'sent',
        limit: 50,
        offset: 0,
      );

      // Carica certificazioni chiuse (status: closed)
      print('🔒 Loading closed certifications...');
      final closedResult = await CertificationServiceV2.getCertifications(
        status: 'closed',
        limit: 50,
        offset: 0,
      );

      print('📝 Draft certifications: ${draftResult?['data']?.length ?? 0}');
      print('📤 Sent certifications: ${sentResult?['data']?.length ?? 0}');
      print('🔒 Closed certifications: ${closedResult?['data']?.length ?? 0}');

      if (mounted) {
        setState(() {
          _draftCertifications = List<Map<String, dynamic>>.from(
            draftResult?['data'] ?? [],
          );
          _sentCertifications = List<Map<String, dynamic>>.from(
            sentResult?['data'] ?? [],
          );
          _closedCertifications = List<Map<String, dynamic>>.from(
            closedResult?['data'] ?? [],
          );
          _isLoading = false;
        });
        print(
          '✅ State updated with ${_draftCertifications.length} draft, ${_sentCertifications.length} sent, ${_closedCertifications.length} closed certifications',
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

    final mockSent = [
      {
        'id_certification': 'cert-003',
        'serial_number': 'MNO90-PQR12',
        'status': 'sent',
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 6))
            .toIso8601String(),
        'n_users': 2,
        'id_certification_category': 'soft-skills',
      },
    ];

    final mockClosed = [
      {
        'id_certification': 'cert-004',
        'serial_number': 'STU34-VWX56',
        'status': 'closed',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
        'n_users': 1,
        'id_certification_category': 'leadership',
      },
    ];

    if (mounted) {
      setState(() {
        _draftCertifications = mockDrafts;
        _sentCertifications = mockSent;
        _closedCertifications = mockClosed;
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    if (_tabController != null) {
      _tabController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 CertificationListScreen build called');
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    // Se c'è un errore di inizializzazione, mostralo
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.pureWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Errore di inizializzazione',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  initState();
                },
                child: Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    // Se il TabController non è ancora inizializzato, mostra un loading
    if (_tabController == null || _tabController!.length == 0) {
      return Scaffold(
        backgroundColor: AppTheme.pureWhite,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: CustomScrollView(
        slivers: [
          // Header stile Airbnb
          _buildAirbnbHeader(l10n, isTablet),

          // Filtri/Tabs
          _buildFilterTabs(l10n),

          // Contenuto principale
          _buildMainContent(l10n, isTablet),
        ],
      ),
    );
  }

  Widget _buildAirbnbHeader(AppLocalizations l10n, bool isTablet) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false, // Rimuove il pulsante di back
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isTablet ? 24 : 16,
          right: isTablet ? 24 : 16,
          bottom: 12,
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.getString('certifications'),
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 24 : 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.getString('manage_certifications'),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.currentUser;
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user?.initials ?? 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    // Se il TabController non è inizializzato, non mostrare i tab
    if (_tabController == null || _tabController!.length == 0) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Pulsante Nuova Certificazione - Stile LinkedIn
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateCertificationScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.add, size: 20),
                label: Text(
                  l10n.getString('create_new_certification'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tab Navigation - Stile LinkedIn
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLinkedInTabButton(
                      l10n.getString('sent_certifications'),
                      _tabController!.length > 0 && _tabController!.index == 0,
                      () {
                        if (_tabController != null &&
                            _tabController!.length > 0) {
                          _tabController!.animateTo(0);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildLinkedInTabButton(
                      l10n.getString('closed_certifications'),
                      _tabController!.length > 1 && _tabController!.index == 1,
                      () {
                        if (_tabController != null &&
                            _tabController!.length > 1) {
                          _tabController!.animateTo(1);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedInTabButton(
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(AppLocalizations l10n, bool isTablet) {
    // Se il TabController non è inizializzato, mostra un loading
    if (_tabController == null || _tabController!.length == 0) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      );
    }

    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController!,
        children: [_buildSentTab(), _buildClosedTab()],
      ),
    );
  }

  Widget _buildCertificationCard(
    Map<String, dynamic> cert,
    AppLocalizations l10n,
    bool isTablet, {
    bool forceClosedStatus = false,
  }) {
    final status = cert['status'] ?? 'draft';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status, forceClosed: forceClosedStatus);
    final createdAt =
        DateTime.tryParse(cert['created_at'] ?? '') ?? DateTime.now();
    final sentAt = cert['sent_at'] != null
        ? DateTime.tryParse(cert['sent_at'])
        : null;
    final nUsers = cert['n_users'] ?? 0;
    final serialNumber = cert['serial_number'] ?? 'N/A';
    final categoryId = cert['id_certification_category'] ?? '';
    final locationId = cert['id_location'] ?? '';
    final categoryName =
        _categoryNames[categoryId] ?? l10n.getString('unknown_category');
    final locationName = _locationNames[locationId] ?? 'Luogo sconosciuto';

    return EnterpriseCard(
      isHoverable: true,
      onTap: () {
        Navigator.of(context).pushNamed(
          '/certification-detail',
          arguments: {
            'certificationId': cert['id_certification'],
            'certificationData': cert,
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: AppTheme.pureWhite,
                  size: 28,
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
                            '$categoryName - $serialNumber',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              statusText,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: AppTheme.textGray),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$nUsers ${l10n.getString('participants')}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textGray),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textGray,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textGray),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.textGray, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGray, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.textGray),
                const SizedBox(width: 8),
                Text(
                  'Creata: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (sentAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.send, size: 16, color: AppTheme.textGray),
                  const SizedBox(width: 8),
                  Text(
                    'Inviata: ${sentAt.day}/${sentAt.month}/${sentAt.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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

  String _getStatusText(String status, {bool forceClosed = false}) {
    if (forceClosed) {
      return 'Chiusa';
    }

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

  Widget _buildSentTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_sentCertifications.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCertificationsGrid(_sentCertifications, isTablet);
  }

  Widget _buildClosedTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Combine draft and closed certifications
    final allClosedCertifications = [
      ..._draftCertifications,
      ..._closedCertifications,
    ];

    if (allClosedCertifications.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCertificationsGrid(
      allClosedCertifications,
      isTablet,
      forceClosedStatus: true,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryBlue),
          const SizedBox(height: 16),
          Text(
            'Caricamento certificazioni...',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderGray),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              'Errore nel caricamento',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadCertifications,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Riprova',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 32,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.getString('no_certifications_found'),
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.getString('certifications_will_appear_here'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCertificationScreen(),
                  ),
                );
              },
              icon: Icon(Icons.add, size: 18),
              label: Text(
                l10n.getString('create_new_certification'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationsGrid(
    List<Map<String, dynamic>> certifications,
    bool isTablet, {
    bool forceClosedStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.separated(
        itemCount: certifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final certification = certifications[index];
          return _buildAirbnbCard(
            certification,
            forceClosedStatus: forceClosedStatus,
          );
        },
      ),
    );
  }

  Widget _buildAirbnbCard(
    Map<String, dynamic> cert, {
    bool forceClosedStatus = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final status = cert['status'] ?? 'draft';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status, forceClosed: forceClosedStatus);
    final createdAt =
        DateTime.tryParse(cert['created_at'] ?? '') ?? DateTime.now();
    final nUsers = cert['n_users'] ?? 0;
    final serialNumber = cert['serial_number'] ?? 'N/A';
    final categoryId = cert['id_certification_category'] ?? '';
    final categoryName =
        _categoryNames[categoryId] ?? l10n.getString('unknown_category');
    final title = cert['title'] ?? cert['name'] ?? 'Titolo non disponibile';
    final description = cert['description'] ?? l10n.getString('no_description');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icona categoria - Stile LinkedIn
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.workspace_premium,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Contenuto principale
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tipologia
                  Text(
                    l10n.getString('certification_type'),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    categoryName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Titolo
                  Text(
                    l10n.getString('certification_title'),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Descrizione
                  Text(
                    l10n.getString('certification_description'),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Informazioni aggiuntive
                  Row(
                    children: [
                      Icon(Icons.tag, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.getString('series')}: $serialNumber',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$nUsers ${l10n.getString('participants')}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
