import 'package:flutter/material.dart';
import '../../models/certification_db.dart';
import '../../services/certification_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../l10n/app_localizations.dart';

class CertificationCategoryManagementScreen extends StatefulWidget {
  final String idLegalEntity;

  const CertificationCategoryManagementScreen({
    super.key,
    required this.idLegalEntity,
  });

  @override
  State<CertificationCategoryManagementScreen> createState() => _CertificationCategoryManagementScreenState();
}

class _CertificationCategoryManagementScreenState extends State<CertificationCategoryManagementScreen> {
  final CertificationDBService _service = CertificationDBService();
  List<CertificationCategoryDB> _categories = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final categories = await _service.getCertificationCategoriesByLegalEntity(widget.idLegalEntity);
      
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createCategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCertificationCategoryScreen(
          idLegalEntity: widget.idLegalEntity,
        ),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  Future<void> _editCategory(CertificationCategoryDB category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCertificationCategoryScreen(
          idLegalEntity: widget.idLegalEntity,
          category: category,
        ),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(CertificationCategoryDB category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).getString('delete')),
        content: Text('Sei sicuro di voler eliminare la categoria "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).getString('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).getString('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteCertificationCategory(category.idCertificationCategory);
        _loadCategories();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Categoria eliminata con successo'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'eliminazione: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          'Gestione Categorie Certificazioni',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Errore nel caricamento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error,
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      LinkedInButton(
                        onPressed: _loadCategories,
                        text: 'Riprova',
                        variant: LinkedInButtonVariant.primary,
                      ),
                    ],
                  ),
                )
              : _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nessuna categoria disponibile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea la tua prima categoria di certificazione',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          LinkedInButton(
                            onPressed: _createCategory,
                            text: 'Crea Categoria',
                            icon: Icons.add,
                            variant: LinkedInButtonVariant.primary,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categorie (${_categories.length})',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                              LinkedInButton(
                                onPressed: _createCategory,
                                text: 'Nuova Categoria',
                                icon: Icons.add,
                                variant: LinkedInButtonVariant.primary,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildCategoryCard(category, l10n, isTablet),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildCategoryCard(CertificationCategoryDB category, AppLocalizations l10n, bool isTablet) {
    return LinkedInCard(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Row(
          children: [
            Container(
              width: isTablet ? 60 : 48,
              height: isTablet ? 60 : 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(category.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(category.type),
                color: _getCategoryColor(category.type),
                size: isTablet ? 30 : 24,
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCategoryTypeLabel(category.type),
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (category.order != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ordine: ${category.order}',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editCategory(category);
                    break;
                  case 'delete':
                    _deleteCategory(category);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text('Modifica'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppTheme.errorRed),
                      const SizedBox(width: 8),
                      Text('Elimina'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(CertificationCategoryType type) {
    switch (type) {
      case CertificationCategoryType.course:
        return AppTheme.primaryBlue;
      case CertificationCategoryType.workshop:
        return AppTheme.successGreen;
      case CertificationCategoryType.seminar:
        return AppTheme.warningOrange;
      case CertificationCategoryType.exam:
        return AppTheme.errorRed;
      case CertificationCategoryType.other:
        return AppTheme.textSecondary;
    }
  }

  IconData _getCategoryIcon(CertificationCategoryType type) {
    switch (type) {
      case CertificationCategoryType.course:
        return Icons.school;
      case CertificationCategoryType.workshop:
        return Icons.build;
      case CertificationCategoryType.seminar:
        return Icons.groups;
      case CertificationCategoryType.exam:
        return Icons.quiz;
      case CertificationCategoryType.other:
        return Icons.category;
    }
  }

  String _getCategoryTypeLabel(CertificationCategoryType type) {
    switch (type) {
      case CertificationCategoryType.course:
        return 'Corso';
      case CertificationCategoryType.workshop:
        return 'Workshop';
      case CertificationCategoryType.seminar:
        return 'Seminario';
      case CertificationCategoryType.exam:
        return 'Esame';
      case CertificationCategoryType.other:
        return 'Altro';
    }
  }
}

class CreateCertificationCategoryScreen extends StatefulWidget {
  final String idLegalEntity;
  final CertificationCategoryDB? category;

  const CreateCertificationCategoryScreen({
    super.key,
    required this.idLegalEntity,
    this.category,
  });

  @override
  State<CreateCertificationCategoryScreen> createState() => _CreateCertificationCategoryScreenState();
}

class _CreateCertificationCategoryScreenState extends State<CreateCertificationCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _orderController = TextEditingController();
  CertificationCategoryType _selectedType = CertificationCategoryType.course;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _orderController.text = widget.category!.order?.toString() ?? '';
      _selectedType = widget.category!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final category = CertificationCategoryDB(
        idCertificationCategory: widget.category?.idCertificationCategory ?? '',
        name: _nameController.text.trim(),
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        type: _selectedType,
        order: _orderController.text.isNotEmpty ? int.tryParse(_orderController.text) : null,
        idLegalEntity: widget.idLegalEntity,
      );

      if (widget.category != null) {
        await CertificationDBService().updateCertificationCategory(category);
      } else {
        await CertificationDBService().createCertificationCategory(category);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.category != null ? 'Categoria aggiornata' : 'Categoria creata'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          widget.category != null ? 'Modifica Categoria' : 'Nuova Categoria',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Informazioni Categoria',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Definisci i dettagli della categoria di certificazione',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              LinkedInTextField(
                controller: _nameController,
                label: 'Nome Categoria',
                hintText: 'Es. Corso di Programmazione',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci il nome della categoria';
                  }
                  return null;
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              DropdownButtonFormField<CertificationCategoryType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipo Categoria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                items: CertificationCategoryType.values.map((type) {
                  return DropdownMenuItem<CertificationCategoryType>(
                    value: type,
                    child: Text(_getCategoryTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              LinkedInTextField(
                controller: _orderController,
                label: 'Ordine (opzionale)',
                hintText: '1, 2, 3...',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final order = int.tryParse(value);
                    if (order == null || order < 0) {
                      return 'Inserisci un numero valido';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: isTablet ? 40 : 32),

              LinkedInButton(
                onPressed: _isLoading ? null : _saveCategory,
                text: _isLoading ? 'Salvataggio...' : 'Salva Categoria',
                icon: Icons.save,
                variant: LinkedInButtonVariant.primary,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryTypeLabel(CertificationCategoryType type) {
    switch (type) {
      case CertificationCategoryType.course:
        return 'Corso';
      case CertificationCategoryType.workshop:
        return 'Workshop';
      case CertificationCategoryType.seminar:
        return 'Seminario';
      case CertificationCategoryType.exam:
        return 'Esame';
      case CertificationCategoryType.other:
        return 'Altro';
    }
  }
}
