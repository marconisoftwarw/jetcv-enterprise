import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/certifier.dart';
import '../models/legal_entity.dart';
import '../services/certifier_service.dart';
import '../services/email_service.dart';
import '../services/edge_function_service.dart';
import '../providers/auth_provider.dart';
import '../providers/legal_entity_provider.dart';
import '../services/user_type_service.dart';
import '../widgets/modern_loader.dart';

class CertifiersContent extends StatefulWidget {
  @override
  _CertifiersContentState createState() => _CertifiersContentState();
}

class _CertifiersContentState extends State<CertifiersContent> {
  final CertifierService _certifierService = CertifierService();
  final EmailService _emailService = EmailService();
  List<CertifierWithUser> _certifiersWithUser = [];
  List<CertifierWithUser> _filteredCertifiers = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filtri
  DateTime? _selectedBirthDate;
  String? _selectedRole;
  String? _selectedCity;
  List<String> _availableRoles = [];
  List<String> _availableCities = [];
  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Legal entity per l'utente corrente
  String? _selectedLegalEntityId;
  List<LegalEntity> _userLegalEntities = [];
  bool _isLoadingCurrentUserLegalEntity = false;

  @override
  void initState() {
    super.initState();
    _loadCertifiers();
    _loadCurrentUserLegalEntity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserLegalEntity() async {
    setState(() {
      _isLoadingCurrentUserLegalEntity = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('Utente non autenticato');
      }

      // Usa l'edge function per ottenere le legal entity dell'utente
      final response = await EdgeFunctionService.getLegalEntitiesByUser(
        userId: currentUser.idUser,
      );

      if (response != null && response['ok'] == true) {
        final data = response['data'] as List<dynamic>?;
        if (data != null && data.isNotEmpty) {
          // Converti i dati in oggetti LegalEntity
          final legalEntities = data
              .map((item) => LegalEntity.fromJson(item))
              .toList();
          setState(() {
            _userLegalEntities = legalEntities;
            // Seleziona automaticamente la prima legal entity
            if (legalEntities.isNotEmpty) {
              _selectedLegalEntityId = legalEntities.first.idLegalEntity;
            }
          });
          print(
            '✅ Loaded ${legalEntities.length} legal entities for current user',
          );
        } else {
          setState(() {
            _userLegalEntities = [];
            _selectedLegalEntityId = null;
          });
          print('❌ No legal entities found for current user');
        }
      } else {
        throw Exception(
          response?['message'] ?? 'Failed to load legal entities',
        );
      }
    } catch (e) {
      print('Error loading current user legal entity: $e');
      setState(() {
        _userLegalEntities = [];
        _selectedLegalEntityId = null;
      });
    } finally {
      setState(() {
        _isLoadingCurrentUserLegalEntity = false;
      });
    }
  }

  Future<void> _loadCertifiers() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final legalEntityProvider = Provider.of<LegalEntityProvider>(
        context,
        listen: false,
      );
      final isAdmin = authProvider.userType == AppUserType.admin;

      List<CertifierWithUser> certifiersWithUser;

      if (isAdmin) {
        // Admin vede tutti i certificatori con dati utente
        print('🔍 Loading all certifiers with user data for admin');
        certifiersWithUser = await _certifierService
            .getCertifiersWithUserByLegalEntity('all');
      } else {
        // Legal entity vede solo i propri certificatori con dati utente
        final selectedLegalEntity = legalEntityProvider.selectedLegalEntity;

        if (selectedLegalEntity == null) {
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            setState(() {
              _errorMessage = l10n.getString('no_legal_entity_selected');
              _isLoading = false;
            });
          }
          return;
        }

        print(
          '🔍 Loading certifiers with user data for legal entity: ${selectedLegalEntity.idLegalEntity}',
        );

        // Usa la nuova Edge Function per ottenere certificatori con dati utente
        certifiersWithUser = await _certifierService
            .getCertifiersWithUserByLegalEntity(
              selectedLegalEntity.idLegalEntity,
            );
      }

