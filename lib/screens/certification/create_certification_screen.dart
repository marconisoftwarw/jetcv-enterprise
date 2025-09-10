import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../widgets/linkedin_button.dart';
import '../../widgets/linkedin_card.dart';
import '../../widgets/linkedin_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../../services/certification_edge_service.dart';
import '../../services/certification_category_service.dart';
import '../../services/default_ids_service.dart';
import '../../config/app_config.dart';

class CreateCertificationScreen extends StatefulWidget {
  const CreateCertificationScreen({super.key});

  @override
  State<CreateCertificationScreen> createState() =>
      _CreateCertificationScreenState();
}

class _CreateCertificationScreenState extends State<CreateCertificationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Form data
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedActivityType = 'Corso Specifico';
  List<File> _mediaFiles = [];

  // API state
  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;

  final List<String> _activityTypes = [
    'Corso Specifico',
    'Workshop',
    'Seminario',
    'Formazione Online',
    'Esame',
    'Altro',
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentStep = _pageController.page?.round() ?? 0;
      });
    });

    // Inizializza le categorie predefinite
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    try {
      await CertificationCategoryService.createDefaultCategories();
    } catch (e) {
      print('❌ Error initializing categories: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          l10n.getString('new_certification'),
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
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildGeneralInfoStep(),
                _buildUsersStep(),
                _buildResultsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      color: AppTheme.pureWhite,
      child: Row(
        children: [
          _buildStepIndicator(
            0,
            l10n.getString('general_info'),
            _currentStep >= 0,
            isTablet,
          ),
          _buildStepConnector(),
          _buildStepIndicator(
            1,
            l10n.getString('users'),
            _currentStep >= 1,
            isTablet,
          ),
          _buildStepConnector(),
          _buildStepIndicator(
            2,
            l10n.getString('results'),
            _currentStep >= 2,
            isTablet,
          ),
          _buildStepConnector(),
          _buildStepIndicator(
            3,
            l10n.getString('review'),
            _currentStep >= 3,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int stepNumber,
    String label,
    bool isActive,
    bool isTablet,
  ) {
    return Column(
      children: [
        Container(
          width: isTablet ? 40 : 32,
          height: isTablet ? 40 : 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlack : AppTheme.lightGrey,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? Icon(
                    Icons.check,
                    color: AppTheme.pureWhite,
                    size: isTablet ? 24 : 20,
                  )
                : Text(
                    '${stepNumber + 1}',
                    style: TextStyle(
                      color: AppTheme.primaryBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
          ),
        ),
        SizedBox(height: isTablet ? 6 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: isActive ? AppTheme.primaryBlack : AppTheme.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Expanded(
      child: Container(
        height: isTablet ? 3 : 2,
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8),
        color: AppTheme.lightGrey,
      ),
    );
  }

  Widget _buildGeneralInfoStep() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.getString('general_information'),
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              l10n.getString('enter_main_details'),
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            LinkedInTextField(
              controller: _titleController,
              label: l10n.getString('certification_title'),
              hintText: l10n.getString('certification_title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il titolo della certificazione';
                }
                return null;
              },
            ),
            SizedBox(height: isTablet ? 20 : 16),

            LinkedInTextField(
              label: l10n.getString('issuing_organization'),
              initialValue: l10n.getString('my_legal_entity'),
              enabled: false,
            ),
            SizedBox(height: isTablet ? 20 : 16),

            DropdownButtonFormField<String>(
              value: _selectedActivityType,
              decoration: InputDecoration(
                labelText: l10n.getString('activity_type'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isTablet ? 16 : 12,
                ),
              ),
              items: _activityTypes.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedActivityType = newValue!;
                });
              },
            ),
            SizedBox(height: isTablet ? 20 : 16),

            LinkedInTextField(
              controller: _descriptionController,
              label: l10n.getString('description'),
              hintText: l10n.getString('description'),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci una descrizione';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            _buildMediaSection(),
            SizedBox(height: isTablet ? 40 : 32),

            LinkedInButton(
              onPressed: _nextStep,
              text: l10n.getString('continue'),
              icon: Icons.arrow_forward,
              variant: LinkedInButtonVariant.primary,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.getString('media_photos_videos'),
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              LinkedInButton(
                onPressed: _addMedia,
                text: '+ ${l10n.getString('add')}',
                variant: LinkedInButtonVariant.outline,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Container(
            height: isTablet ? 140 : 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderGrey,
                style: BorderStyle.solid,
              ),
            ),
            child: _mediaFiles.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: isTablet ? 56 : 48,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        l10n.getString('add_photos_videos'),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _mediaFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _mediaFiles[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeMedia(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: AppTheme.pureWhite,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersStep() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.getString('add_users'),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            l10n.getString('enter_participants'),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          _buildAddUserSection(),
          const SizedBox(height: 24),

          _buildUsersList(),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: LinkedInButton(
                  onPressed: _previousStep,
                  text: 'Indietro',
                  variant: LinkedInButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinkedInButton(
                  onPressed: _nextStep,
                  text: 'Continua alla Revisione',
                  icon: Icons.arrow_forward,
                  variant: LinkedInButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserSection() {
    return LinkedInCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinkedInTextField(
                  label: 'Inserisci codice OTP utente',
                  hintText: 'Inserisci codice OT...',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(width: 12),
              LinkedInButton(
                onPressed: _addUserByOTP,
                text: 'Aggiungi',
                variant: LinkedInButtonVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(height: 1, color: AppTheme.borderGrey, width: 100),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'oppure',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              Expanded(child: Container(height: 1, color: AppTheme.borderGrey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.qr_code, size: 48, color: AppTheme.primaryBlue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scansiona codice QR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      'Scansiona il QR code dall\'app utente',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              LinkedInButton(
                onPressed: _scanQRCode,
                text: 'Scansiona',
                icon: Icons.qr_code_scanner,
                variant: LinkedInButtonVariant.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    // Mock data - in real app this would come from state
    final users = [
      {
        'name': 'Marco Bianchi',
        'email': 'marco.bianchi@email.it',
        'location': 'Milano, Italia',
        'avatar': 'https://via.placeholder.com/40',
      },
      {
        'name': 'Simone Moretti',
        'email': 'simone.moretti@email.it',
        'location': 'Firenze, Italia',
        'avatar': 'https://via.placeholder.com/40',
      },
    ];

    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Utenti Aggiunti (${users.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              TextButton.icon(
                onPressed: _removeAllUsers,
                icon: Icon(Icons.clear_all, size: 16),
                label: Text('Rimuovi Tutti'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...users.map((user) => _buildUserItem(user)).toList(),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, String> user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(user['avatar']!),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                Text(
                  user['email']!,
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user['location']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeUser(user),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove, color: AppTheme.pureWhite, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsStep() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.getString('user_results'),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            l10n.getString('enter_results_for_each'),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            l10n.getString('fill_fields_for_participants'),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          _buildUserResultsCard(),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: LinkedInButton(
                  onPressed: _previousStep,
                  text: l10n.getString('back'),
                  variant: LinkedInButtonVariant.outline,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: LinkedInButton(
                  onPressed: _nextStep,
                  text: l10n.getString('continue_to_review'),
                  icon: Icons.arrow_forward,
                  variant: LinkedInButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserResultsCard() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://via.placeholder.com/48'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giulia Rossi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      'giulia.rossi@email.it',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: LinkedInTextField(
                  label: 'Risultato',
                  initialValue: 'Superato',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinkedInTextField(
                  label: 'Punteggio',
                  initialValue: '90/100',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinkedInTextField(
                  label: 'Valutazione',
                  initialValue: 'A+',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Media (Foto e Video)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMediaThumbnail(),
              const SizedBox(width: 12),
              _buildMediaThumbnail(),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _addMedia,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderGrey,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '+ Aggiungi',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnail() {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage('https://via.placeholder.com/60'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {}, // Remove media
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: AppTheme.pureWhite, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.getString('certification_review'),
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            l10n.getString('check_details_before_sending'),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          _buildReviewCard(),
          const SizedBox(height: 16),
          _buildMediaReviewCard(),
          const SizedBox(height: 16),
          _buildUsersReviewCard(),
          const SizedBox(height: 16),
          _buildConfirmationCard(),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: LinkedInButton(
                  onPressed: _previousStep,
                  text: l10n.getString('back'),
                  variant: LinkedInButtonVariant.outline,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: LinkedInButton(
                  onPressed: _sendCertification,
                  text: l10n.getString('send_certification'),
                  icon: Icons.send,
                  variant: LinkedInButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Informazioni Generali',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewItem('Titolo', 'Corso Platform Management in-place'),
          _buildReviewItem('Organizzazione', 'La mia Legal Entity'),
          _buildReviewItem(
            'Descrizione',
            'I partecipanti apprenderanno le modalità specifiche della gestione di una piattaforma in loco.',
          ),
        ],
      ),
    );
  }

  Widget _buildMediaReviewCard() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Media Real-time (0)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun media generale allegato',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersReviewCard() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Utenti (1)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://via.placeholder.com/40'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giulia Rossi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      'giulia.rossi@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildReviewItem('Risultato', 'Superato'),
                _buildReviewItem('Punteggio', 'A+'),
                _buildReviewItem('Valutazione', 'Non valutato'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Media del Certificatore (2)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMediaThumbnail(),
              const SizedBox(width: 8),
              _buildMediaThumbnail(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard() {
    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: AppTheme.warningOrange),
              const SizedBox(width: 8),
              Text(
                'Conferma Invio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Una volta inviata, la certificazione verrà inviata agli utenti destinatari e non sarà più modificabile. Una volta che gli utenti accetteranno la certificazione, questa verrà notarizzata sulla blockchain. Questa azione non può essere annullata.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: false, // This should be managed by state
                onChanged: (value) {
                  // Handle checkbox change
                },
              ),
              Expanded(
                child: Text(
                  'Confermo di aver verificato tutti i dettagli e di voler procedere con l\'invio della certificazione',
                  style: TextStyle(fontSize: 14, color: AppTheme.primaryBlack),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createCertification() async {
    print('🚀 Creating certification...');

    setState(() {
      _isCreating = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Ottieni l'ID della categoria
      final categoryId = await CertificationCategoryService.getCategoryIdByName(
        _selectedActivityType,
      );
      if (categoryId == null) {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Categoria non trovata: $_selectedActivityType';
        });
        return;
      }

      // Ottieni gli ID di default
      final certifierId = await DefaultIdsService.getDefaultCertifierId();
      final legalEntityId = await DefaultIdsService.getDefaultLegalEntityId();
      final locationId = await DefaultIdsService.getDefaultLocationId();

      if (certifierId == null || legalEntityId == null || locationId == null) {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Errore nel recupero degli ID di default';
        });
        return;
      }

      // Prepara i dati della certificazione
      final certificationData = {
        'id_certifier': certifierId,
        'id_legal_entity': legalEntityId,
        'id_location': locationId,
        'n_users': 1, // Default value
        'id_certification_category': categoryId,
        'status': 'draft',
        'draft_at': DateTime.now().toIso8601String(),
      };

      print('📋 Certification data: $certificationData');

      // Crea la certificazione
      final result = await CertificationEdgeService.createCertification(
        idCertifier: certificationData['id_certifier'] as String,
        idLegalEntity: certificationData['id_legal_entity'] as String,
        idLocation: certificationData['id_location'] as String,
        nUsers: certificationData['n_users'] as int,
        idCertificationCategory: "126fa831-c3ce-4f12-bfc3-600c24bc25a7",
        status: certificationData['status'] as String?,
        draftAt: certificationData['draft_at'] as String?,
      );

      if (result != null) {
        print('✅ Certification created successfully: $result');

        // Se ci sono media files, aggiungili
        if (_mediaFiles.isNotEmpty) {
          await _addMediaToCertification(result['id_certification']);
        }

        setState(() {
          _successMessage = 'Certificazione creata con successo!';
          _isCreating = false;
        });

        // Mostra messaggio di successo e chiudi
        _showSuccessDialog();
      } else {
        throw Exception('Failed to create certification');
      }
    } catch (e) {
      print('💥 Error creating certification: $e');
      setState(() {
        _errorMessage = 'Errore nella creazione della certificazione: $e';
        _isCreating = false;
      });
    }
  }

  Future<void> _addMediaToCertification(String certificationId) async {
    try {
      print('📸 Adding media to certification: $certificationId');

      // Ottieni l'ID di location di default
      final locationId = await DefaultIdsService.getDefaultLocationId();
      if (locationId == null) {
        print('❌ Could not get default location ID');
        return;
      }

      final mediaData = _mediaFiles
          .map(
            (file) => {
              'name': file.path.split('/').last,
              'description': 'Media file for certification',
              'acquisition_type': 'camera',
              'captured_at': DateTime.now().toIso8601String(),
              'file_type': file.path.split('.').last,
              'id_location': locationId,
            },
          )
          .toList();

      final result = await CertificationEdgeService.addCertificationMedia(
        certificationId: certificationId,
        media: mediaData,
      );

      print('✅ Media added successfully: ${result.length} files');
    } catch (e) {
      print('💥 Error adding media: $e');
      // Non bloccare la creazione della certificazione per errori sui media
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successGreen),
            const SizedBox(width: 8),
            const Text('Successo'),
          ],
        ),
        content: Text(_successMessage ?? 'Certificazione creata con successo!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi dialog
              Navigator.of(context).pop(); // Chiudi screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mediaFiles.add(File(image.path));
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  void _addUserByOTP() {
    // Implement OTP user addition
  }

  void _scanQRCode() {
    // Implement QR code scanning
  }

  void _removeUser(Map<String, String> user) {
    // Implement user removal
  }

  void _removeAllUsers() {
    // Implement remove all users
  }

  void _sendCertification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppTheme.successGreen, size: 64),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).getString('certification_sent'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              ).getString('certification_sent_success'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).getString('recipients_notification'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppTheme.errorRed,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            LinkedInButton(
              onPressed: _isCreating ? null : _createCertification,
              text: _isCreating
                  ? 'Creazione in corso...'
                  : 'Crea Certificazione',
              variant: LinkedInButtonVariant.primary,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
