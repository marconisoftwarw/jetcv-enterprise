import 'package:flutter/material.dart';
import '../../models/certification_db.dart';
import '../../services/certification_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../l10n/app_localizations.dart';

class CertificationUserManagementScreen extends StatefulWidget {
  final String idCertification;

  const CertificationUserManagementScreen({
    super.key,
    required this.idCertification,
  });

  @override
  State<CertificationUserManagementScreen> createState() => _CertificationUserManagementScreenState();
}

class _CertificationUserManagementScreenState extends State<CertificationUserManagementScreen> {
  final CertificationDBService _service = CertificationDBService();
  List<CertificationUserDB> _users = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final users = await _service.getCertificationUsersByCertification(widget.idCertification);
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCertificationUserScreen(
          idCertification: widget.idCertification,
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _editUser(CertificationUserDB user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCertificationUserScreen(
          idCertification: widget.idCertification,
          user: user,
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _deleteUser(CertificationUserDB user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).getString('delete')),
        content: Text('Sei sicuro di voler rimuovere questo utente dalla certificazione?'),
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
        await _service.deleteCertificationUser(user.idCertificationUser);
        _loadUsers();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Utente rimosso con successo'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nella rimozione: $e'),
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
          'Gestione Utenti Certificazione',
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
                        onPressed: _loadUsers,
                        text: 'Riprova',
                        variant: LinkedInButtonVariant.primary,
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nessun utente aggiunto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aggiungi utenti alla certificazione',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          LinkedInButton(
                            onPressed: _addUser,
                            text: 'Aggiungi Utente',
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
                                'Utenti (${_users.length})',
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                              LinkedInButton(
                                onPressed: _addUser,
                                text: 'Aggiungi Utente',
                                icon: Icons.add,
                                variant: LinkedInButtonVariant.primary,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildUserCard(user, l10n, isTablet),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildUserCard(CertificationUserDB user, AppLocalizations l10n, bool isTablet) {
    return LinkedInCard(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: isTablet ? 30 : 24,
              backgroundColor: _getStatusColor(user.status).withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: _getStatusColor(user.status),
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utente ${user.idUser.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Serial: ${user.serialNumber}',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 8,
                          vertical: isTablet ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(user.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusLabel(user.status),
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: _getStatusColor(user.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (user.rejectionReason != null) ...[
                        SizedBox(width: isTablet ? 8 : 4),
                        Icon(
                          Icons.info_outline,
                          size: isTablet ? 16 : 14,
                          color: AppTheme.warningOrange,
                        ),
                      ],
                    ],
                  ),
                  if (user.rejectionReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Motivo: ${user.rejectionReason}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: AppTheme.warningOrange,
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
                    _editUser(user);
                    break;
                  case 'delete':
                    _deleteUser(user);
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
                      Text('Rimuovi'),
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

  Color _getStatusColor(CertificationUserStatus status) {
    switch (status) {
      case CertificationUserStatus.draft:
        return AppTheme.textSecondary;
      case CertificationUserStatus.accepted:
        return AppTheme.successGreen;
      case CertificationUserStatus.rejected:
        return AppTheme.errorRed;
    }
  }

  String _getStatusLabel(CertificationUserStatus status) {
    switch (status) {
      case CertificationUserStatus.draft:
        return 'Bozza';
      case CertificationUserStatus.accepted:
        return 'Accettata';
      case CertificationUserStatus.rejected:
        return 'Rifiutata';
    }
  }
}

class AddCertificationUserScreen extends StatefulWidget {
  final String idCertification;
  final CertificationUserDB? user;

  const AddCertificationUserScreen({
    super.key,
    required this.idCertification,
    this.user,
  });

  @override
  State<AddCertificationUserScreen> createState() => _AddCertificationUserScreenState();
}

class _AddCertificationUserScreenState extends State<AddCertificationUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _otpIdController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  CertificationUserStatus _selectedStatus = CertificationUserStatus.draft;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _userIdController.text = widget.user!.idUser;
      _otpIdController.text = widget.user!.idOtp;
      _rejectionReasonController.text = widget.user!.rejectionReason ?? '';
      _selectedStatus = widget.user!.status;
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _otpIdController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = CertificationUserDB(
        idCertificationUser: widget.user?.idCertificationUser ?? '',
        idCertification: widget.idCertification,
        idUser: _userIdController.text.trim(),
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        status: _selectedStatus,
        serialNumber: widget.user?.serialNumber ?? 'SN-${DateTime.now().millisecondsSinceEpoch}',
        rejectionReason: _rejectionReasonController.text.trim().isNotEmpty ? _rejectionReasonController.text.trim() : null,
        idOtp: _otpIdController.text.trim(),
      );

      if (widget.user != null) {
        await CertificationDBService().updateCertificationUser(user);
      } else {
        await CertificationDBService().createCertificationUser(user);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user != null ? 'Utente aggiornato' : 'Utente aggiunto'),
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
          widget.user != null ? 'Modifica Utente' : 'Aggiungi Utente',
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
                'Dettagli Utente',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Aggiungi un utente alla certificazione',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              LinkedInTextField(
                controller: _userIdController,
                label: 'ID Utente',
                hintText: 'UUID dell\'utente',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci l\'ID utente';
                  }
                  return null;
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              LinkedInTextField(
                controller: _otpIdController,
                label: 'ID OTP',
                hintText: 'UUID dell\'OTP',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci l\'ID OTP';
                  }
                  return null;
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              DropdownButtonFormField<CertificationUserStatus>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Stato',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
                items: CertificationUserStatus.values.map((status) {
                  return DropdownMenuItem<CertificationUserStatus>(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              SizedBox(height: isTablet ? 20 : 16),

              if (_selectedStatus == CertificationUserStatus.rejected) ...[
                LinkedInTextField(
                  controller: _rejectionReasonController,
                  label: 'Motivo Rifiuto',
                  hintText: 'Spiega perché è stata rifiutata',
                  maxLines: 3,
                  validator: (value) {
                    if (_selectedStatus == CertificationUserStatus.rejected && 
                        (value == null || value.isEmpty)) {
                      return 'Inserisci il motivo del rifiuto';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isTablet ? 20 : 16),
              ],

              LinkedInButton(
                onPressed: _isLoading ? null : _saveUser,
                text: _isLoading ? 'Salvataggio...' : 'Salva Utente',
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

  String _getStatusLabel(CertificationUserStatus status) {
    switch (status) {
      case CertificationUserStatus.draft:
        return 'Bozza';
      case CertificationUserStatus.accepted:
        return 'Accettata';
      case CertificationUserStatus.rejected:
        return 'Rifiutata';
    }
  }
}
