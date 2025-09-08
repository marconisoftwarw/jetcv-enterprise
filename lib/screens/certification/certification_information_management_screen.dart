import 'package:flutter/material.dart';
import '../../models/certification_db.dart';
import '../../services/certification_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../l10n/app_localizations.dart';

class CertificationInformationManagementScreen extends StatefulWidget {
  final String idLegalEntity;

  const CertificationInformationManagementScreen({
    super.key,
    required this.idLegalEntity,
  });

  @override
  State<CertificationInformationManagementScreen> createState() => _CertificationInformationManagementScreenState();
}

class _CertificationInformationManagementScreenState extends State<CertificationInformationManagementScreen> {
  final CertificationDBService _service = CertificationDBService();
  List<CertificationInformationDB> _informations = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadInformations();
  }

  Future<void> _loadInformations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final informations = await _service.getCertificationInformationsByLegalEntity(widget.idLegalEntity);
      
      setState(() {
        _informations = informations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createInformation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCertificationInformationScreen(
          idLegalEntity: widget.idLegalEntity,
        ),
      ),
    );

    if (result == true) {
      _loadInformations();
    }
  }

  Future<void> _editInformation(CertificationInformationDB information) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCertificationInformationScreen(
          idLegalEntity: widget.idLegalEntity,
          information: information,
        ),
      ),
    );

    if (result == true) {
      _loadInformations();
    }
  }

  Future<void> _deleteInformation(CertificationInformationDB information) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).getString('delete')),
        content: Text('Sei sicuro di voler eliminare l\'informazione "${information.name}"?'),
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
        await _service.deleteCertificationInformation(information.idCertificationInformation);
        _loadInformations();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Informazione eliminata con successo'),
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
          'Gestione Informazioni Certificazioni',
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
                        onPressed: _loadInformations,
                        text: 'Riprova',
                        variant: LinkedInButtonVariant.primary,
                      ),
                    ],
                  ),
                )
              : _informations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nessuna informazione disponibile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea la tua prima informazione di certificazione',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          LinkedInButton(
                            onPressed: _createInformation,
                            text: 'Crea Informazione',
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
                                'Informazioni (${_informations.length})',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                              LinkedInButton(
                                onPressed: _createInformation,
                                text: 'Nuova Informazione',
                                icon: Icons.add,
                                variant: LinkedInButtonVariant.primary,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                            itemCount: _informations.length,
                            itemBuilder: (context, index) {
                              final information = _informations[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildInformationCard(information, l10n, isTablet),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildInformationCard(CertificationInformationDB information, AppLocalizations l10n, bool isTablet) {
    return LinkedInCard(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Row(
          children: [
            Container(
              width: isTablet ? 60 : 48,
              height: isTablet ? 60 : 48,
              decoration: BoxDecoration(
                color: _getInformationColor(information.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getInformationIcon(information.type),
                color: _getInformationColor(information.type),
                size: isTablet ? 30 : 24,
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    information.name,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    information.label,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (information.type != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getInformationTypeLabel(information.type!),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (information.scope != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getInformationScopeLabel(information.scope!),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (information.order != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Ordine: ${information.order}',
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
                    _editInformation(information);
                    break;
                  case 'delete':
                    _deleteInformation(information);
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

  Color _getInformationColor(CertificationInformationType? type) {
    switch (type) {
      case CertificationInformationType.text:
        return AppTheme.primaryBlue;
      case CertificationInformationType.number:
        return AppTheme.successGreen;
      case CertificationInformationType.date:
        return AppTheme.warningOrange;
      case CertificationInformationType.boolean:
        return AppTheme.errorRed;
      case CertificationInformationType.file:
        return AppTheme.primaryBlack;
      case null:
        return AppTheme.textSecondary;
    }
  }

  IconData _getInformationIcon(CertificationInformationType? type) {
    switch (type) {
      case CertificationInformationType.text:
        return Icons.text_fields;
      case CertificationInformationType.number:
        return Icons.numbers;
      case CertificationInformationType.date:
        return Icons.calendar_today;
      case CertificationInformationType.boolean:
        return Icons.toggle_on;
      case CertificationInformationType.file:
        return Icons.attach_file;
      case null:
        return Icons.info;
    }
  }

  String _getInformationTypeLabel(CertificationInformationType type) {
    switch (type) {
      case CertificationInformationType.text:
        return 'Testo';
      case CertificationInformationType.number:
        return 'Numero';
      case CertificationInformationType.date:
        return 'Data';
      case CertificationInformationType.boolean:
        return 'Sì/No';
      case CertificationInformationType.file:
        return 'File';
    }
  }

  String _getInformationScopeLabel(CertificationInformationScope scope) {
    switch (scope) {
      case CertificationInformationScope.general:
        return 'Generale';
      case CertificationInformationScope.user:
        return 'Utente';
    }
  }
}

class CreateCertificationInformationScreen extends StatefulWidget {
  final String idLegalEntity;
  final CertificationInformationDB? information;

  const CreateCertificationInformationScreen({
    super.key,
    required this.idLegalEntity,
    this.information,
  });

  @override
  State<CreateCertificationInformationScreen> createState() => _CreateCertificationInformationScreenState();
}

class _CreateCertificationInformationScreenState extends State<CreateCertificationInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final _orderController = TextEditingController();
  CertificationInformationType? _selectedType;
  CertificationInformationScope? _selectedScope;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.information != null) {
      _nameController.text = widget.information!.name;
      _labelController.text = widget.information!.label;
      _orderController.text = widget.information!.order?.toString() ?? '';
      _selectedType = widget.information!.type;
      _selectedScope = widget.information!.scope;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveInformation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final information = CertificationInformationDB(
        idCertificationInformation: widget.information?.idCertificationInformation ?? '',
        name: _nameController.text.trim(),
        order: _orderController.text.isNotEmpty ? int.tryParse(_orderController.text) : null,
        createdAt: widget.information?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        label: _labelController.text.trim(),
        type: _selectedType,
        idLegalEntity: widget.idLegalEntity,
        scope: _selectedScope,
      );

      if (widget.information != null) {
        await CertificationDBService().updateCertificationInformation(information);
      } else {
        await CertificationDBService().createCertificationInformation(information);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.information != null ? 'Informazione aggiornata' : 'Informazione creata'),
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
          widget.information != null ? 'Modifica Informazione' : 'Nuova Informazione',
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
                'Informazioni Campo',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Definisci i dettagli del campo di informazione',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              LinkedInTextField(
                controller: _nameController,
                label: 'Nome Campo',
                hintText: 'Es. durata_corso',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci il nome del campo';
                  }
                  return null;
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              LinkedInTextField(
                controller: _labelController,
                label: 'Etichetta',
                hintText: 'Es. Durata del Corso',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci l\'etichetta del campo';
                  }
                  return null;
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              DropdownButtonFormField<CertificationInformationType?>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipo Campo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                items: [
                  DropdownMenuItem<CertificationInformationType?>(
                    value: null,
                    child: Text('Seleziona tipo'),
                  ),
                  ...CertificationInformationType.values.map((type) {
                    return DropdownMenuItem<CertificationInformationType?>(
                      value: type,
                      child: Text(_getInformationTypeLabel(type)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              DropdownButtonFormField<CertificationInformationScope?>(
                value: _selectedScope,
                decoration: InputDecoration(
                  labelText: 'Ambito',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                items: [
                  DropdownMenuItem<CertificationInformationScope?>(
                    value: null,
                    child: Text('Seleziona ambito'),
                  ),
                  ...CertificationInformationScope.values.map((scope) {
                    return DropdownMenuItem<CertificationInformationScope?>(
                      value: scope,
                      child: Text(_getInformationScopeLabel(scope)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedScope = value;
                  });
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
                onPressed: _isLoading ? null : _saveInformation,
                text: _isLoading ? 'Salvataggio...' : 'Salva Informazione',
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

  String _getInformationTypeLabel(CertificationInformationType type) {
    switch (type) {
      case CertificationInformationType.text:
        return 'Testo';
      case CertificationInformationType.number:
        return 'Numero';
      case CertificationInformationType.date:
        return 'Data';
      case CertificationInformationType.boolean:
        return 'Sì/No';
      case CertificationInformationType.file:
        return 'File';
    }
  }

  String _getInformationScopeLabel(CertificationInformationScope scope) {
    switch (scope) {
      case CertificationInformationScope.general:
        return 'Generale';
      case CertificationInformationScope.user:
        return 'Utente';
    }
  }
}
