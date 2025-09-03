import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_text_field.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _jobTitleController;
  late TextEditingController _departmentController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;

  bool _isEditing = false;
  bool _isLoading = false;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _currentUser = user;
      _firstNameController = TextEditingController(text: user.firstName ?? '');
      _lastNameController = TextEditingController(text: user.lastName ?? '');
      _phoneController = TextEditingController(text: user.phone ?? '');
      _jobTitleController = TextEditingController(text: 'Non specificato');
      _departmentController = TextEditingController(text: 'Non specificato');
      _addressController = TextEditingController(text: user.address ?? '');
      _cityController = TextEditingController(text: user.city ?? '');
      _zipCodeController = TextEditingController(text: 'Non specificato');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profilo Utente',
          style: AppTheme.title1.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              tooltip: 'Salva modifiche',
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _initializeControllers(); // Reset to original values
                }
              });
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Annulla' : 'Modifica',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con foto profilo e informazioni principali
                _buildProfileHeader(authProvider.currentUser!),

                const SizedBox(height: 32),

                // Form per le informazioni personali
                _buildPersonalInfoForm(),

                const SizedBox(height: 32),

                // Informazioni aziendali
                _buildCompanyInfoSection(authProvider.currentUser!),

                const SizedBox(height: 32),

                // Statistiche e attività
                _buildStatsSection(authProvider.currentUser!),

                const SizedBox(height: 32),

                // Azioni rapide
                _buildQuickActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return LinkedInCard(
      child: Column(
        children: [
          Row(
            children: [
              // Foto profilo
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.lightBlue,
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture == null
                    ? Text(
                        user.initials,
                        style: AppTheme.headline2.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 24),

              // Informazioni principali
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: AppTheme.headline2),
                    const SizedBox(height: 8),
                    Text(
                      'Non specificato',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Non specificato',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'Non specificato',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryBlack,
                      ).copyWith(color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 16),

                    // Badge ruolo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Utente',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_isEditing) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Upload foto profilo
            Row(
              children: [
                LinkedInButton(
                  onPressed: _uploadProfilePicture,
                  text: 'Cambia Foto Profilo',
                  icon: Icons.camera_alt,
                  variant: LinkedInButtonVariant.outline,
                ),
                const SizedBox(width: 16),
                LinkedInButton(
                  onPressed: _removeProfilePicture,
                  text: 'Rimuovi Foto',
                  icon: Icons.delete,
                  variant: LinkedInButtonVariant.danger,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informazioni Personali', style: AppTheme.title1),
          const SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinkedInTextField(
                        label: 'Nome',
                        controller: _firstNameController,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Il nome è obbligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinkedInTextField(
                        label: 'Cognome',
                        controller: _lastNameController,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Il cognome è obbligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: LinkedInTextField(
                        label: 'Telefono',
                        controller: _phoneController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinkedInTextField(
                        label: 'Data di Nascita',
                        enabled: false,
                        initialValue:
                            _currentUser?.dateOfBirth?.toString() ??
                            'Non specificata',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: LinkedInTextField(
                        label: 'Indirizzo',
                        controller: _addressController,
                        enabled: _isEditing,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: LinkedInTextField(
                        label: 'Città',
                        controller: _cityController,
                        enabled: _isEditing,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinkedInTextField(
                        label: 'CAP',
                        controller: _zipCodeController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoSection(AppUser user) {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informazioni Aziendali', style: AppTheme.title1),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: LinkedInTextField(
                  label: 'Ruolo Aziendale',
                  controller: _jobTitleController,
                  enabled: _isEditing,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinkedInTextField(
                  label: 'Dipartimento',
                  controller: _departmentController,
                  enabled: _isEditing,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informazioni sull'entità legale
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Row(
              children: [
                Icon(Icons.business, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entità Legale Associata',
                        style: AppTheme.body2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: Non specificato',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryBlack,
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
    );
  }

  Widget _buildStatsSection(AppUser user) {
    return Row(
      children: [
        Expanded(
          child: LinkedInMetricCard(
            title: 'Certificazioni',
            value: '0',
            icon: Icons.verified,
            iconColor: AppTheme.successGreen,
            change: '+0',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LinkedInMetricCard(
            title: 'Ultimo Accesso',
            value: 'Mai',
            icon: Icons.access_time,
            iconColor: AppTheme.primaryBlue,
            subtitle: 'Ultima attività',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: LinkedInMetricCard(
            title: 'Stato Account',
            value: 'Attivo',
            icon: Icons.check_circle,
            iconColor: AppTheme.successGreen,
            subtitle: 'Non verificato',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Azioni Rapide', style: AppTheme.title1),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: LinkedInActionCard(
                  title: 'Cambia Password',
                  description: 'Aggiorna la password del tuo account',
                  icon: Icons.lock,
                  iconColor: AppTheme.warningOrange,
                  onTap: _changePassword,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinkedInActionCard(
                  title: 'Impostazioni Notifiche',
                  description: 'Gestisci le preferenze di notifica',
                  icon: Icons.notifications,
                  iconColor: AppTheme.accentBlue,
                  onTap: _openNotificationSettings,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: LinkedInActionCard(
                  title: 'Esporta Dati',
                  description: 'Scarica i tuoi dati personali',
                  icon: Icons.download,
                  iconColor: AppTheme.secondaryBlue,
                  onTap: _exportData,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinkedInActionCard(
                  title: 'Elimina Account',
                  description: 'Rimuovi definitivamente il tuo account',
                  icon: Icons.delete_forever,
                  iconColor: AppTheme.errorRed,
                  onTap: _deleteAccount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Metodi per le azioni
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implementare il salvataggio del profilo
      await Future.delayed(const Duration(seconds: 1)); // Simulazione

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profilo aggiornato con successo!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante il salvataggio: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _uploadProfilePicture() {
    // TODO: Implementare upload foto profilo
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _removeProfilePicture() {
    // TODO: Implementare rimozione foto profilo
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _changePassword() {
    // TODO: Implementare cambio password
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _openNotificationSettings() {
    // TODO: Implementare impostazioni notifiche
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _exportData() {
    // TODO: Implementare esportazione dati
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }

  void _deleteAccount() {
    // TODO: Implementare eliminazione account
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Funzionalità in sviluppo')));
  }
}
