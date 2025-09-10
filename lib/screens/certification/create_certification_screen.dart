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
import '../../services/certification_category_edge_service.dart';
import '../../services/certification_information_service.dart';
import '../../services/otp_verification_service.dart';
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
  final _otpController = TextEditingController();
  String _selectedActivityType = '';
  List<File> _mediaFiles = [];

  // API state
  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoadingCategories = true;
  bool _isVerifyingOtp = false;

  // Dynamic categories from Edge Function
  List<CertificationCategoryEdge> _categories = [];
  String? _selectedCategoryId;

  // Users management
  List<UserData> _addedUsers = [];

  // Certification information fields
  List<CertificationInformation> _certificationUserFields = [];
  bool _isLoadingCertificationFields = true;
  Map<String, Map<String, String>> _userFieldValues =
      {}; // user_id -> field_name -> value

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentStep = _pageController.page?.round() ?? 0;
      });
    });

    // Carica le categorie dalla Edge Function
    _loadCategories();
    // Carica le informazioni di certificazione
    _loadCertificationFields();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
      });

      print('🔍 Loading categories from Edge Function...');
      final categories = await CertificationCategoryEdgeService.getCategories();

      if (categories.isNotEmpty) {
        setState(() {
          _categories = categories;
          _selectedActivityType = categories.first.name;
          _selectedCategoryId = categories.first.idCertificationCategory;
          _isLoadingCategories = false;
        });
        print('✅ Loaded ${categories.length} categories');
      } else {
        print('❌ No categories loaded, using fallback');
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadCertificationFields() async {
    try {
      setState(() {
        _isLoadingCertificationFields = true;
      });

      print('🔍 Loading certification fields from Edge Function...');
      final fields =
          await CertificationInformationService.getCertificationUserInformations();

      if (fields.isNotEmpty) {
        setState(() {
          _certificationUserFields = fields;
          _isLoadingCertificationFields = false;
        });
        print('✅ Loaded ${fields.length} certification user fields');
      } else {
        print('❌ No certification fields loaded');
        setState(() {
          _isLoadingCertificationFields = false;
        });
      }
    } catch (e) {
      print('❌ Error loading certification fields: $e');
      setState(() {
        _isLoadingCertificationFields = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _otpController.dispose();
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
              items: _isLoadingCategories
                  ? [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('Caricamento...'),
                      ),
                    ]
                  : _categories.map((CertificationCategoryEdge category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
              onChanged: _isLoadingCategories
                  ? null
                  : (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedActivityType = newValue;
                          // Trova l'ID della categoria selezionata
                          final selectedCategory = _categories.firstWhere(
                            (cat) => cat.name == newValue,
                            orElse: () => _categories.first,
                          );
                          _selectedCategoryId =
                              selectedCategory.idCertificationCategory;
                          print(
                            '🔍 Selected category: $newValue with ID: $_selectedCategoryId',
                          );
                        });
                      }
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
                  controller: _otpController,
                  label: 'Inserisci codice OTP utente',
                  hintText: 'Inserisci codice OTP...',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(width: 12),
              LinkedInButton(
                onPressed: _isVerifyingOtp ? null : _addUserByOTP,
                text: _isVerifyingOtp ? 'Verificando...' : 'Aggiungi',
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
    final isTablet = MediaQuery.of(context).size.width > 768;

    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _addedUsers.isEmpty ? 'Aggiungi Utente' : 'Utente Aggiunto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              if (_addedUsers.isNotEmpty)
                TextButton.icon(
                  onPressed: _removeUser,
                  icon: Icon(Icons.person_remove, size: 16),
                  label: Text('Rimuovi Utente'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_addedUsers.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nessun utente aggiunto. Inserisci un codice OTP per aggiungere un utente.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ),
            )
          else
            ..._addedUsers.map((user) => _buildUserItem(user)).toList(),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserData user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? Icon(Icons.person, color: AppTheme.textSecondary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                if (user.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeUser(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: AppTheme.pureWhite, size: 16),
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
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (_addedUsers.isEmpty) {
      return LinkedInCard(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nessun utente aggiunto. Inserisci un codice OTP per aggiungere un utente alla certificazione.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return LinkedInCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoadingCertificationFields)
            Container(
              padding: const EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ..._addedUsers
                .map((user) => _buildUserResultSection(user, isTablet))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildUserResultSection(UserData user, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header utente
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture == null
                    ? Icon(Icons.person, color: AppTheme.textSecondary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      user.email,
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

          // Campi dinamici per questo utente
          if (_certificationUserFields.isEmpty)
            Text(
              'Nessun campo di informazione disponibile',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            )
          else
            ..._certificationUserFields
                .map((field) => _buildFieldInput(user, field, isTablet))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildFieldInput(
    UserData user,
    CertificationInformation field,
    bool isTablet,
  ) {
    final currentValue = _userFieldValues[user.idUser]?[field.name] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LinkedInTextField(
        label: field.label,
        initialValue: currentValue,
        onChanged: (value) {
          setState(() {
            if (_userFieldValues[user.idUser] == null) {
              _userFieldValues[user.idUser] = {};
            }
            _userFieldValues[user.idUser]![field.name] = value;
          });
        },
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
      // Usa l'ID della categoria selezionata
      final categoryId = _selectedCategoryId;
      if (categoryId == null) {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Nessuna categoria selezionata';
        });
        return;
      }

      print(
        '🔍 Using category ID: $categoryId for activity: $_selectedActivityType',
      );

      // Ottieni gli ID di default
      print('🔍 Getting default IDs...');
      final certifierId = await DefaultIdsService.getDefaultCertifierId();
      print('🔍 Certifier ID: $certifierId');

      // Usa la legal entity del certificatore
      final legalEntityId = certifierId != null
          ? await DefaultIdsService.getLegalEntityIdForCertifier(certifierId)
          : null;
      print('🔍 Legal Entity ID: $legalEntityId');

      final locationId = await DefaultIdsService.getDefaultLocationId();
      print('🔍 Location ID: $locationId');

      if (certifierId == null || legalEntityId == null || locationId == null) {
        print(
          '❌ One or more IDs are null: certifier=$certifierId, legalEntity=$legalEntityId, location=$locationId',
        );
        print('🔄 Using fallback UUIDs...');

        // Usa UUID di fallback se il servizio non funziona
        final fallbackCertifierId =
            certifierId ?? '550e8400-e29b-41d4-a716-446655440001';
        final fallbackLegalEntityId =
            legalEntityId ?? '550e8400-e29b-41d4-a716-446655440002';
        final fallbackLocationId =
            locationId ?? '550e8400-e29b-41d4-a716-446655440003';

        print(
          '🔄 Fallback IDs: certifier=$fallbackCertifierId, legalEntity=$fallbackLegalEntityId, location=$fallbackLocationId',
        );

        // Prepara i dati della certificazione con fallback
        final certificationData = {
          'id_certifier': fallbackCertifierId,
          'id_legal_entity': fallbackLegalEntityId,
          'id_location': fallbackLocationId,
          'n_users': _addedUsers.isNotEmpty ? 1 : 0,
          'id_certification_category': categoryId,
          'status': 'draft',
          'draft_at': DateTime.now().toIso8601String(),
        };

        print('📋 Certification data (fallback): $certificationData');

        // Crea la certificazione con fallback
        final result = await CertificationEdgeService.createCertification(
          idCertifier: certificationData['id_certifier'] as String,
          idLegalEntity: certificationData['id_legal_entity'] as String,
          idLocation: certificationData['id_location'] as String,
          nUsers: certificationData['n_users'] as int,
          idCertificationCategory:
              certificationData['id_certification_category'] as String,
          status: certificationData['status'] as String,
          draftAt: certificationData['draft_at'] as String,
        );

        if (result != null) {
          print(
            '✅ Certification created successfully with fallback IDs: $result',
          );

          // Se ci sono media files, aggiungili
          if (_mediaFiles.isNotEmpty) {
            await _addMediaToCertification(
              result['id_certification'] as String,
            );
          }

          _showSuccessDialog();
        } else {
          setState(() {
            _isCreating = false;
            _errorMessage = 'Errore nella creazione della certificazione';
          });
        }
        return;
      }

      // Prepara i dati della certificazione
      final certificationData = {
        'id_certifier': certifierId,
        'id_legal_entity': legalEntityId,
        'id_location': locationId,
        'n_users': _addedUsers.isNotEmpty ? 1 : 0,
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
        idCertificationCategory:
            certificationData['id_certification_category'] as String,
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

  void _showSuccessDialog([String? message]) {
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
        content: Text(
          message ?? _successMessage ?? 'Certificazione creata con successo!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi dialog
              if (message != null) {
                // Se è un messaggio di successo per utente aggiunto, non chiudere la schermata
                return;
              }
              Navigator.of(context).pop(); // Chiudi screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            const Text('Errore'),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16, color: AppTheme.primaryBlack),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
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

  Future<void> _addUserByOTP() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.isEmpty) {
      _showErrorDialog('Inserisci un codice OTP valido');
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    try {
      print('🔍 Verifying OTP: $otpCode');
      final result = await OtpVerificationService.verifyOtp(otpCode);

      if (result.success && result.user != null) {
        // Verifica se c'è già un utente (massimo 1 per certificazione)
        if (_addedUsers.isNotEmpty) {
          _showErrorDialog(
            'È possibile aggiungere solo un utente per certificazione',
          );
        } else {
          // Verifica se l'utente è già stato aggiunto (controllo ridondante ma sicuro)
          final existingUser = _addedUsers.any(
            (user) => user.idUser == result.user!.idUser,
          );

          if (existingUser) {
            _showErrorDialog('Questo utente è già stato aggiunto');
          } else {
            setState(() {
              _addedUsers.add(result.user!);
              // Inizializza i valori dei campi per il nuovo utente
              _userFieldValues[result.user!.idUser] = {};
              _otpController.clear();
            });
            _showSuccessDialog('Utente aggiunto con successo!');
          }
        }
      } else {
        _showErrorDialog(
          result.errorMessage ?? 'Errore durante la verifica OTP',
        );
      }
    } catch (e) {
      print('❌ Error adding user by OTP: $e');
      _showErrorDialog('Errore di connessione: $e');
    } finally {
      setState(() {
        _isVerifyingOtp = false;
      });
    }
  }

  void _scanQRCode() {
    // Implement QR code scanning
  }

  void _removeUser() {
    if (_addedUsers.isNotEmpty) {
      setState(() {
        _addedUsers.clear();
        _userFieldValues.clear();
      });
    }
  }

  void _removeAllUsers() {
    setState(() {
      _addedUsers.clear();
      _userFieldValues.clear();
    });
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
