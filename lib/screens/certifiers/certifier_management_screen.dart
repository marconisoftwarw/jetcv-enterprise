import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../providers/certifier_provider.dart';
import '../../providers/legal_entity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../services/user_search_service.dart';
import '../../models/user.dart';
import 'package:url_launcher/url_launcher.dart';

class CertifierManagementScreen extends StatefulWidget {
  const CertifierManagementScreen({super.key});

  @override
  State<CertifierManagementScreen> createState() =>
      _CertifierManagementScreenState();
}

class _CertifierManagementScreenState extends State<CertifierManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Form controllers
  final _userSearchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // State
  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;
  String? _selectedUserId;
  String? _selectedUserName;
  String? _selectedLegalEntityId;
  List<User> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadData() async {
    final certifierProvider = context.read<CertifierProvider>();
    final legalEntityProvider = context.read<LegalEntityProvider>();

    await Future.wait([
      certifierProvider.loadAllCertifiers(),
      legalEntityProvider.loadLegalEntities(),
    ]);
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, isTablet),
            Expanded(child: _buildContent(l10n, isTablet)),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(l10n),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
                size: isTablet ? 32 : 28,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Text(
                  'Gestione Certificatori',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Consumer<CertifierProvider>(
            builder: (context, provider, child) {
              final stats = provider.stats;
              return Row(
                children: [
                  _buildStatCard(
                    'Totale',
                    stats['total']?.toString() ?? '0',
                    Icons.people,
                    isTablet,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  _buildStatCard(
                    'Attivi',
                    stats['active']?.toString() ?? '0',
                    Icons.check_circle,
                    isTablet,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  _buildStatCard(
                    'KYC Completato',
                    stats['withKyc']?.toString() ?? '0',
                    Icons.verified,
                    isTablet,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isTablet ? 12 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, bool isTablet) {
    return Consumer<CertifierProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState(isTablet);
        }

        if (provider.errorMessage != null) {
          return _buildErrorState(provider.errorMessage!, l10n, isTablet);
        }

        return _buildCertifiersList(provider, l10n, isTablet);
      },
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: AnimatedBuilder(
        animation: _loadingAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                    strokeWidth: isTablet ? 4 : 3,
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  Text(
                    'Caricamento certificatori...',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error, AppLocalizations l10n, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
              size: isTablet ? 64 : 48,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Errore nel caricamento',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),
            NeonButton(
              text: 'Riprova',
              onPressed: _loadData,
              width: isTablet ? 200 : 150,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertifiersList(
    CertifierProvider provider,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final certifiers = provider.filteredCertifiers;

    if (certifiers.isEmpty) {
      return _buildEmptyState(l10n, isTablet);
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      itemCount: certifiers.length,
      itemBuilder: (context, index) {
        final certifier = certifiers[index];
        return _buildCertifierCard(certifier, l10n, isTablet);
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              color: AppTheme.textSecondary,
              size: isTablet ? 64 : 48,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Nessun certificatore trovato',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Aggiungi il primo certificatore per iniziare',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertifierCard(
    dynamic certifier,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      child: EnterpriseCard(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isTablet ? 24 : 20,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Text(
                      certifier.idUser?.substring(0, 2).toUpperCase() ?? 'U',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certificatore',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        Text(
                          'ID: ${certifier.idCertifier}',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(
                    certifier.active ? 'active' : 'inactive',
                    isTablet,
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
              _buildInfoRow('Legal Entity', certifier.idLegalEntity, isTablet),
              if (certifier.role != null)
                _buildInfoRow('Ruolo', certifier.role!, isTablet),
              SizedBox(height: isTablet ? 16 : 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editCertifier(certifier),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modifica'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 8),
                  TextButton.icon(
                    onPressed: () => _deleteCertifier(certifier.idCertifier),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Elimina'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isTablet) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = AppTheme.successGreen;
        text = 'Attivo';
        break;
      case 'pending':
        color = AppTheme.warningOrange;
        text = 'In attesa';
        break;
      default:
        color = AppTheme.errorRed;
        text = 'Inattivo';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: isTablet ? 12 : 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 120 : 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: _showCreateCertifierDialog,
      backgroundColor: AppTheme.primaryBlue,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Aggiungi Certificatore',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showCreateCertifierDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.person_add, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  const Text(
                    'Aggiungi Certificatore',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: isTablet ? 500 : 300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildUserSearchField(setState, isTablet),
                      const SizedBox(height: 16),
                      _buildLegalEntityDropdown(isTablet),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.errorRed.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.errorRed,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_successMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.successGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppTheme.successGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetForm();
                  },
                  child: const Text('Annulla'),
                ),
                NeonButton(
                  text: _isCreating ? 'Creando...' : 'Crea Certificatore',
                  onPressed: _isCreating ? null : _createCertifier,
                  width: 150,
                  height: 40,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserSearchField(StateSetter setState, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnterpriseTextField(
          controller: _userSearchController,
          labelText: 'Cerca Utente',
          hintText: 'Inserisci nome, email o ID utente',
          prefixIcon: Icons.search,
          onChanged: (value) => _searchUsers(value, setState),
          validator: (value) {
            if (_selectedUserId == null) {
              return 'Seleziona un utente';
            }
            return null;
          },
        ),
        if (_isSearching) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderGray),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Text(user.email ?? 'Nessuna email'),
                  onTap: () {
                    setState(() {
                      _selectedUserId = user.idUser;
                      _selectedUserName = '${user.firstName} ${user.lastName}';
                      _userSearchController.text = _selectedUserName!;
                      _searchResults.clear();
                    });
                  },
                );
              },
            ),
          ),
        ],
        if (_selectedUserId != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Utente selezionato: $_selectedUserName',
                    style: const TextStyle(
                      color: AppTheme.successGreen,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedUserId = null;
                      _selectedUserName = null;
                      _userSearchController.clear();
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.successGreen,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegalEntityDropdown(bool isTablet) {
    return Consumer<LegalEntityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CircularProgressIndicator();
        }

        final legalEntities = provider.legalEntities;

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Legal Entity',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          value: _selectedLegalEntityId,
          items: legalEntities.map((entity) {
            return DropdownMenuItem<String>(
              value: entity.idLegalEntity,
              child: Text(entity.legalName, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLegalEntityId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleziona una legal entity';
            }
            return null;
          },
        );
      },
    );
  }

  Future<void> _searchUsers(String query, StateSetter setState) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final users = await UserSearchService.searchUsers(query);
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      print('❌ Error searching users: $e');
    }
  }

  Future<void> _createCertifier() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUserId == null || _selectedLegalEntityId == null) {
      setState(() {
        _errorMessage = 'Seleziona utente e legal entity';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final certifierProvider = context.read<CertifierProvider>();
      final success = await certifierProvider.createCertifier(
        userId: _selectedUserId!,
        legalEntityId: _selectedLegalEntityId!,
        status: 'pending',
      );

      if (success) {
        setState(() {
          _successMessage = 'Certificatore creato con successo!';
        });

        // Chiudi il dialog dopo 2 secondi
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
            _resetForm();
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Errore nella creazione del certificatore';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore: $e';
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedUserId = null;
      _selectedUserName = null;
      _selectedLegalEntityId = null;
      _errorMessage = null;
      _successMessage = null;
      _isCreating = false;
      _searchResults.clear();
      _userSearchController.clear();
    });
  }

  void _editCertifier(dynamic certifier) {
    // TODO: Implementa la modifica del certificatore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funzionalità di modifica in sviluppo'),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  Future<void> _deleteCertifier(String certifierId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: const Text(
            'Sei sicuro di voler eliminare questo certificatore?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final certifierProvider = context.read<CertifierProvider>();
      final success = await certifierProvider.deleteCertifier(certifierId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificatore eliminato con successo'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nell\'eliminazione del certificatore'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
