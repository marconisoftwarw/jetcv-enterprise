import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/certification_edge_service.dart';
import '../../services/edge_function_service.dart';
import '../../models/legal_entity.dart';
import '../../services/user_type_service.dart';
import '../../providers/auth_provider.dart';
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

  // Dati delle certificazioni
  List<Map<String, dynamic>> _issuedCertifications = [];
  List<Map<String, dynamic>> _draftCertifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Legal entity per l'utente corrente
  String? _userLegalEntityId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCertifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCertifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prima testa la connessione alla Edge Function
      final connectionOk = await CertificationEdgeService.testConnection();

      if (!connectionOk) {
        _loadMockData();
        return;
      }

      // Determina se l'utente è di tipo legal_entity e carica la sua legal entity
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLegalEntityUser =
          authProvider.userType == AppUserType.legalEntity;
      final isAdmin = authProvider.userType == AppUserType.admin;

      if (isLegalEntityUser) {
        print('🏢 User is legal_entity type, loading user legal entity...');
        await _loadUserLegalEntity();
      } else if (isAdmin) {
        print(
          '👑 User is admin, loading all certifications without filters...',
        );
      }

      // Carica certificazioni emesse (status: completed, closed)
      final issuedResult = await CertificationEdgeService.getCertifications(
        status: 'sent',
        idLegalEntity: isLegalEntityUser
            ? _userLegalEntityId
            : null, // Filtra solo per legal_entity
        limit: 50,
        offset: 0,
      );

      // Carica bozze e in corso (status: draft, submitted)
      final draftResult = await CertificationEdgeService.getCertifications(
        status: 'draft',
        idLegalEntity: isLegalEntityUser
            ? _userLegalEntityId
            : null, // Filtra solo per legal_entity
        limit: 50,
        offset: 0,
      );

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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore nel caricamento delle certificazioni: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserLegalEntity() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        print('❌ No current user available');
        return;
      }

      print('🔍 Loading legal entity for user: ${currentUser.idUser}');

      // Solo gli admin vedono tutte le legal entities
      // Tutti gli altri utenti vedono solo la propria legal entity
      final isAdmin = authProvider.userType == AppUserType.admin;
      
      print('🔍 DEBUG: User type: ${authProvider.userType}');
      print('🔍 DEBUG: Is admin: $isAdmin');
      print('🔍 DEBUG: User ID: ${currentUser.idUser}');
      
      final response = isAdmin
          ? await EdgeFunctionService.getAllLegalEntities().timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                print('⏰ Timeout loading all legal entities for admin');
                return null;
              },
            )
          : await EdgeFunctionService.getLegalEntitiesByUser(
              userId: currentUser.idUser,
            ).timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                print('⏰ Timeout loading user legal entity');
                return null;
              },
            );
      
      print('🔍 DEBUG: Method called: ${isAdmin ? "getAllLegalEntities" : "getLegalEntitiesByUser"}');
      print('🔍 DEBUG: Response received: ${response != null ? "Yes" : "No"}');
      
      if (response != null) {
        print('🔍 DEBUG: Response data: $response');
        print('🔍 DEBUG: Response ok: ${response['ok']}');
        if (response['data'] != null) {
          print('🔍 DEBUG: Data length: ${(response['data'] as List).length}');
        }
      }

      if (response != null && response['ok'] == true) {
        final data = response['data'] as List<dynamic>?;
        if (data != null && data.isNotEmpty) {
          final legalEntities = data
              .map((item) => LegalEntity.fromJson(item))
              .toList();

          // Seleziona la prima legal entity (la più recente)
          _userLegalEntityId = legalEntities.first.idLegalEntity;

          print(
            '✅ Loaded legal entity for user: ${legalEntities.first.legalName} (${_userLegalEntityId})',
          );
        } else {
          print('❌ No legal entities found for user');
        }
      } else {
        print('❌ Failed to load legal entities: ${response?['message']}');
      }
    } catch (e) {
      print('❌ Error loading user legal entity: $e');
    }
  }

  void _loadMockData() {
    final mockIssued = [
      {
        'id_certification': 'cert-001',
        'serial_number': 'ABC12-DEF34',
        'status': 'approved',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        'updated_t': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'n_users': 3,
        'id_certification_category': 'tech-skills',
      },
      {
        'id_certification': 'cert-002',
        'serial_number': 'GHI56-JKL78',
        'status': 'closed',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 10))
            .toIso8601String(),
        'updated_t': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'n_users': 2,
        'id_certification_category': 'design-skills',
      },
    ];

    final mockDrafts = [
      {
        'id_certification': 'cert-003',
        'serial_number': 'MNO90-PQR12',
        'status': 'draft',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
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
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1D3A),
                const Color(0xFF2D3561),
                const Color(0xFF3B82F6).withValues(alpha: 0.8),
              ],
            ),
          ),
          child: ClipRRect(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header principale
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dashboard',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(
                                  'Certificatori',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF8B5CF6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Statistiche rapide
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildQuickStat(
                              'Emesse',
                              '${_issuedCertifications.length}',
                              const Color(0xFF10B981),
                              Icons.verified,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickStat(
                              'In Bozza',
                              '${_draftCertifications.length}',
                              const Color(0xFFF59E0B),
                              Icons.edit_document,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickStat(
                              'Totale',
                              '${_issuedCertifications.length + _draftCertifications.length}',
                              const Color(0xFF8B5CF6),
                              Icons.workspace_premium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tab Bar moderna
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withValues(
                          alpha: 0.6,
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(text: 'Certificazioni Emesse'),
                          Tab(text: 'Bozze e In Corso'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF151B3B),
              const Color(0xFF1F2347),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [_buildIssuedCertificationsTab(), _buildDraftsTab()],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateCertificationScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Nuova Certificazione',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildIssuedCertificationsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Caricamento...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.red.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Errore nel caricamento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _loadCertifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Riprova',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: isTablet ? 24 : 16,
        right: isTablet ? 24 : 16,
        top: 20,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Management Cards con layout moderno
          const Text(
            'Gestione Rapida',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Layout asimmetrico per le card
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildModernManagementCard(
                      'Categorie',
                      'Gestisci le categorie\ndi certificazione',
                      Icons.category_rounded,
                      const Color(0xFF3B82F6),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CertificationCategoryManagementScreen(
                                  idLegalEntity: 'placeholder',
                                ),
                          ),
                        );
                      },
                      120,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildModernManagementCard(
                      'Info',
                      'Campi',
                      Icons.info_rounded,
                      const Color(0xFF10B981),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CertificationInformationManagementScreen(
                                  idLegalEntity: 'placeholder',
                                ),
                          ),
                        );
                      },
                      80,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Sezione certificazioni
          Row(
            children: [
              const Text(
                'Certificazioni Emesse',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6).withValues(alpha: 0.2),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_issuedCertifications.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_issuedCertifications.isEmpty)
            _buildModernEmptyState(
              'Nessuna certificazione emessa',
              'Le certificazioni completate appariranno qui',
              Icons.workspace_premium_rounded,
            )
          else
            ..._buildModernCertificationsList(_issuedCertifications, isTablet),
        ],
      ),
    );
  }

  Widget _buildDraftsTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Caricamento...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.red.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Errore nel caricamento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _loadCertifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Riprova',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: isTablet ? 24 : 16,
        right: isTablet ? 24 : 16,
        top: 20,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Bozze e In Corso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      const Color(0xFFEF4444).withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_draftCertifications.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_draftCertifications.isEmpty)
            _buildModernEmptyState(
              'Nessuna bozza disponibile',
              'Le tue bozze e certificazioni in corso appariranno qui',
              Icons.edit_document,
            )
          else
            ..._buildModernCertificationsList(_draftCertifications, isTablet),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'sent':
        return 'Inviata';
      case 'closed':
        return 'Chiusa';
      case 'draft':
        return 'Bozza';
      default:
        return 'Sconosciuto';
    }
  }

  Widget _buildQuickStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernManagementCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    double height,
  ) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildModernCertificationsList(
    List<Map<String, dynamic>> certifications,
    bool isTablet,
  ) {
    return certifications.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> cert = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: _buildModernCertificationCard(cert, isTablet, index),
      );
    }).toList();
  }

  Widget _buildModernCertificationCard(
    Map<String, dynamic> cert,
    bool isTablet,
    int index,
  ) {
    final status = cert['status'] ?? 'draft';
    final statusColor = _getModernStatusColor(status);
    final statusText = _getStatusText(status);
    final createdAt =
        DateTime.tryParse(cert['created_at'] ?? '') ?? DateTime.now();
    final nUsers = cert['n_users'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to certification details
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Certificazione ${cert['serial_number'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cert['id_certification_category'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: statusColor.withValues(alpha: 0.2),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
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
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Utenti',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$nUsers',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Creazione',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getModernStatusColor(String status) {
    switch (status) {
      case 'sent':
        return const Color(0xFF10B981);
      case 'closed':
        return const Color(0xFF6B7280);
      case 'draft':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}
