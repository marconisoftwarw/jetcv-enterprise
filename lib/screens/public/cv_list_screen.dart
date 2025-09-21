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
      final cvs = await _cvService.getPublicCVs();
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

  void _filterCVs() {
    String searchQuery = _searchController.text.trim();
    String locationQuery = _locationController.text.trim();

    List<CV> filtered = List.from(_cvs);

    // Filtra per ricerca testuale
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((cv) {
        return cv.displayName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            cv.displayLocation.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            (cv.email?.toLowerCase() ?? '').contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Filtra per località
    if (locationQuery.isNotEmpty) {
      filtered = filtered.where((cv) {
        return cv.displayLocation.toLowerCase().contains(
          locationQuery.toLowerCase(),
        );
      }).toList();
    }

    // Filtra per verifica
    if (_showVerifiedOnly) {
      filtered = filtered.where((cv) => cv.isVerified).toList();
    }

    // Ordina i risultati
    _sortCVs(filtered);

    setState(() {
      _filteredCVs = filtered;
    });
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
          'CV Pubblici',
          style: AppTheme.title1.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          const AppBarLanguageDropdown(),
          IconButton(
            onPressed: _loadCVs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna',
          ),
          IconButton(
            onPressed: _testDatabaseConnection,
            icon: const Icon(Icons.bug_report),
            tooltip: 'Test Database',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildStats(),
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
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        children: [
          // Barra di ricerca principale
          LinkedInTextField(
            controller: _searchController,
            hint: 'Cerca CV per nome, competenze o località...',
            prefixIcon: Icon(Icons.search),
            onChanged: (_) => _filterCVs(),
          ),

          const SizedBox(height: 16),

          // Filtri avanzati
          Row(
            children: [
              Expanded(
                child: LinkedInTextField(
                  controller: _locationController,
                  hint: 'Località',
                  prefixIcon: Icon(Icons.location_on),
                  onChanged: (_) => _filterCVs(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSortBy,
                  decoration: InputDecoration(
                    labelText: 'Ordina per',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
            ],
          ),

          const SizedBox(height: 16),

          // Filtri rapidi
          Row(
            children: [
              FilterChip(
                label: const Text('Solo verificati'),
                selected: _showVerifiedOnly,
                onSelected: (selected) {
                  setState(() {
                    _showVerifiedOnly = selected;
                  });
                  _filterCVs();
                },
                selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 12),
              if (_hasActiveFilters())
                ElevatedButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Pulisci filtri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              const Spacer(),
              Text(
                '${_filteredCVs.length} CV trovati',
                style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (_stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Totale CV',
              _stats['total']?.toString() ?? '0',
              Icons.description,
              AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Verificati',
              _stats['verified']?.toString() ?? '0',
              Icons.verified,
              AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Con Wallet',
              _stats['withWallet']?.toString() ?? '0',
              Icons.account_balance_wallet,
              AppTheme.warningOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return LinkedInCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.title1.copyWith(color: color)),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppTheme.primaryBlack),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: LinkedInCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: AppTheme.primaryBlack),
              const SizedBox(height: 16),
              Text(
                'Nessun CV trovato',
                style: AppTheme.title1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Prova a modificare i filtri di ricerca',
                style: TextStyle(fontSize: 16, color: AppTheme.primaryBlack),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCVList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCVs.length,
      itemBuilder: (context, index) {
        final cv = _filteredCVs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCVCard(cv),
        );
      },
    );
  }

  Widget _buildCVCard(CV cv) {
    return LinkedInCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: cv.hasProfilePicture
                  ? ClipOval(
                      child: Image.network(
                        cv.profilePicture!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            cv.initials,
                            style: AppTheme.title1.copyWith(
                              color: AppTheme.primaryBlue,
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      cv.initials,
                      style: AppTheme.title1.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
            ),

            const SizedBox(width: 16),

            // Informazioni CV
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cv.displayName,
                          style: AppTheme.title2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (cv.isVerified)
                        Icon(
                          Icons.verified,
                          color: AppTheme.successGreen,
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    cv.displayLocation,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.primaryBlack,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: AppTheme.primaryBlack),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cv.displayContact,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppTheme.primaryBlack,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Aggiornato ${_formatDate(cv.updatedAt ?? cv.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Azioni
            Column(
              children: [
                LinkedInButton(
                  onPressed: () => _viewCVDetails(cv),
                  text: 'Visualizza',
                  icon: Icons.visibility,
                  variant: LinkedInButtonVariant.outline,
                ),
                const SizedBox(height: 8),
                LinkedInButton(
                  onPressed: () => _contactCV(cv),
                  text: 'Contatta',
                  icon: Icons.message,
                  variant: LinkedInButtonVariant.primary,
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

  Future<void> _testDatabaseConnection() async {
    try {
      final cvs = await _cvService.getPublicCVs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connessione al database riuscita! CV trovati: ${cvs.length}',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella connessione al database: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}
