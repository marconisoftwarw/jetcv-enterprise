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
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.pureWhite,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isTablet ? 120 : 80,
          right: isTablet ? 120 : 80,
          bottom: 16,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le tue certificazioni',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gestisci e crea nuove certificazioni',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              return CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  user?.initials ?? 'U',
                  style: TextStyle(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                'Bozze e In corso',
                _tabController!.length > 0 && _tabController!.index == 0,
                () {
                  if (_tabController != null && _tabController!.length > 0) {
                    _tabController!.animateTo(0);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTabButton(
                'Emesse',
                _tabController!.length > 1 && _tabController!.index == 1,
                () {
                  if (_tabController != null && _tabController!.length > 1) {
                    _tabController!.animateTo(1);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            // Pulsante Nuova Certificazione
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCertificationScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.successGreen,
                      AppTheme.successGreen.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppTheme.pureWhite, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Nuova',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.pureWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isSelected ? AppTheme.pureWhite : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
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
        children: [_buildDraftsTab(), _buildSentTab()],
      ),
    );
  }

  Widget _buildDraftsTab() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_draftCertifications.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCertificationsGrid(_draftCertifications, isTablet);
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
                            '$nUsers utenti',
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 40,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nessuna certificazione',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le certificazioni in bozza e in corso appariranno qui',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCertificationScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.successGreen,
                      AppTheme.successGreen.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Crea Certificazione',
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

  Widget _buildCertificationsGrid(
    List<Map<String, dynamic>> certifications,
    bool isTablet,
  ) {
    final crossAxisCount = isTablet ? 2 : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 1.2 : 1.0,
        ),
        itemCount: certifications.length,
        itemBuilder: (context, index) {
          final certification = certifications[index];
          return _buildAirbnbCard(certification);
        },
      ),
    );
  }

  Widget _buildAirbnbCard(Map<String, dynamic> cert) {
    final status = cert['status'] ?? 'draft';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final createdAt =
        DateTime.tryParse(cert['created_at'] ?? '') ?? DateTime.now();
    final nUsers = cert['n_users'] ?? 0;
    final serialNumber = cert['serial_number'] ?? 'N/A';
    final categoryId = cert['id_certification_category'] ?? '';
    final categoryName = _categoryNames[categoryId] ?? 'Categoria sconosciuta';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/certification-detail',
          arguments: {
            'certificationId': cert['id_certification'],
            'certificationData': cert,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.more_vert, color: AppTheme.textGray, size: 20),
                ],
              ),
            ),

            // Contenuto principale
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Serie: $serialNumber',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nUsers} partecipanti',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                    ),
                  ],
                ),
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
