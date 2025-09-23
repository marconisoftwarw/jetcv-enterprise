import 'package:flutter/material.dart';
import '../../models/cv.dart';
import '../../services/cv_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../widgets/appbar_language_dropdown.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(
          'Registro Pubblico',
          style: AppTheme.title1.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: const [AppBarLanguageDropdown()],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCVs.isEmpty
                ? _buildEmptyState()
                : _buildCVList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlack.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          children: [
            // Header con titolo e contatore
            Row(
              children: [
                Text(
                  'Registro Pubblico',
                  style: AppTheme.title1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${_filteredCVs.length} CV',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Barra di ricerca moderna
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlack.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cerca per nome, competenze, località...',
                  hintStyle: TextStyle(
                    color: AppTheme.primaryBlack.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.primaryBlue,
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.primaryBlack.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterCVs();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (_) => _filterCVs(),
              ),
            ),

            const SizedBox(height: 16),

            // Filtri in una riga compatta
            Row(
              children: [
                // Filtro località
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBlack.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Località',
                        hintStyle: TextStyle(
                          color: AppTheme.primaryBlack.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primaryBlue,
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
                      color: AppTheme.lightGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBlack.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSortBy,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryBlack,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'recent',
                            child: Text('Più recenti'),
                          ),
                          DropdownMenuItem(value: 'name', child: Text('Nome')),
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
                Container(
                  decoration: BoxDecoration(
                    color: _showVerifiedOnly
                        ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                        : AppTheme.lightGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _showVerifiedOnly
                          ? AppTheme.primaryBlue
                          : AppTheme.primaryBlack.withValues(alpha: 0.1),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: _showVerifiedOnly
                                  ? AppTheme.primaryBlue
                                  : AppTheme.primaryBlack.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Verificati',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _showVerifiedOnly
                                    ? AppTheme.primaryBlue
                                    : AppTheme.primaryBlack.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Pulsante pulisci filtri
                if (_hasActiveFilters()) ...[
                  const SizedBox(width: 8),
                  Container(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.clear,
                                size: 16,
                                color: AppTheme.errorRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Pulisci',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.errorRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlack.withValues(alpha: 0.05),
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
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nessun CV trovato',
              style: AppTheme.title1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Prova a modificare i filtri di ricerca o\ncerca con termini diversi',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_hasActiveFilters())
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
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
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pulisci tutti i filtri',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
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

  Widget _buildCVList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: _filteredCVs.length,
      itemBuilder: (context, index) {
        final cv = _filteredCVs[index];
        return _buildCVCard(cv);
      },
    );
  }

  Widget _buildCVCard(CV cv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlack.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar e info principali
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar migliorato
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.1,
                    ),
                    child: cv.hasProfilePicture
                        ? ClipOval(
                            child: Image.network(
                              cv.profilePicture!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  cv.initials,
                                  style: AppTheme.title1.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            cv.initials,
                            style: AppTheme.title1.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

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
                                color: AppTheme.primaryBlack,
                              ),
                            ),
                          ),
                          if (cv.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
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
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verificato',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Località con icona
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              cv.displayLocation,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.primaryBlack.withValues(
                                  alpha: 0.8,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Contatto con icona
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 18,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              cv.displayContact,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryBlack.withValues(
                                  alpha: 0.7,
                                ),
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

            const SizedBox(height: 16),

            // Footer con info aggiuntive e azioni
            Row(
              children: [
                // Info aggiornamento
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Aggiornato ${_formatDate(cv.updatedAt ?? cv.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Azioni
                Row(
                  children: [
                    // Pulsante Visualizza
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _viewCVDetails(cv),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 16,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Visualizza',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Pulsante Contatta
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.primaryBlue.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _contactCV(cv),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.message_outlined,
                                  size: 16,
                                  color: AppTheme.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Contatta',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.white,
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
        backgroundColor: AppTheme.primaryBlue,
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
}