      if (mounted) {
        setState(() {
          _certifiersWithUser = certifiersWithUser;
          _filteredCertifiers = certifiersWithUser;
          _extractFilterOptions();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading certifiers: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _errorMessage = '${l10n.getString('error_loading_certifiers')}: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _extractFilterOptions() {
    final roles = <String>{};
    final cities = <String>{};

    for (final certifierWithUser in _certifiersWithUser) {
      if (certifierWithUser.certifier.role != null &&
          certifierWithUser.certifier.role!.isNotEmpty) {
        roles.add(certifierWithUser.certifier.role!);
      }
      if (certifierWithUser.user?.city != null &&
          certifierWithUser.user!.city!.isNotEmpty) {
        cities.add(certifierWithUser.user!.city!);
      }
    }

    if (mounted) {
      setState(() {
        _availableRoles = roles.toList()..sort();
        _availableCities = cities.toList()..sort();
      });
    }
  }

  void _applyFilters() {
    if (mounted) {
      setState(() {
        _filteredCertifiers = _certifiersWithUser.where((certifierWithUser) {
          // Filtro per data di nascita (match esatto sul giorno)
          if (_selectedBirthDate != null) {
            final userBirthDate = certifierWithUser.user?.dateOfBirth;
            // Se l'utente non ha la data di nascita, escludi
            if (userBirthDate == null) {
              return false;
            }

            final selected = DateTime(
              _selectedBirthDate!.year,
              _selectedBirthDate!.month,
              _selectedBirthDate!.day,
            );
            final userDobOnly = DateTime(
              userBirthDate.year,
              userBirthDate.month,
              userBirthDate.day,
            );

            if (userDobOnly != selected) {
              return false;
            }
          }

          // Filtro per ruolo
          if (_selectedRole != null &&
              certifierWithUser.certifier.role != _selectedRole) {
            return false;
          }

          // Filtro per città
          if (_selectedCity != null &&
              certifierWithUser.user?.city != _selectedCity) {
            return false;
          }

          // Filtro ricerca testo (nome, email, ruolo, città)
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase().trim();
            final fullName = '${certifierWithUser.user?.firstName ?? ''} ${certifierWithUser.user?.lastName ?? ''}'.toLowerCase();
            final email = (certifierWithUser.user?.email ?? '').toLowerCase();
            final role = (certifierWithUser.certifier.role ?? '').toLowerCase();
            final city = (certifierWithUser.user?.city ?? '').toLowerCase();
            if (!(fullName.contains(query) ||
                email.contains(query) ||
                role.contains(query) ||
                city.contains(query))) {
              return false;
            }
          }

          return true;
        }).toList();
      });
    }
  }

  void _clearFilters() {
    if (mounted) {
      setState(() {
        _selectedBirthDate = null;
        _selectedRole = null;
        _selectedCity = null;
        _searchQuery = '';
        _filteredCertifiers = _certifiersWithUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (_isLoading) {
      return ModernLoader(
        title: l10n.getString('loading_certifiers'),
        subtitle: l10n.getString('please_wait'),
        icon: Icons.verified_user,
        isTablet: isTablet,
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 64 : 48,
              color: AppTheme.errorRed,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppTheme.errorRed,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ElevatedButton(
              onPressed: _loadCertifiers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
              ),
              child: Text(l10n.getString('retry')),
            ),
          ],
        ),
      );
    }

    if (_filteredCertifiers.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con titolo e pulsante refresh
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Row(
              children: [
                Text(
                  l10n.getString('certifiers'),
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                Spacer(),
                // Add certifier button
                Container(
                  margin: EdgeInsets.only(right: 18),
                  child: ElevatedButton.icon(
                    onPressed: _showAddCertifierDialog,
                    icon: Icon(Icons.add, size: isTablet ? 20 : 18),
                    label: Text(
                      l10n.getString('add_certifier'),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.pureWhite,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 12 : 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadCertifiers,
                  icon: Icon(Icons.refresh, size: isTablet ? 24 : 20),
                  tooltip: l10n.getString('refresh'),
                ),
              ],
            ),
          ),

          // Sezione filtri (sempre visibile)
          _buildFiltersSection(l10n, isTablet),

          // Messaggio nessun certificatore trovato
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: isTablet ? 64 : 48,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Text(
                    l10n.getString('no_certifiers_found'),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.getString('no_certifiers_for_entity'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con titolo e pulsante refresh
        Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Row(
            children: [
              Text(
                l10n.getString('certifiers'),
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const Spacer(),
              // Add certifier button
              Container(
                margin: EdgeInsets.only(right: 18),
                child: ElevatedButton.icon(
                  onPressed: _showAddCertifierDialog,
                  icon: Icon(Icons.add, size: isTablet ? 20 : 18),
                  label: Text(
                    l10n.getString('add_certifier'),
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.pureWhite,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 12 : 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: AppTheme.primaryBlue),
                onPressed: _loadCertifiers,
                tooltip: l10n.getString('refresh'),
              ),
            ],
          ),
        ),

        // Sezione filtri
        _buildFiltersSection(l10n, isTablet),

        // Lista certificatori
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 8 : 4,
            ),
            itemCount: _filteredCertifiers.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: isTablet ? 16 : 12),
            itemBuilder: (context, index) {
              final certifierWithUser = _filteredCertifiers[index];
              return _buildCertifierCard(certifierWithUser, l10n, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(AppLocalizations l10n, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header filtri
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppTheme.primaryBlue,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: 8),
              Text(
                l10n.getString('filters'),
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _clearFilters,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        (_selectedBirthDate != null ||
                            _selectedRole != null ||
                            _selectedCity != null ||
                            _searchQuery.isNotEmpty)
                        ? AppTheme.errorRed.withValues(alpha: 0.1)
                        : AppTheme.neutralGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (_selectedBirthDate != null ||
                              _selectedRole != null ||
                              _selectedCity != null ||
                              _searchQuery.isNotEmpty)
                          ? AppTheme.errorRed.withValues(alpha: 0.3)
                          : AppTheme.neutralGrey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.clear,
                        color:
                            (_selectedBirthDate != null ||
                                _selectedRole != null ||
                                _selectedCity != null ||
                                _searchQuery.isNotEmpty)
                            ? AppTheme.errorRed
                            : AppTheme.neutralGrey,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        l10n.getString('clear_filters'),
                        style: TextStyle(
                          color:
                              (_selectedBirthDate != null ||
                                  _selectedRole != null ||
                                  _selectedCity != null ||
                                  _searchQuery.isNotEmpty)
                              ? AppTheme.errorRed
                              : AppTheme.neutralGrey,
                          fontSize: isTablet ? 13 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Search bar
          _buildSearchBar(l10n, isTablet),

          // Selected filters chips
          _buildSelectedFilterChips(l10n, isTablet),

          SizedBox(height: isTablet ? 16 : 12),

          // Filtri
          Wrap(
            spacing: isTablet ? 16 : 12,
            runSpacing: isTablet ? 16 : 12,
            children: [
              // Filtro data di nascita
              _buildDateFilter(l10n, isTablet),

              // Filtro ruolo
              _buildRoleFilter(l10n, isTablet),

              // Filtro città
              _buildCityFilter(l10n, isTablet),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Contatore risultati
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 16),
                SizedBox(width: 8),
                Text(
                  '${_filteredCertifiers.length} ${l10n.getString('certifiers_found')}',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, bool isTablet) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        _searchQuery = value;
        _applyFilters();
      },
      decoration: InputDecoration(
        hintText: l10n.getString('search_placeholder'),
        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: l10n.getString('clear_filters'),
                icon: Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilters();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.06),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
      ),
      style: TextStyle(fontSize: isTablet ? 14 : 13),
    );
  }

  Widget _buildSelectedFilterChips(AppLocalizations l10n, bool isTablet) {
    final hasAny = _selectedBirthDate != null ||
        _selectedRole != null ||
        _selectedCity != null ||
        _searchQuery.isNotEmpty;

    if (!hasAny) return SizedBox.shrink();

    final chips = <Widget>[];

    if (_searchQuery.isNotEmpty) {
      chips.add(_buildChip(
        label: '${l10n.getString('search')}: $_searchQuery',
        onDeleted: () {
          _searchController.clear();
          _searchQuery = '';
          _applyFilters();
        },
        isTablet: isTablet,
      ));
    }
    if (_selectedBirthDate != null) {
      chips.add(_buildChip(
        label:
            '${l10n.getString('birth_date')}: ${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
        onDeleted: () {
          setState(() => _selectedBirthDate = null);
          _applyFilters();
        },
        isTablet: isTablet,
      ));
    }
    if (_selectedRole != null) {
      chips.add(_buildChip(
        label: '${l10n.getString('role')}: $_selectedRole',
        onDeleted: () {
          setState(() => _selectedRole = null);
          _applyFilters();
        },
        isTablet: isTablet,
      ));
    }
    if (_selectedCity != null) {
      chips.add(_buildChip(
        label: '${l10n.getString('city')}: $_selectedCity',
        onDeleted: () {
          setState(() => _selectedCity = null);
          _applyFilters();
        },
        isTablet: isTablet,
      ));
    }

    return Padding(
      padding: EdgeInsets.only(top: isTablet ? 8 : 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required VoidCallback onDeleted,
    required bool isTablet,
  }) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: isTablet ? 13 : 12),
      ),
      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      deleteIcon: Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
    );
  }

  Widget _buildDateFilter(AppLocalizations l10n, bool isTablet) {
    return Container(
      width: isTablet ? 200 : 160,
      height: isTablet ? 85 : 75,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedBirthDate != null
              ? AppTheme.primaryBlue
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedBirthDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppTheme.primaryBlue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && mounted) {
            setState(() {
              _selectedBirthDate = picked;
            });
            _applyFilters();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.getString('birth_date'),
                style: TextStyle(
                  fontSize: isTablet ? 11 : 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Flexible(
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : l10n.getString('select_date'),
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: _selectedBirthDate != null
                        ? AppTheme.primaryBlack
                        : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFilter(AppLocalizations l10n, bool isTablet) {
    return Container(
      width: isTablet ? 200 : 160,
      height: isTablet ? 85 : 75,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedRole != null
              ? AppTheme.primaryBlue
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String?>(
            value: _selectedRole,
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.getString('role'),
                    style: TextStyle(
                      fontSize: isTablet ? 11 : 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      l10n.getString('all_roles'),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            selectedItemBuilder: (BuildContext context) {
              return [
                // Per il valore null (all_roles)
                Padding(
                  padding: EdgeInsets.all(isTablet ? 12 : 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.getString('role'),
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          l10n.getString('all_roles'),
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 12,
                            color: AppTheme.primaryBlack,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Per ogni ruolo disponibile
                ..._availableRoles.map((String role) {
                  return Padding(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.getString('role'),
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              color: AppTheme.primaryBlack,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ];
            },
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.getString('all_roles')),
              ),
              ..._availableRoles.map(
                (role) =>
                    DropdownMenuItem<String>(value: role, child: Text(role)),
              ),
            ],
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _selectedRole = value;
                });
                _applyFilters();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCityFilter(AppLocalizations l10n, bool isTablet) {
    return Container(
      width: isTablet ? 200 : 160,
      height: isTablet ? 85 : 75,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedCity != null
              ? AppTheme.primaryBlue
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String?>(
            value: _selectedCity,
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.getString('city'),
                    style: TextStyle(
                      fontSize: isTablet ? 11 : 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      l10n.getString('all_cities'),
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            selectedItemBuilder: (BuildContext context) {
              return [
                // Per il valore null (all_cities)
                Padding(
                  padding: EdgeInsets.all(isTablet ? 12 : 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.getString('city'),
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          l10n.getString('all_cities'),
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 12,
                            color: AppTheme.primaryBlack,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Per ogni città disponibile
                ..._availableCities.map((String city) {
                  return Padding(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.getString('city'),
                          style: TextStyle(
                            fontSize: isTablet ? 11 : 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              color: AppTheme.primaryBlack,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ];
            },
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.getString('all_cities')),
              ),
              ..._availableCities.map(
                (city) =>
                    DropdownMenuItem<String>(value: city, child: Text(city)),
              ),
            ],
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _selectedCity = value;
                });
                _applyFilters();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCertifierCard(
    CertifierWithUser certifierWithUser,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final certifier = certifierWithUser.certifier;
    final user = certifierWithUser.user;
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final isAdmin = authProvider.userType == AppUserType.admin;

    // Debug logging
    print('🔍 Building certifier card:');
    print('   - Certifier ID: ${certifier.idCertifier}');
    print('   - User is null: ${user == null}');
    if (user != null) {
      print('   - User ID: ${user.idUser}');
      print('   - First Name: ${user.firstName}');
      print('   - Last Name: ${user.lastName}');
      print('   - Email: ${user.email}');
    }

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar e info principale
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Row(
              children: [
                // Avatar moderno
                Container(
                  width: isTablet ? 72 : 60,
                  height: isTablet ? 72 : 60,
                  decoration: BoxDecoration(
                    gradient: certifier.active
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.primaryBlue.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.neutralGrey,
                              AppTheme.neutralGrey.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (certifier.active
                                    ? AppTheme.primaryBlue
                                    : AppTheme.neutralGrey)
                                .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: user != null
                      ? Center(
                          child: Text(
                            certifierWithUser.initials,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 22 : 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.white,
                          size: isTablet ? 32 : 28,
                        ),
                ),
                SizedBox(width: isTablet ? 20 : 16),

                // Info principale
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user != null) ...[
                        // Nome completo
                        Text(
                          '${user.firstName?.isNotEmpty == true ? user.firstName! : 'N/A'} ${user.lastName?.isNotEmpty == true && user.lastName != 'N/A' ? user.lastName! : 'N/A'}',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlack,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Email
                        Text(
                          user.email?.isNotEmpty == true ? user.email! : 'N/A',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Invito in sospeso',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'In attesa di registrazione',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Azioni
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // More actions button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppTheme.textSecondary,
                          size: isTablet ? 24 : 20,
                        ),
                        onPressed: () =>
                            _showCertifierActions(certifierWithUser),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Separatore
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Dettagli e badge
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informazioni aggiuntive
                if (user != null) ...[
                  if (user.dateOfBirth != null) ...[
                    _buildInfoRow(
                      Icons.cake,
                      'Nato il ${certifierWithUser.dateOfBirthFormatted}',
                      isTablet,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                  ],
                  if (certifier.role != null) ...[
                    _buildInfoRow(Icons.work, certifier.role!, isTablet),
                    SizedBox(height: isTablet ? 12 : 8),
                  ],
                  if (user.city != null) ...[
                    _buildInfoRow(Icons.location_on, user.city!, isTablet),
                    SizedBox(height: isTablet ? 16 : 12),
                  ],
                ],

                // Badge di stato
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: certifier.active
                            ? AppTheme.successGreen.withValues(alpha: 0.1)
                            : AppTheme.neutralGrey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: certifier.active
                              ? AppTheme.successGreen.withValues(alpha: 0.3)
                              : AppTheme.neutralGrey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: certifier.active
                                  ? AppTheme.successGreen
                                  : AppTheme.neutralGrey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            certifier.active
                                ? l10n.getString('active')
                                : l10n.getString('inactive'),
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 12,
                              fontWeight: FontWeight.w600,
                              color: certifier.active
                                  ? AppTheme.successGreen
                                  : AppTheme.neutralGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),

                    // KYC badge
                    if (certifier.kycPassed == true) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: AppTheme.primaryBlue,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              l10n.getString('kyc_verified'),
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (certifier.kycPassed == false) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              l10n.getString('kyc_failed'),
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isTablet) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: isTablet ? 18 : 16,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showCertifierActions(CertifierWithUser certifierWithUser) {
    final certifier = certifierWithUser.certifier;
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility, color: AppTheme.primaryBlue),
                title: Text(l10n.getString('view_details')),
                onTap: () {
                  Navigator.pop(context);
                  _showCertifierDetails(certifierWithUser, l10n, isTablet);
                },
              ),
              if (certifier.invitationToken != null) ...[
                ListTile(
                  leading: Icon(Icons.send, color: AppTheme.primaryBlue),
                  title: Text(l10n.getString('resend_invitation')),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Resend invitation
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showCertifierDetails(
    CertifierWithUser certifierWithUser,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final certifier = certifierWithUser.certifier;
    final user = certifierWithUser.user;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.userType == AppUserType.admin;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.verified_user, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text(l10n.getString('certifier_details')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Informazioni personali
              if (user != null) ...[
                _buildDetailSection(l10n.getString('personal_information'), [
                  _buildDetailRow(
                    l10n.getString('first_name'),
                    user.firstName ?? 'N/A',
                  ),
                  _buildDetailRow(
                    l10n.getString('last_name'),
                    user.lastName ?? 'N/A',
                  ),
                  _buildDetailRow(l10n.getString('email'), user.email ?? 'N/A'),
                  if (user.dateOfBirth != null)
                    _buildDetailRow(
                      l10n.getString('date_of_birth'),
                      certifierWithUser.dateOfBirthFormatted,
                    ),
                  if (user.phone != null)
                    _buildDetailRow(l10n.getString('phone'), user.phone!),
                  if (user.city != null)
                    _buildDetailRow(l10n.getString('city'), user.city!),
                  if (user.address != null)
                    _buildDetailRow(l10n.getString('address'), user.address!),
                ]),
                SizedBox(height: 16),
              ] else ...[
                _buildDetailSection(l10n.getString('personal_information'), [
                  _buildDetailRow(
                    l10n.getString('status'),
                    l10n.getString('pending_invitation'),
                  ),
                ]),
                SizedBox(height: 16),
              ],

              // Informazioni del certificatore
              _buildDetailSection(l10n.getString('certifier_information'), [
                _buildDetailRow(
                  l10n.getString('status'),
                  certifier.active
                      ? l10n.getString('active')
                      : l10n.getString('inactive'),
                ),
                if (certifier.kycPassed == true)
                  _buildDetailRow(
                    l10n.getString('kyc_status'),
                    l10n.getString('kyc_verified'),
                  ),
                if (certifier.kycPassed == false)
                  _buildDetailRow(
                    l10n.getString('kyc_status'),
                    l10n.getString('kyc_failed'),
                  ),
                if (isAdmin)
                  _buildDetailRow(
                    l10n.getString('legal_entity_id'),
                    certifierWithUser.legalEntityName ??
                        certifier.idLegalEntity,
                  ),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.getString('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlack,
          ),
        ),
        SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCertifierDialog() {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final legalEntityProvider = Provider.of<LegalEntityProvider>(
      context,
      listen: false,
    );
    final isAdmin = authProvider.userType == AppUserType.admin;

    // Form controllers
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();
    final cityController = TextEditingController();
    final addressController = TextEditingController();

    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person_add, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text(l10n.getString('new_certifier')),
            ],
          ),
          content: Container(
            width: isTablet ? 500 : double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Legal Entity Info (per tutti gli utenti)
                  _buildCurrentUserLegalEntityInfo(l10n, isTablet),

                  // Personal Data Section
                  _buildSectionHeader(
                    l10n.getString('personal_data'),
                    Icons.person,
                    isTablet,
                  ),
                  SizedBox(height: 12),

                  // First Name and Last Name Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: firstNameController,
                          label: l10n.getString('first_name'),
                          hint: l10n.getString('first_name'),
                          isTablet: isTablet,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: lastNameController,
                          label: l10n.getString('last_name'),
                          hint: l10n.getString('last_name'),
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Contact Information Section
                  _buildSectionHeader(
                    l10n.getString('contact_information'),
                    Icons.contact_mail,
                    isTablet,
                  ),
                  SizedBox(height: 12),

                  // Email
                  _buildTextField(
                    controller: emailController,
                    label: l10n.getString('email'),
                    hint: l10n.getString('email'),
                    keyboardType: TextInputType.emailAddress,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: 16),

                  // Phone
                  _buildTextField(
                    controller: phoneController,
                    label: l10n.getString('phone'),
                    hint: l10n.getString('phone'),
                    keyboardType: TextInputType.phone,
                    isTablet: isTablet,
                    required: false,
                  ),
                  SizedBox(height: 16),

                  // Address Information
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: addressController,
                          label: l10n.getString('address'),
                          hint: l10n.getString('address'),
                          isTablet: isTablet,
                          required: false,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: cityController,
                          label: l10n.getString('city'),
                          hint: l10n.getString('city'),
                          isTablet: isTablet,
                          required: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Certifier Role Section
                  _buildSectionHeader(
                    l10n.getString('certifier_role'),
                    Icons.work,
                    isTablet,
                  ),
                  SizedBox(height: 12),

                  _buildTextField(
                    controller: roleController,
                    label: l10n.getString('certifier_role'),
                    hint: l10n.getString('enter_role'),
                    isTablet: isTablet,
                  ),
                  SizedBox(height: 20),

                  // Info Container
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Verranno creati sia l\'utente che il certificatore associato. L\'utente potrà accedere al sistema con le credenziali fornite.',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 13,
                              color: AppTheme.primaryBlue,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(l10n.getString('cancel')),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validazione campi obbligatori
                      if (firstNameController.text.trim().isEmpty) {
                        _showError(l10n.getString('first_name_required'));
                        return;
                      }

                      if (lastNameController.text.trim().isEmpty) {
                        _showError(l10n.getString('last_name_required'));
                        return;
                      }

                      if (emailController.text.trim().isEmpty) {
                        _showError(l10n.getString('email_required'));
                        return;
                      }

                      if (!_isValidEmail(emailController.text.trim())) {
                        _showError(l10n.getString('email_invalid'));
                        return;
                      }

                      if (roleController.text.trim().isEmpty) {
                        _showError(l10n.getString('enter_role'));
                        return;
                      }

                      if (_selectedLegalEntityId == null) {
                        _showError(
                          'Nessuna legal entity disponibile per l\'utente corrente',
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        // Prepara i dati utente per la signup
                        final userData = {
                          'firstName': firstNameController.text.trim(),
                          'lastName': lastNameController.text.trim(),
                          'email': emailController.text.trim(),
                          'phone': phoneController.text.trim().isNotEmpty
                              ? phoneController.text.trim()
                              : null,
                          'city': cityController.text.trim().isNotEmpty
                              ? cityController.text.trim()
                              : null,
                          'address': addressController.text.trim().isNotEmpty
                              ? addressController.text.trim()
                              : null,
                          'type': 'certifier',
                          'fullName':
                              '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
                          'profileCompleted': true,
                          'languageCode': 'it',
                        };

                        // Prepara i dati certificatore
                        final newCertifier = Certifier(
                          idLegalEntity: _selectedLegalEntityId!,
                          role: roleController.text.trim(),
                          active: true,
                        );

                        // Crea solo il certificatore tramite Edge Function
                        print('🚀 Creating certifier via Edge Function...');
                        final certifierResult = await _certifierService
                            .createCertifierWithUser(
                              userData: userData,
                              certifier: newCertifier,
                            );

                        if (certifierResult == null) {
                          throw Exception(
                            'Errore nella creazione del certificatore',
                          );
                        }

                        print('✅ Certifier created successfully');

                        // Invia email di invito al certificatore
                        try {
                          await _emailService.sendCertifierInvitationEmail(
                            email: emailController.text.trim(),
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                            role: roleController.text.trim(),
                            legalEntityName: _userLegalEntities.isNotEmpty
                                ? _userLegalEntities.first.legalName ??
                                      'Entità Legale'
                                : 'Entità Legale',
                          );
                          print('✅ Invitation email sent successfully');
                        } catch (e) {
                          print('❌ Error sending invitation email: $e');
                          // Non bloccare il processo se l'email fallisce
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${l10n.getString('certifier_created_successfully')} - Email di invito inviata',
                              ),
                              backgroundColor: AppTheme.successGreen,
                              duration: Duration(seconds: 4),
                            ),
                          );
                          _loadCertifiers(); // Ricarica la lista
                        }
                      } catch (e) {
                        if (mounted) {
                          _showError(
                            '${l10n.getString('error_creating_certifier')}: $e',
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.pureWhite,
                        ),
                      ),
                    )
                  : Text(l10n.getString('create_certifier')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: isTablet ? 20 : 18,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 16 : 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isTablet,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            if (required) ...[
              SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isTablet,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            if (required) ...[
              SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildCurrentUserLegalEntityInfo(
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal Entity (Utente Corrente)',
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlack,
          ),
        ),
        SizedBox(height: 8),
        if (_isLoadingCurrentUserLegalEntity) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Caricamento legal entity...',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ] else if (_userLegalEntities.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nessuna legal entity disponibile per l\'utente corrente',
                    style: TextStyle(color: AppTheme.errorRed),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userLegalEntities.first.legalName ?? 'N/A',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_userLegalEntities.first.identifierCode != null)
                        Text(
                          'ID: ${_userLegalEntities.first.identifierCode}',
                          style: TextStyle(
                            color: AppTheme.successGreen,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 24),
      ],
    );
  }
}
