import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../../services/certification_edge_service.dart';
import '../../services/certification_service_v2.dart';
import '../../services/otp_service.dart';
import '../../services/certification_category_service.dart';
import '../../services/certification_category_edge_service.dart';
import '../../services/certification_information_service.dart';
import '../../services/otp_verification_service.dart';
import '../../services/default_ids_service.dart';
import '../../services/legal_entity_service.dart';
import '../../services/location_service.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

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
  final _locationController = TextEditingController();
  String _selectedActivityType = '';
  List<File> _mediaFiles = [];

  // API state
  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoadingCategories = true;

  // Dati per il blocco degli OTP
  List<Map<String, dynamic>> _usedOtps = [];
  bool _isVerifyingOtp = false;

  // Dynamic categories from Edge Function
  List<CertificationCategoryEdge> _categories = [];
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Legal entity information
  String? _legalEntityName;
  List<Map<String, dynamic>> _legalEntities = [];
  String? _selectedLegalEntityId;
  bool _isLoadingLegalEntities = true;

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
    // Carica le legal entities dell'utente
    _loadLegalEntities();
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
          _selectedCategoryName = categories.first.name;
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

  Future<void> _loadLegalEntities() async {
    try {
      print('🔍 Loading legal entities by user...');

      setState(() {
        _isLoadingLegalEntities = true;
      });

      // Ottieni l'utente loggato
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = await authProvider.getCurrentUserId();

      if (currentUserId == null) {
        print('❌ No current user ID available');
        setState(() {
          _isLoadingLegalEntities = false;
        });
        return;
      }

      print('🔍 Current user ID: $currentUserId');

      // Carica tutte le legal entities dell'utente
      final legalEntities = await LegalEntityService.getLegalEntitiesByUser(
        currentUserId,
      );

      if (legalEntities != null && legalEntities.isNotEmpty) {
        setState(() {
          _legalEntities = legalEntities;
          // Seleziona automaticamente la prima legal entity
          _selectedLegalEntityId =
              legalEntities.first['id_legal_entity'] as String?;
          _legalEntityName = legalEntities.first['legal_name'] as String?;
          _isLoadingLegalEntities = false;
        });
        print('✅ Loaded ${legalEntities.length} legal entities for user');
        print('✅ Selected first legal entity: $_legalEntityName');
      } else {
        print('❌ No legal entities found for user');
        setState(() {
          _isLoadingLegalEntities = false;
        });
      }
    } catch (e) {
      print('❌ Error loading legal entities: $e');
      setState(() {
        _isLoadingLegalEntities = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _otpController.dispose();
    _locationController.dispose();
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
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.getString('new_certification'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
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

            EnterpriseTextField(
              controller: _titleController,
              label: l10n.getString('certification_title'),
              hint: l10n.getString('certification_title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il titolo della certificazione';
                }
                return null;
              },
            ),
            SizedBox(height: isTablet ? 20 : 16),

            DropdownButtonFormField<String>(
              value: _selectedLegalEntityId,
              decoration: InputDecoration(
                labelText: l10n.getString('issuing_organization'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isTablet ? 16 : 12,
                ),
              ),
              items: _isLoadingLegalEntities
                  ? [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Caricamento legal entities...'),
                      ),
                    ]
                  : _legalEntities.map((legalEntity) {
                      return DropdownMenuItem<String>(
                        value: legalEntity['id_legal_entity'] as String,
                        child: Text(legalEntity['legal_name'] as String),
                      );
                    }).toList(),
              onChanged: _isLoadingLegalEntities
                  ? null
                  : (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLegalEntityId = newValue;
                          // Trova il nome della legal entity selezionata
                          final selectedEntity = _legalEntities.firstWhere(
                            (entity) => entity['id_legal_entity'] == newValue,
                            orElse: () => _legalEntities.first,
                          );
                          _legalEntityName =
                              selectedEntity['legal_name'] as String?;
                          print('🔍 Selected legal entity: $_legalEntityName');
                        });
                      }
                    },
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
                          _selectedCategoryName = selectedCategory.name;
                          print(
                            '🔍 Selected category: $newValue with ID: $_selectedCategoryId',
                          );
                        });
                      }
                    },
            ),
            SizedBox(height: isTablet ? 20 : 16),

            EnterpriseTextField(
              controller: _descriptionController,
              label: l10n.getString('description'),
              hint: l10n.getString('description'),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci una descrizione';
                }
                return null;
              },
            ),
            SizedBox(height: isTablet ? 20 : 16),

            EnterpriseTextField(
              controller: _locationController,
              label: l10n.getString('location'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il luogo della certificazione';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            _buildMediaSection(),
            SizedBox(height: isTablet ? 40 : 32),

            NeonButton(
              onPressed: _nextStep,
              text: l10n.getString('continue'),
              icon: Icons.arrow_forward,
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

    return EnterpriseCard(
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
              NeonButton(
                onPressed: _addMedia,
                text: '+ ${l10n.getString('add')}',
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
                child: NeonButton(onPressed: _previousStep, text: 'Indietro'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NeonButton(
                  onPressed: _nextStep,
                  text: 'Continua alla Revisione',
                  icon: Icons.arrow_forward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserSection() {
    return EnterpriseCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: EnterpriseTextField(
                  controller: _otpController,
                  label: 'Inserisci codice OTP utente',
                  hint: 'Inserisci codice OTP...',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(width: 12),
              NeonButton(
                onPressed: _isVerifyingOtp ? null : _addUserByOTP,
                text: _isVerifyingOtp ? 'Verificando...' : 'Aggiungi',
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
              NeonButton(
                onPressed: _scanQRCode,
                text: 'Scansiona',
                icon: Icons.qr_code_scanner,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    final isTablet = MediaQuery.of(context).size.width > 768;

    return EnterpriseCard(
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
                child: NeonButton(
                  onPressed: _previousStep,
                  text: l10n.getString('back'),
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: NeonButton(
                  onPressed: _nextStep,
                  text: l10n.getString('continue_to_review'),
                  icon: Icons.arrow_forward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserResultsCard() {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;

    if (_addedUsers.isEmpty) {
      return EnterpriseCard(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              l10n.getString('no_users_added_otp_instruction'),
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return EnterpriseCard(
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
    final l10n = AppLocalizations.of(context);
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
              l10n.getString('no_information_fields_available'),
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
    final controller = TextEditingController(text: currentValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: EnterpriseTextField(
        label: field.label,
        controller: controller,
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
                child: NeonButton(
                  onPressed: _previousStep,
                  text: l10n.getString('back'),
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: NeonButton(
                  onPressed: _sendCertification,
                  text: 'Conferma Certificazione',
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                l10n.getString('general_info'),
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            l10n.getString('title'),
            _selectedCategoryName ?? l10n.getString('no_category_selected'),
          ),
          _buildReviewItem(
            l10n.getString('organization'),
            _legalEntityName ?? l10n.getString('loading_organization'),
          ),
          _buildReviewItem(
            l10n.getString('description'),
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : l10n.getString('no_description_provided'),
          ),
          _buildReviewItem(
            l10n.getString('location'),
            _locationController.text.isNotEmpty
                ? _locationController.text
                : l10n.getString('no_location_provided'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaReviewCard() {
    return EnterpriseCard(
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
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Utenti (${_addedUsers.length})',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_addedUsers.isEmpty)
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.textSecondary,
                    size: isTablet ? 20 : 18,
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: Text(
                      'Nessun utente aggiunto alla certificazione',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._addedUsers
                .map(
                  (user) => Padding(
                    padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: isTablet ? 24 : 20,
                          backgroundColor: AppTheme.primaryBlue.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppTheme.primaryBlue,
                            size: isTablet ? 24 : 20,
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName ??
                                    '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                        .trim(),
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                              if (user.email != null) ...[
                                SizedBox(height: isTablet ? 2 : 1),
                                Text(
                                  user.email!,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                              if (user.phone != null) ...[
                                SizedBox(height: isTablet ? 2 : 1),
                                Text(
                                  user.phone!,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 8,
                            vertical: isTablet ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.successGreen.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            'Aggiunto',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard() {
    return EnterpriseCard(
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

    // Mostra alert di conferma prima di inviare
    final shouldProceed = await _showConfirmationDialog();
    if (!shouldProceed) {
      return;
    }

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

      // Ottieni l'utente loggato
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = await authProvider.getCurrentUserId();

      if (currentUserId == null) {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Utente non autenticato';
        });
        return;
      }

      print('🔍 Current user ID: $currentUserId');

      // Verifica che sia stata selezionata una legal entity
      if (_selectedLegalEntityId == null) {
        print('❌ No legal entity selected');
        setState(() {
          _isCreating = false;
          _errorMessage = 'Seleziona una legal entity prima di procedere.';
        });
        return;
      }

      // Ottieni un certifier esistente con legal entity valida
      final certifierData =
          await DefaultIdsService.getValidCertifierWithLegalEntity();
      if (certifierData == null) {
        print('❌ Could not get valid certifier and legal entity');
        setState(() {
          _isCreating = false;
          _errorMessage =
              'Errore nel recupero dei dati necessari. Riprova più tardi.';
        });
        return;
      }

      final certifierId = certifierData['certifierId']!;
      final legalEntityId =
          _selectedLegalEntityId!; // Usa la legal entity selezionata

      // Crea dinamicamente la location dal campo luogo
      String? locationId;
      if (_locationController.text.isNotEmpty) {
        print('🌍 Creating location for: ${_locationController.text}');
        locationId = await LocationService.createSimpleLocation(
          _locationController.text,
        );
        if (locationId == null) {
          print('❌ Failed to create location, using fallback');
          locationId = 'a5196c46-3d57-4e8c-b293-f4dff308a1a0'; // Fallback ID
        }
      } else {
        print('⚠️ No location provided, using fallback');
        locationId = 'a5196c46-3d57-4e8c-b293-f4dff308a1a0'; // Fallback ID
      }

      print('🔍 Using valid IDs from database:');
      print('  - Certifier ID: $certifierId');
      print('  - Legal Entity ID: $legalEntityId');
      print('  - Legal Entity Name: $_legalEntityName');
      print('  - Location ID: $locationId');

      print('✅ All required IDs available:');
      print('  - certifierId: $certifierId');
      print('  - legalEntityId: $legalEntityId');
      print('  - locationId: ${locationId ?? 'fallback'}');

      // Prepara i dati della certificazione
      final certificationData = {
        'id_certifier': certifierId,
        'id_legal_entity': legalEntityId,
        'id_location': locationId,
        'n_users': _addedUsers.isNotEmpty ? 1 : 0,
        'id_certification_category': categoryId,
        'status': 'pending',
        'draft_at': DateTime.now().toIso8601String(),
      };

      // Prepara l'array certification_users
      List<Map<String, dynamic>> certificationUsers = [];
      if (_addedUsers.isNotEmpty) {
        for (final user in _addedUsers) {
          final otpData = _usedOtps.firstWhere(
            (otp) => otp['user_id'] == user.idUser,
            orElse: () => {},
          );

          certificationUsers.add({
            'id_user': user.idUser,
            'id_otp': otpData['otp_id'],
            'status': 'pending',
            'rejection_reason': null,
          });
        }
      }

      print('📋 Certification data: $certificationData');

      // Test della connessione prima di creare
      final connectionTest = await CertificationEdgeService.testConnection();
      print('🔗 Connection test result: $connectionTest');

      if (!connectionTest) {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Errore di connessione al server. Riprova più tardi.';
        });
        return;
      }

      // Crea la certificazione
      print('🚀 Starting certification creation...');
      // Imposta la data di invio se lo status è "sent"
      String? sentAt;
      if (certificationData['status'] == 'sent') {
        sentAt = DateTime.now().toIso8601String();
        print('📤 Setting sent_at to: $sentAt');
      }

      final result = await CertificationServiceV2.createCertification(
        idCertifier: certificationData['id_certifier'] as String,
        idLegalEntity: certificationData['id_legal_entity'] as String,
        idLocation: certificationData['id_location'] as String,
        nUsers: certificationData['n_users'] as int,
        idCertificationCategory:
            certificationData['id_certification_category'] as String,
        status: certificationData['status'] as String?,
        sentAt: sentAt,
        draftAt: certificationData['draft_at'] as String?,
        media: _mediaFiles.isNotEmpty ? _convertMediaFilesToMaps() : null,
        certificationUsers: certificationUsers.isNotEmpty
            ? certificationUsers
            : null,
      );

      if (result != null) {
        print('✅ Certification created successfully: $result');

        // Blocca gli OTP utilizzati dopo la creazione della certificazione
        await _blockUsedOtps(
          result['data']['id_certification'],
          certificationData,
        );

        // Se ci sono media files, aggiungili
        if (_mediaFiles.isNotEmpty) {
          await _addMediaToCertification(
            result['data']['id_certification'],
            locationId,
          );
        }

        setState(() {
          _successMessage = 'Certificazione inviata con successo!';
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

  /// Mostra dialog di conferma per l'invio della certificazione
  Future<bool> _showConfirmationDialog() async {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.send_rounded,
                    color: AppTheme.primaryBlue,
                    size: isTablet ? 28 : 24,
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: Text(
                      l10n.getString('confirm_certification_send'),
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.getString('confirm_send_certification_question'),
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Container(
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.getString('certification_details'),
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        if (_selectedCategoryName != null)
                          _buildDetailRow(
                            '${l10n.getString('category')}:',
                            _selectedCategoryName!,
                            isTablet,
                          ),
                        if (_addedUsers.isNotEmpty)
                          _buildDetailRow(
                            '${l10n.getString('users')}:',
                            '${_addedUsers.length} ${l10n.getString('users_added')}',
                            isTablet,
                          ),
                        _buildDetailRow(
                          '${l10n.getString('status')}:',
                          l10n.getString('sent_not_modifiable'),
                          isTablet,
                        ),
                        _buildDetailRow(
                          '${l10n.getString('send_date')}:',
                          l10n.getString('now'),
                          isTablet,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Text(
                    '⚠️ ${l10n.getString('certification_send_warning')}',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: AppTheme.warningOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    l10n.getString('cancel'),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 8 : 4),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                      vertical: isTablet ? 12 : 10,
                    ),
                  ),
                  child: Text(
                    l10n.getString('send_certification'),
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Costruisce una riga di dettaglio per il dialog
  Widget _buildDetailRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 4 : 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 80 : 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: AppTheme.primaryBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Converte i File in Map per l'API
  List<Map<String, dynamic>> _convertMediaFilesToMaps() {
    return _mediaFiles.map((file) {
      return {
        'id_media_hash':
            'media_${DateTime.now().millisecondsSinceEpoch}_${file.path.hashCode}',
        'acquisition_type': 'upload',
        'captured_at': DateTime.now().toIso8601String(),
        'file_type': file.path.split('.').last.toLowerCase(),
        'name': file.path.split('/').last,
        'description': null,
        'id_location':
            'a5196c46-3d57-4e8c-b293-f4dff308a1a0', // Fallback ID per media
      };
    }).toList();
  }

  /// Blocca gli OTP utilizzati dopo la creazione della certificazione
  Future<void> _blockUsedOtps(
    String certificationId,
    Map<String, dynamic> certificationData,
  ) async {
    if (_usedOtps.isEmpty) {
      print('ℹ️ No OTPs to block');
      return;
    }

    print(
      '🔒 Blocking ${_usedOtps.length} OTPs after certification creation...',
    );

    for (final otpData in _usedOtps) {
      final otpId = otpData['otp_id'] as String?;
      final userId = otpData['user_id'] as String?;

      if (otpId != null && userId != null) {
        final success = await OtpService.blockOtpAfterUse(
          otpId: otpId,
          userId: userId,
          certificationId: certificationId,
          certifierId: certificationData['id_certifier'] as String,
          legalEntityId: certificationData['id_legal_entity'] as String,
        );

        if (success) {
          print('✅ OTP $otpId blocked successfully');
        } else {
          print('❌ Failed to block OTP $otpId');
        }
      } else {
        print('⚠️ Invalid OTP data: $otpData');
      }
    }

    // Pulisci la lista degli OTP utilizzati
    _usedOtps.clear();
  }

  Future<void> _addMediaToCertification(
    String certificationId,
    String? locationId,
  ) async {
    try {
      print('📸 Adding media to certification: $certificationId');

      // Usa l'ID di location passato o fallback
      final mediaLocationId =
          locationId ?? 'a5196c46-3d57-4e8c-b293-f4dff308a1a0';

      final mediaData = _mediaFiles
          .map(
            (file) => {
              'name': file.path.split('/').last,
              'description': 'Media file for certification',
              'acquisition_type': 'camera',
              'captured_at': DateTime.now().toIso8601String(),
              'file_type': file.path.split('.').last,
              'id_location': mediaLocationId,
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
              // Naviga alla dashboard dei certificatori (indice 2 nella HomeScreen)
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
                arguments: {'selectedIndex': 2},
              );
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
              // Memorizza i dati dell'OTP per il blocco successivo
              _usedOtps.add({
                'otp_id': result.otp?.idOtp,
                'user_id': result.user!.idUser,
                'otp_code': otpCode,
              });
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
    final l10n = AppLocalizations.of(context);
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

            NeonButton(
              onPressed: _isCreating ? null : _createCertification,
              text: _isCreating
                  ? l10n.getString('sending_in_progress')
                  : l10n.getString('send_certification'),
            ),
          ],
        ),
      ),
    );
  }
}
