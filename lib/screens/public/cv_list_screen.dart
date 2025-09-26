import 'package:flutter/material.dart';
import '../../models/cv.dart';
import '../../services/cv_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_text_field.dart';

class CVListScreen extends StatefulWidget {
  const CVListScreen({super.key});

  @override
  State<CVListScreen> createState() => _CVListScreenState();
}

class _CVListScreenState extends State<CVListScreen> {
  final CVService _cvService = CVService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<CV> _cvs = [];
  List<CV> _filteredCVs = [];
  bool _isLoading = true;
  bool _showVerifiedOnly = false;
  Map<String, dynamic> _stats = {};

  // String _selectedLocation = '';
  String _selectedSortBy = 'recent';

  @override
  void initState() {
    super.initState();
    _loadCVs();
    _loadStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCVs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('CVListScreen: Iniziando caricamento CV...');
      final cvs = await _cvService.getPublicCVs(
        q: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        city: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        orderBy: _selectedSortBy == 'name'
            ? 'lastName'
            : _selectedSortBy == 'location'
            ? 'city'
            : _selectedSortBy == 'verified'
            ? 'updatedAt'
            : 'createdAt',
        orderDir: _selectedSortBy == 'name' || _selectedSortBy == 'location'
            ? 'asc'
            : 'desc',
        limit: 100,
        offset: 0,
      );
      print('CVListScreen: CV caricati dal servizio: ${cvs.length}');

      setState(() {
        _cvs = cvs;
        _filteredCVs = cvs;
        _isLoading = false;
      });

      print(
        'CVListScreen: Stato aggiornato - CV: ${_cvs.length}, Filtrati: ${_filteredCVs.length}',
      );
    } catch (e) {
      print('CVListScreen: Errore nel caricamento dei CV: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Errore nel caricamento dei CV: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _cvService.getCVStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _filterCVs() async {
    await _loadCVs();
  }

  void _sortCVs(List<CV> cvs) {
    switch (_selectedSortBy) {
      case 'recent':
        cvs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
        cvs.sort((a, b) => a.displayName.compareTo(b.displayName));
        break;
      case 'location':
        cvs.sort((a, b) => a.displayLocation.compareTo(b.displayLocation));
        break;
      case 'verified':
        cvs.sort((a, b) {
          if (a.isVerified == b.isVerified) {
            return b.createdAt.compareTo(a.createdAt);
          }
          return a.isVerified ? -1 : 1;
        });
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchController.text.trim().isNotEmpty ||
        _locationController.text.trim().isNotEmpty ||
        _showVerifiedOnly ||
        _selectedSortBy != 'recent';
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _showVerifiedOnly = false;
      _selectedSortBy = 'recent';
    });
    _filterCVs();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = !isDesktop && !isTablet;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Modern Hero Section
          SliverAppBar(
            expandedHeight: isMobile ? 200 : (isDesktop ? 300 : 250),
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0A0E27),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              background: _buildModernHeroSection(
                isDesktop,
                isTablet,
                isMobile,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          // Search and Filters Section
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(isDesktop, isTablet, isMobile),
          ),

          // CV List Section
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _filteredCVs.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : _buildCVListSliver(isDesktop, isTablet, isMobile),
        ],
      ),
    );
  }

  Widget _buildModernHeroSection(bool isDesktop, bool isTablet, bool isMobile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1A1F3A),
            Color(0xFF2D1B69),
            Color(0xFF6366F1),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated particles background
          _buildParticleBackground(),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isDesktop ? 80 : 40),
                vertical: isMobile ? 20 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Registro Pubblico',
                          style: AppTheme.title1.copyWith(
                            color: Colors.white,
                            fontSize: isMobile ? 24 : (isDesktop ? 32 : 28),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 20 : 30),

                  // Stats and description
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scopri i migliori talenti',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isMobile ? 16 : (isDesktop ? 20 : 18),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Trova professionisti verificati e competenti per il tuo team',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: isMobile ? 14 : (isDesktop ? 16 : 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 20,
                          vertical: isMobile ? 12 : 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_filteredCVs.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 24 : (isDesktop ? 32 : 28),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'CV Disponibili',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticleBackground() {
    return Positioned.fill(child: CustomPaint(painter: ParticlePainter()));
  }

  Widget _buildSearchAndFilters(bool isDesktop, bool isTablet, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : (isDesktop ? 24 : 20),
          isMobile ? 16 : 20,
          isMobile ? 16 : (isDesktop ? 24 : 20),
          isMobile ? 16 : 20,
        ),
        child: Column(
          children: [
            // Header con titolo e contatore (solo su desktop/tablet)
            if (!isMobile) ...[
              Row(
                children: [
                  Text(
                    'Registro Pubblico',
                    style: AppTheme.title1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A0E27),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_filteredCVs.length} CV',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],

            // Barra di ricerca moderna
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                border: Border.all(
                  color: const Color(0xFF0A0E27).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Cerca CV...'
                      : 'Cerca per nome, competenze, località...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF0A0E27).withValues(alpha: 0.5),
                    fontSize: isMobile ? 14 : 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF06B6D4),
                    size: isMobile ? 20 : 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: const Color(
                              0xFF0A0E27,
                            ).withValues(alpha: 0.5),
                            size: isMobile ? 18 : 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterCVs();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
                style: TextStyle(fontSize: isMobile ? 14 : 16),
                onChanged: (_) => _filterCVs(),
              ),
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Filtri responsive
            isMobile
                ? Column(
                    children: [
                      // Filtro località su mobile
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                              0xFF0A0E27,
                            ).withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: 'Località',
                            hintStyle: TextStyle(
                              color: const Color(
                                0xFF0A0E27,
                              ).withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: const Color(0xFF06B6D4),
                              size: 18,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (_) => _filterCVs(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Dropdown e filtri su mobile
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF8F9FA,
                                ).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF0A0E27,
                                  ).withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSortBy,
                                  isExpanded: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF0A0E27),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'recent',
                                      child: Text('Più recenti'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'name',
                                      child: Text('Nome'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'location',
                                      child: Text('Località'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'verified',
                                      child: Text('Verificati'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedSortBy = value;
                                      });
                                      _filterCVs();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Filtro verificati su mobile
                          _buildVerifiedFilter(isMobile: true),
                        ],
                      ),
                      // Pulsante pulisci filtri su mobile
                      if (_hasActiveFilters()) ...[
                        const SizedBox(height: 12),
                        _buildClearFiltersButton(isMobile: true),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      // Filtro località
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF8F9FA,
                            ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFF0A0E27,
                              ).withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Località',
                              hintStyle: TextStyle(
                                color: const Color(
                                  0xFF0A0E27,
                                ).withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: const Color(0xFF06B6D4),
                                size: 18,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                            onChanged: (_) => _filterCVs(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Dropdown ordinamento
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF8F9FA,
                            ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFF0A0E27,
                              ).withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSortBy,
                              isExpanded: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF0A0E27),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'recent',
                                  child: Text('Più recenti'),
                                ),
                                DropdownMenuItem(
                                  value: 'name',
                                  child: Text('Nome'),
                                ),
                                DropdownMenuItem(
                                  value: 'location',
                                  child: Text('Località'),
                                ),
                                DropdownMenuItem(
                                  value: 'verified',
                                  child: Text('Verificati'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSortBy = value;
                                  });
                                  _filterCVs();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Filtro verificati
                      _buildVerifiedFilter(isMobile: false),

                      // Pulsante pulisci filtri
                      if (_hasActiveFilters()) ...[
                        const SizedBox(width: 8),
                        _buildClearFiltersButton(isMobile: false),
                      ],
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A0E27).withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: const Color(0xFF06B6D4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nessun CV trovato',
              style: AppTheme.title1.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A0E27),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Prova a modificare i filtri di ricerca o\ncerca con termini diversi',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF0A0E27).withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_hasActiveFilters())
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _clearAllFilters,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 18,
                            color: const Color(0xFF06B6D4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pulisci tutti i filtri',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF06B6D4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCVListSliver(bool isDesktop, bool isTablet, bool isMobile) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final cv = _filteredCVs[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : (isDesktop ? 24 : 20),
            index == 0 ? (isMobile ? 12 : 16) : 0,
            isMobile ? 16 : (isDesktop ? 24 : 20),
            index == _filteredCVs.length - 1 ? (isMobile ? 16 : 24) : 0,
          ),
          child: _buildModernCVCard(cv, isDesktop, isTablet, isMobile),
        );
      }, childCount: _filteredCVs.length),
    );
  }

  Widget _buildModernCVCard(
    CV cv,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A0E27).withValues(alpha: 0.08),
            blurRadius: isMobile ? 12 : 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF0A0E27).withValues(alpha: 0.04),
            blurRadius: isMobile ? 6 : 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0A0E27).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar e info principali
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar moderno con gradiente
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF06B6D4),
                        Color(0xFF3B82F6),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                        blurRadius: isMobile ? 8 : 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: isMobile ? 24 : 32,
                    backgroundColor: Colors.transparent,
                    child: cv.hasProfilePicture
                        ? ClipOval(
                            child: Image.network(
                              cv.profilePicture!,
                              width: isMobile ? 48 : 64,
                              height: isMobile ? 48 : 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  cv.initials,
                                  style: AppTheme.title1.copyWith(
                                    color: const Color(0xFF06B6D4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 16 : 20,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            cv.initials,
                            style: AppTheme.title1.copyWith(
                              color: const Color(0xFF06B6D4),
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 16 : 20,
                            ),
                          ),
                  ),
                ),

                SizedBox(width: isMobile ? 12 : 16),

                // Informazioni principali
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome e badge verifica
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cv.displayName,
                              style: AppTheme.title2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0A0E27),
                                fontSize: isMobile ? 16 : 18,
                              ),
                            ),
                          ),
                          if (cv.isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 6 : 8,
                                vertical: isMobile ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 8 : 12,
                                ),
                                border: Border.all(
                                  color: AppTheme.successGreen,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: AppTheme.successGreen,
                                    size: isMobile ? 12 : 16,
                                  ),
                                  SizedBox(width: isMobile ? 3 : 4),
                                  Text(
                                    'Verificato',
                                    style: TextStyle(
                                      fontSize: isMobile ? 10 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: isMobile ? 6 : 8),

                      // Località con icona
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isMobile ? 16 : 18,
                            color: const Color(0xFF06B6D4),
                          ),
                          SizedBox(width: isMobile ? 4 : 6),
                          Expanded(
                            child: Text(
                              cv.displayLocation,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: const Color(
                                  0xFF0A0E27,
                                ).withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isMobile ? 8 : 12),

                      // Contatto con icona
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: isMobile ? 16 : 18,
                            color: const Color(0xFF06B6D4),
                          ),
                          SizedBox(width: isMobile ? 4 : 6),
                          Expanded(
                            child: Text(
                              cv.displayContact,
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: const Color(
                                  0xFF0A0E27,
                                ).withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Footer con info aggiuntive e azioni
            isMobile
                ? Column(
                    children: [
                      // Info aggiornamento su mobile
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: const Color(
                              0xFF0A0E27,
                            ).withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Aggiornato ${_formatDate(cv.updatedAt ?? cv.createdAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(
                                0xFF0A0E27,
                              ).withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Azioni su mobile
                      Row(
                        children: [
                          Expanded(child: _buildViewButton(cv, isMobile: true)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildContactButton(cv, isMobile: true),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Info aggiornamento
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: const Color(
                                0xFF0A0E27,
                              ).withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Aggiornato ${_formatDate(cv.updatedAt ?? cv.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(
                                  0xFF0A0E27,
                                ).withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Azioni
                      Row(
                        children: [
                          _buildViewButton(cv, isMobile: false),
                          const SizedBox(width: 8),
                          _buildContactButton(cv, isMobile: false),
                        ],
                      ),
                    ],
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
      return 'oggi';
    } else if (difference.inDays == 1) {
      return 'ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'settimana' : 'settimane'} fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _viewCVDetails(CV cv) {
    // TODO: Implementare la visualizzazione dettagliata del CV
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visualizzazione dettagliata per ${cv.displayName}'),
        backgroundColor: const Color(0xFF06B6D4),
      ),
    );
  }

  void _contactCV(CV cv) {
    // TODO: Implementare il sistema di contatto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contatto per ${cv.displayName}'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  Widget _buildVerifiedFilter({required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        color: _showVerifiedOnly
            ? const Color(0xFF06B6D4).withValues(alpha: 0.1)
            : const Color(0xFFF8F9FA).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _showVerifiedOnly
              ? const Color(0xFF06B6D4)
              : const Color(0xFF0A0E27).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _showVerifiedOnly = !_showVerifiedOnly;
            });
            _filterCVs();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 8 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  size: isMobile ? 14 : 16,
                  color: _showVerifiedOnly
                      ? const Color(0xFF06B6D4)
                      : const Color(0xFF0A0E27).withValues(alpha: 0.6),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  'Verificati',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: _showVerifiedOnly
                        ? const Color(0xFF06B6D4)
                        : const Color(0xFF0A0E27).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton({required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.errorRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _clearAllFilters,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 8 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.clear,
                  size: isMobile ? 14 : 16,
                  color: AppTheme.errorRed,
                ),
                SizedBox(width: isMobile ? 4 : 4),
                Text(
                  'Pulisci',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.errorRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton(CV cv, {required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(
          color: const Color(0xFF0A0E27).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A0E27).withValues(alpha: 0.05),
            blurRadius: isMobile ? 4 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          onTap: () => _viewCVDetails(cv),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: isMobile ? 14 : 16,
                  color: const Color(0xFF06B6D4),
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  'Visualizza',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF06B6D4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton(CV cv, {required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          onTap: () => _contactCV(cv),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 6 : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: isMobile ? 14 : 16,
                  color: Colors.white,
                ),
                SizedBox(width: isMobile ? 4 : 6),
                Text(
                  'Contatta',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 23.0) % size.height;
      final radius = (i % 3 + 1) * 2.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
