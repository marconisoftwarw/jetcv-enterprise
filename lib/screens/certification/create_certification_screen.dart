import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../services/certification_edge_service.dart';
import '../../services/certification_media_service.dart';
import '../../services/certification_upload_service.dart';
import '../../services/certification_service_v2.dart';
import '../../services/otp_service.dart';
import '../../services/certification_category_edge_service.dart';
import '../../services/certification_information_service.dart';
import '../../services/otp_verification_service.dart';
import '../../services/default_ids_service.dart';
import '../../services/legal_entity_service.dart';
import '../../services/location_service.dart';
import '../../models/legal_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_search_selector.dart';
import '../../models/media_item.dart';

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
  List<MediaItem> _mediaFiles = [];

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
  List<LegalEntity> _legalEntities = [];
  String? _selectedLegalEntityId;
  bool _isLoadingLegalEntities = true;

  // Users management
  List<UserData> _addedUsers = [];
  bool _isOtpMode = true; // true = OTP mode, false = search mode

  // Certification information fields
  List<CertificationInformation> _certificationUserFields = [];
  bool _isLoadingCertificationFields = true;
  Map<String, Map<String, String>> _userFieldValues =
      {}; // user_id -> field_name -> value

  // Media certificativi per utente
  Map<String, List<MediaItem>> _userCertificationMedia =
      {}; // user_id -> List<MediaItem>

  // GPS Location
  bool _isLoadingLocation = false;

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
    // Rileva automaticamente la posizione all'avvio
    _getCurrentLocation();
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
      final legalEntityService = LegalEntityService();
      final legalEntities = await legalEntityService.getLegalEntitiesByUser(
        currentUserId,
      );

      if (legalEntities.isNotEmpty) {
        setState(() {
          _legalEntities = legalEntities;
          // Seleziona automaticamente la prima legal entity
          _selectedLegalEntityId = legalEntities.first.idLegalEntity;
          _legalEntityName = legalEntities.first.legalName;
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
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive breakpoints
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive values
    final horizontalPadding = isMobile
        ? 20.0
        : isTablet
        ? 32.0
        : 48.0;
    final verticalPadding = isMobile
        ? 16.0
        : isTablet
        ? 24.0
        : 32.0;
    final cardPadding = isMobile
        ? 16.0
        : isTablet
        ? 20.0
        : 24.0;
    final fontSize = isMobile
        ? 14.0
        : isTablet
        ? 16.0
        : 18.0;
    final titleFontSize = isMobile
        ? 18.0
        : isTablet
        ? 20.0
        : 24.0;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.getString('new_certification'),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: titleFontSize,
                  letterSpacing: -0.2,
                ),
              ),
              if (_legalEntityName != null && _legalEntityName!.isNotEmpty) ...[
                SizedBox(
                  width: isMobile
                      ? 8
                      : isTablet
                      ? 12
                      : 16,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? 8
                        : isTablet
                        ? 10
                        : 12,
                    vertical: isMobile
                        ? 3
                        : isTablet
                        ? 4
                        : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.1),
                        AppTheme.primaryBlue.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.business_rounded,
                        color: AppTheme.primaryBlue,
                        size: isMobile
                            ? 12
                            : isTablet
                            ? 14
                            : 16,
                      ),
                      SizedBox(
                        width: isMobile
                            ? 4
                            : isTablet
                            ? 6
                            : 8,
                      ),
                      Text(
                        _legalEntityName!,
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: isMobile
                              ? 10
                              : isTablet
                              ? 12
                              : 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ] else if (_isLoadingLegalEntities) ...[
                SizedBox(
                  width: isMobile
                      ? 8
                      : isTablet
                      ? 12
                      : 16,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? 8
                        : isTablet
                        ? 10
                        : 12,
                    vertical: isMobile
                        ? 3
                        : isTablet
                        ? 4
                        : 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: isTablet ? 12 : 10,
                        height: isTablet ? 12 : 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        l10n.getString('loading_organization'),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
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
              physics:
                  const NeverScrollableScrollPhysics(), // Disabilita lo swipe
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
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 20,
        vertical: isTablet ? 24 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.pureWhite,
            AppTheme.pureWhite.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar moderna
          Container(
            height: isTablet ? 6 : 4,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              width:
                  MediaQuery.of(context).size.width *
                  ((_currentStep + 1) / 4) *
                  0.85, // 85% della larghezza disponibile
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withValues(alpha: 0.8),
                    AppTheme.successGreen,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Step indicators moderni
          Row(
            children: [
              _buildModernStepIndicator(
                0,
                l10n.getString('general_info'),
                _currentStep >= 0,
                _currentStep == 0,
                isTablet,
              ),
              _buildModernStepConnector(_currentStep > 0, isTablet),
              _buildModernStepIndicator(
                1,
                l10n.getString('users'),
                _currentStep >= 1,
                _currentStep == 1,
                isTablet,
              ),
              _buildModernStepConnector(_currentStep > 1, isTablet),
              _buildModernStepIndicator(
                2,
                l10n.getString('results'),
                _currentStep >= 2,
                _currentStep == 2,
                isTablet,
              ),
              _buildModernStepConnector(_currentStep > 2, isTablet),
              _buildModernStepIndicator(
                3,
                l10n.getString('review'),
                _currentStep >= 3,
                _currentStep == 3,
                isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStepIndicator(
    int stepNumber,
    String label,
    bool isCompleted,
    bool isCurrent,
    bool isTablet,
  ) {
    final isActive = isCompleted || isCurrent;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          width: isTablet ? 52 : 44,
          height: isTablet ? 52 : 44,
          decoration: BoxDecoration(
            gradient: isCompleted
                ? LinearGradient(
                    colors: [
                      AppTheme.successGreen,
                      AppTheme.successGreen.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : isCurrent
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.primaryBlue.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isCompleted || isCurrent
                ? null
                : AppTheme.lightGrey.withValues(alpha: 0.4),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? AppTheme.primaryBlue
                  : isCompleted
                  ? AppTheme.successGreen
                  : AppTheme.borderGrey.withValues(alpha: 0.4),
              width: isCurrent || isCompleted ? 2.5 : 1.5,
            ),
            boxShadow: (isCurrent || isCompleted)
                ? [
                    BoxShadow(
                      color:
                          (isCompleted
                                  ? AppTheme.successGreen
                                  : AppTheme.primaryBlue)
                              .withValues(alpha: 0.4),
                      blurRadius: isCurrent ? 12 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: AppTheme.pureWhite,
                    size: isTablet ? 26 : 22,
                  )
                : Text(
                    '${stepNumber + 1}',
                    style: TextStyle(
                      color: isCurrent
                          ? AppTheme.pureWhite
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
          ),
        ),
        SizedBox(height: isTablet ? 10 : 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 8 : 6,
            vertical: isTablet ? 4 : 3,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? (isCurrent
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : AppTheme.successGreen.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: isActive ? AppTheme.primaryBlack : AppTheme.textSecondary,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(
    int stepNumber,
    String label,
    bool isCompleted,
    bool isCurrent,
    bool isTablet,
  ) {
    final isActive = isCompleted || isCurrent;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isTablet ? 48 : 40,
          height: isTablet ? 48 : 40,
          decoration: BoxDecoration(
            gradient: isCompleted
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.primaryBlue.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isCompleted
                ? null
                : isCurrent
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : AppTheme.lightGrey.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? AppTheme.primaryBlue
                  : isCompleted
                  ? AppTheme.primaryBlue
                  : AppTheme.borderGrey.withValues(alpha: 0.5),
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: AppTheme.pureWhite,
                    size: isTablet ? 24 : 20,
                  )
                : Text(
                    '${stepNumber + 1}',
                    style: TextStyle(
                      color: isCurrent
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
          ),
        ),
        SizedBox(height: isTablet ? 8 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: isActive ? AppTheme.primaryBlack : AppTheme.textSecondary,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModernStepConnector(bool isCompleted, bool isTablet) {
    return Expanded(
      child: Container(
        height: isTablet ? 3 : 2,
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 14),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    AppTheme.successGreen,
                    AppTheme.successGreen.withValues(alpha: 0.7),
                    AppTheme.primaryBlue,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isCompleted ? null : AppTheme.lightGrey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(isTablet ? 2 : 1),
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted, bool isTablet) {
    return Expanded(
      child: Container(
        height: isTablet ? 4 : 3,
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withValues(alpha: 0.6),
                  ],
                )
              : null,
          color: isCompleted ? null : AppTheme.lightGrey.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildGeneralInfoStep() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32 : 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header moderno
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.primaryBlue.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.pureWhite,
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                      SizedBox(width: isTablet ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.getString('general_information'),
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlack,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: isTablet ? 4 : 2),
                            Text(
                              l10n.getString('enter_main_details'),
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),

            // Campo Tipologia - PRIMO CAMPO
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedActivityType,
                decoration: InputDecoration(
                  labelText: l10n.getString('activity_type'),
                  labelStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.borderGrey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.borderGrey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 20 : 16,
                  ),
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: AppTheme.primaryBlue,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                items: _isLoadingCategories
                    ? [
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            AppLocalizations.of(context).getString('loading'),
                          ),
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
            ),
            SizedBox(height: isTablet ? 20 : 16),

            // Label per contattare il supporto se il tipo attività non è incluso
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.05),
                    AppTheme.primaryBlue.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppTheme.primaryBlue,
                      size: isTablet ? 20 : 18,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: isTablet ? 14 : 13,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: l10n.getString('activity_type_not_included'),
                          ),
                          TextSpan(text: ' '),
                          TextSpan(
                            text: l10n.getString('contact_jetcv_support'),
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 20 : 16),

            // Campo Titolo - SECONDO CAMPO
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: EnterpriseTextField(
                controller: _titleController,
                label: l10n.getString('certification_title'),
                hint: l10n.getString('certification_title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.getString('enter_certification_title');
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),

            // Campo Organizzazione - TERZO CAMPO
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedLegalEntityId,
                decoration: InputDecoration(
                  labelText: l10n.getString('issuing_organization'),
                  labelStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.borderGrey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.borderGrey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 20 : 16,
                  ),
                  prefixIcon: Icon(
                    Icons.business_outlined,
                    color: AppTheme.primaryBlue,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                items: _isLoadingLegalEntities
                    ? [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).getString('loading_legal_entities'),
                          ),
                        ),
                      ]
                    : _legalEntities.map((legalEntity) {
                        return DropdownMenuItem<String>(
                          value: legalEntity.idLegalEntity,
                          child: Text(legalEntity.legalName ?? 'N/A'),
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
                              (entity) => entity.idLegalEntity == newValue,
                              orElse: () => _legalEntities.first,
                            );
                            _legalEntityName = selectedEntity.legalName;
                            print(
                              '🔍 Selected legal entity: $_legalEntityName',
                            );
                          });
                        }
                      },
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),

            // Campo Descrizione - QUARTO CAMPO
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: EnterpriseTextField(
                controller: _descriptionController,
                label: l10n.getString('description'),
                hint: l10n.getString('description'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.getString('enter_description');
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: isTablet ? 24 : 20),

            // Campo Location - QUINTO CAMPO
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Campo di testo per la location
                  EnterpriseTextField(
                    controller: _locationController,
                    label: l10n.getString('location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getString('enter_certification_location');
                      }
                      return null;
                    },
                  ),

                  // Pulsante per rilevamento GPS automatico
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoadingLocation ? null : _getCurrentLocation,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isLoadingLocation
                                  ? [AppTheme.lightGrey, AppTheme.lightGrey]
                                  : [
                                      AppTheme.successGreen,
                                      AppTheme.successGreen.withValues(
                                        alpha: 0.8,
                                      ),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoadingLocation)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.pureWhite,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.my_location_rounded,
                                  color: AppTheme.pureWhite,
                                  size: 18,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                _isLoadingLocation
                                    ? l10n.getString('detecting_location')
                                    : l10n.getString(
                                        'detect_location_automatically',
                                      ),
                                style: TextStyle(
                                  color: AppTheme.pureWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildMediaSection(),
            SizedBox(height: isTablet ? 40 : 32),

            // Pulsante Continua moderno
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _nextStep,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 18 : 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.getString('continue'),
                          style: TextStyle(
                            color: AppTheme.pureWhite,
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.pureWhite,
                          size: isTablet ? 22 : 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 28 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.successGreen,
                        AppTheme.successGreen.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: AppTheme.pureWhite,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.getString('media_photos_videos'),
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlack,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: isTablet ? 2 : 1),
                      Text(
                        l10n.getString('add_photos_videos_description'),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addMedia,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 12 : 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: AppTheme.pureWhite,
                              size: isTablet ? 20 : 18,
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Text(
                              l10n.getString('add'),
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 14 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Container(
              height: isTablet ? 160 : 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightGrey.withValues(alpha: 0.3),
                    AppTheme.lightGrey.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderGrey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: _mediaFiles.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: isTablet ? 48 : 40,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        Text(
                          l10n.getString('add_photos_videos'),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isTablet ? 4 : 2),
                        Text(
                          l10n.getString('drag_files_or_click'),
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: isTablet ? 12 : 11,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isTablet ? 12 : 8),
                      itemCount: _mediaFiles.length,
                      itemBuilder: (context, index) {
                        final mediaItem = _mediaFiles[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.borderGrey.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Anteprima immagine
                              Container(
                                width: isTablet ? 90 : 80,
                                height: isTablet ? 90 : 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.lightGrey.withValues(alpha: 0.3),
                                      AppTheme.lightGrey.withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: FutureBuilder<Uint8List>(
                                    future: mediaItem.file.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          width: isTablet ? 90 : 80,
                                          height: isTablet ? 90 : 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.error_outline_rounded,
                                                  color: AppTheme.errorRed,
                                                  size: isTablet ? 28 : 24,
                                                );
                                              },
                                        );
                                      } else {
                                        return Icon(
                                          Icons.image_outlined,
                                          color: AppTheme.textSecondary,
                                          size: isTablet ? 28 : 24,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              // Contenuto
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mediaItem.title.isNotEmpty
                                            ? mediaItem.title
                                            : l10n.getString('no_title'),
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryBlack,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 6 : 4),
                                      Text(
                                        mediaItem.description.isNotEmpty
                                            ? mediaItem.description
                                            : l10n.getString('no_description'),
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 12,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w400,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Pulsanti azione
                              Padding(
                                padding: EdgeInsets.all(isTablet ? 12 : 8),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: () => _showMediaEditDialog(
                                          mediaItem,
                                          index,
                                        ),
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: AppTheme.primaryBlue,
                                          size: isTablet ? 20 : 18,
                                        ),
                                        tooltip: l10n.getString('edit'),
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 8 : 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorRed.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: () => _removeMedia(index),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.errorRed,
                                          size: isTablet ? 20 : 18,
                                        ),
                                        tooltip: l10n.getString('remove'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersStep() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header moderno
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.warningOrange,
                            AppTheme.warningOrange.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.people_outline_rounded,
                        color: AppTheme.pureWhite,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.getString('add_users'),
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlack,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: isTablet ? 4 : 2),
                          Text(
                            l10n.getString('enter_participants'),
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          _buildAddUserSection(),
          const SizedBox(height: 24),

          _buildUsersList(),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.borderGrey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _previousStep,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                          vertical: isTablet ? 16 : 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              color: AppTheme.textSecondary,
                              size: isTablet ? 20 : 18,
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Text(
                              l10n.getString('back'),
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _nextStep,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                          vertical: isTablet ? 16 : 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continua alla Revisione',
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppTheme.pureWhite,
                              size: isTablet ? 20 : 18,
                            ),
                          ],
                        ),
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

  Widget _buildAddUserSection() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Column(
      children: [
        // Solo modalità OTP - nascondo il selettore di modalità
        _buildOtpUserSection(l10n, isTablet),
      ],
    );
  }

  Widget _buildUserSelectionModeSelector(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getString('user_selection_mode'),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  isSelected: _isOtpMode,
                  icon: Icons.numbers,
                  title: l10n.getString('add_user_with_otp'),
                  description: 'Aggiungi utente con codice OTP',
                  onTap: () => setState(() => _isOtpMode = true),
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: _buildModeButton(
                  isSelected: !_isOtpMode,
                  icon: Icons.search,
                  title: l10n.getString('add_existing_user'),
                  description: 'Cerca tra utenti esistenti',
                  onTap: () => setState(() => _isOtpMode = false),
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : AppTheme.lightGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : AppTheme.borderGrey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: isTablet ? 32 : 28,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.textSecondary,
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpUserSection(AppLocalizations l10n, bool isTablet) {
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
              SizedBox(width: isTablet ? 16 : 12),
              NeonButton(
                onPressed: _isVerifyingOtp ? null : _addUserByOTP,
                text: _isVerifyingOtp
                    ? l10n.getString('verifying')
                    : l10n.getString('add'),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
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
          SizedBox(height: isTablet ? 20 : 16),
          Row(
            children: [
              Icon(
                Icons.qr_code,
                size: isTablet ? 48 : 40,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('scan_qr_code'),
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      l10n.getString('scan_qr_from_app'),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              NeonButton(
                onPressed: _scanQRCode,
                text: l10n.getString('scan'),
                icon: Icons.qr_code_scanner,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchUserSection(AppLocalizations l10n) {
    if (_selectedLegalEntityId == null) {
      return EnterpriseCard(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber,
                size: 48,
                color: AppTheme.warningOrange,
              ),
              const SizedBox(height: 16),
              Text(
                'Seleziona prima una Legal Entity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Per cercare utenti esistenti è necessario selezionare una Legal Entity nella sezione "Informazioni Generali"',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return UserSearchSelector(
      legalEntityId: _selectedLegalEntityId!,
      onUserSelected: _addUserFromSearch,
      selectedUsers: _addedUsers,
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
                  label: Text(
                    AppLocalizations.of(context).getString('remove_user'),
                  ),
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
                  user.fullName ?? 'N/A',
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
                      user.fullName ?? 'N/A',
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

          // Sezione Media Certificativi per questo utente
          _buildUserCertificationMediaSection(user.idUser, isTablet),
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
              Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Media (${_mediaFiles.length})',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_mediaFiles.isEmpty)
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
                      l10n.getString('no_media_attached'),
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
            Column(
              children: [
                for (int i = 0; i < _mediaFiles.length; i++)
                  Container(
                    margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                    padding: EdgeInsets.all(isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isTablet ? 60 : 50,
                          height: isTablet ? 60 : 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.lightGrey.withValues(alpha: 0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FutureBuilder<Uint8List>(
                              future: _mediaFiles[i].file.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image,
                                        color: AppTheme.textSecondary,
                                        size: isTablet ? 24 : 20,
                                      );
                                    },
                                  );
                                }
                                return Icon(
                                  Icons.image,
                                  color: AppTheme.textSecondary,
                                  size: isTablet ? 24 : 20,
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _mediaFiles[i].file.name,
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isTablet ? 4 : 2),
                              FutureBuilder<int>(
                                future: _mediaFiles[i].file.length(),
                                builder: (context, snapshot) {
                                  final size = snapshot.data ?? 0;
                                  final sizeKB = (size / 1024).round();
                                  return Text(
                                    '${sizeKB} KB',
                                    style: TextStyle(
                                      fontSize: isTablet ? 12 : 10,
                                      color: AppTheme.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successGreen,
                          size: isTablet ? 20 : 18,
                        ),
                      ],
                    ),
                  ),
              ],
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

  /// Gestisce il click del pulsante "Invia Certificazione" con dialog di conferma
  Future<void> _handleSendCertification() async {
    // Mostra dialog di conferma unificato
    final shouldProceed = await _showUnifiedConfirmationDialog();
    if (!shouldProceed) {
      return;
    }

    // Se l'utente conferma, procedi con la creazione
    await _createCertification();
  }

  Future<void> _createCertification() async {
    print('🚀 Creating certification with unified upload service...');
    print('📝 Title from controller: "${_titleController.text.trim()}"');

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

      // Prepara l'array certification_users
      List<Map<String, dynamic>> certificationUsers = [];
      Map<String, String> userEsitoValues = {}; // user_id -> esito_value

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

          // Raccogli l'esito per questo utente se presente
          final userFieldValues = _userFieldValues[user.idUser];
          if (userFieldValues != null) {
            // Cerca il campo "esito" tra i campi dell'utente
            for (final field in _certificationUserFields) {
              if (field.name == 'esito' &&
                  userFieldValues.containsKey('esito')) {
                userEsitoValues[user.idUser] = userFieldValues['esito'] ?? "0";
                print(
                  '📊 Esito per utente ${user.idUser}: ${userFieldValues['esito']}',
                );
                break;
              }
            }
          }
        }
      }

      print('📊 User esito values collected: $userEsitoValues');

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

      // Scegli il servizio appropriato in base alla presenza di media
      Map<String, dynamic>? result;

      // Raccogli tutti i media (di contesto + degli utenti)
      List<MediaItem> allMedia = [];
      List<String> mediaUserIds =
          []; // Lista parallela per identificare i media degli utenti

      // Aggiungi i media di contesto (con user ID vuoto)
      for (int i = 0; i < _mediaFiles.length; i++) {
        allMedia.add(_mediaFiles[i]);
        mediaUserIds.add(''); // Media di contesto hanno user ID vuoto
      }

      // Aggiungi i media degli utenti
      for (String userId in _userCertificationMedia.keys) {
        final userMedia = _userCertificationMedia[userId] ?? [];
        for (int i = 0; i < userMedia.length; i++) {
          allMedia.add(userMedia[i]);
          mediaUserIds.add(userId); // Media degli utenti hanno il loro user ID
        }
      }

      if (allMedia.isNotEmpty) {
        // Se ci sono media, usa il servizio di upload unificato
        print('🚀 Creating certification with media files...');
        print('📁 Context media files: ${_mediaFiles.length}');
        print('📁 User media files: ${allMedia.length - _mediaFiles.length}');
        print('📁 Total media files: ${allMedia.length}');
        print('📁 Media order:');
        for (int i = 0; i < allMedia.length; i++) {
          final userId = i < mediaUserIds.length
              ? mediaUserIds[i]
              : 'NO_USER_ID';
          final isUserMedia = userId.isNotEmpty;
          print(
            '  File $i: ${allMedia[i].file.name} - User: ${isUserMedia ? userId : "CONTEXT"}',
          );
        }

        result = await CertificationUploadService.createCertificationWithMedia(
          idCertifier: certifierId,
          idLegalEntity: legalEntityId,
          idLocation: locationId,
          nUsers: _addedUsers.isNotEmpty ? 1 : 0,
          idCertificationCategory: categoryId,
          status: 'pending',
          draftAt: DateTime.now().toIso8601String(),
          certificationUsers: certificationUsers.isNotEmpty
              ? certificationUsers
              : null,
          mediaFiles: allMedia.map((item) => item.file).toList(),
          mediaMetadata: allMedia
              .map(
                (item) => {
                  'title': item.title,
                  'description': item.description,
                },
              )
              .toList(),
          acquisitionType: 'deferred',
          userIds: mediaUserIds,
          esitoValue: "0", // Valore di default per esito (deprecato)
          titoloValue: _titleController.text
              .trim(), // Titolo inserito dall'utente
          userEsitoValues: userEsitoValues, // Esiti per ogni utente
        );
      } else {
        // Se non ci sono media, usa il servizio certificazioni standard
        print('🚀 Creating certification without media...');

        result = await CertificationServiceV2.createCertification(
          idCertifier: certifierId,
          idLegalEntity: legalEntityId,
          idLocation: locationId,
          nUsers: _addedUsers.isNotEmpty ? 1 : 0,
          idCertificationCategory: categoryId,
          status: 'pending',
          draftAt: DateTime.now().toIso8601String(),
          certificationUsers: certificationUsers.isNotEmpty
              ? certificationUsers
              : null,
          esitoValue: "0", // Valore di default per esito (deprecato)
          titoloValue: _titleController.text
              .trim(), // Titolo inserito dall'utente
          userEsitoValues: userEsitoValues, // Esiti per ogni utente
        );
      }

      if (result != null) {
        print('✅ Certification created successfully with media: $result');

        // Blocca gli OTP utilizzati dopo la creazione della certificazione
        if (_addedUsers.isNotEmpty) {
          await _blockUsedOtps(result['data']['id_certification'], {
            'id_certification': result['data']['id_certification'],
            'id_certifier': certifierId,
            'id_legal_entity': legalEntityId,
            'id_location': locationId,
            'n_users': _addedUsers.length,
            'id_certification_category': categoryId,
            'status': 'pending',
          });
        }

        setState(() {
          _successMessage = 'Certificazione e media caricati con successo!';
          _isCreating = false;
        });

        // Mostra messaggio di successo e chiudi
        _showUnifiedResultDialog(
          isSuccess: true,
          title: 'Certificazione Inviata!',
          message:
              'La certificazione è stata inviata con successo e non può più essere modificata.',
        );
      } else {
        throw Exception('Failed to create certification with media');
      }
    } catch (e) {
      print('💥 Error creating certification: $e');
      setState(() {
        _errorMessage = 'Errore nella creazione della certificazione: $e';
        _isCreating = false;
      });

      // Mostra dialog di errore unificato
      _showUnifiedResultDialog(
        isSuccess: false,
        title: 'Errore nell\'Invio',
        message:
            'Si è verificato un errore durante l\'invio della certificazione. Riprova più tardi.',
      );
    }
  }

  /// Mostra dialog di conferma unificato per l'invio della certificazione
  Future<bool> _showUnifiedConfirmationDialog() async {
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
                      'Conferma Invio Certificazione',
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
                    'Sei sicuro di voler inviare questa certificazione?',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: AppTheme.primaryBlack,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),

                  // Riepilogo certificazione
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
                          'Riepilogo Certificazione:',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        if (_selectedCategoryName != null)
                          _buildDetailRow(
                            'Categoria:',
                            _selectedCategoryName!,
                            isTablet,
                          ),
                        if (_addedUsers.isNotEmpty)
                          _buildDetailRow(
                            'Utenti:',
                            '${_addedUsers.length} utenti aggiunti',
                            isTablet,
                          ),
                        _buildDetailRow(
                          'Titolo:',
                          _titleController.text.trim().isNotEmpty
                              ? _titleController.text.trim()
                              : 'Nessun titolo specificato',
                          isTablet,
                        ),
                        _buildDetailRow(
                          'Stato:',
                          'Inviata (non modificabile)',
                          isTablet,
                        ),
                        _buildDetailRow('Data invio:', 'Ora', isTablet),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),

                  // Avviso importante
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 10),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.warningOrange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.warningOrange,
                          size: isTablet ? 20 : 18,
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        Expanded(
                          child: Text(
                            'Una volta inviata, la certificazione non potrà più essere modificata.',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11,
                              color: AppTheme.warningOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Annulla',
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
                    'Invia Certificazione',
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

  /// Mostra dialog di conferma per l'invio della certificazione (DEPRECATO)
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

  Future<void> _uploadMediaToCertification(
    String certificationId,
    String? locationId,
  ) async {
    try {
      print('📸 Uploading media to certification: $certificationId');

      // Usa l'ID di location passato o fallback
      final mediaLocationId =
          locationId ?? 'a5196c46-3d57-4e8c-b293-f4dff308a1a0';

      // Raccogli tutti i media (di contesto + degli utenti)
      List<MediaItem> allMedia = [];
      List<String> mediaUserIds =
          []; // Lista parallela per identificare i media degli utenti

      // Aggiungi i media di contesto (con user ID vuoto)
      for (int i = 0; i < _mediaFiles.length; i++) {
        allMedia.add(_mediaFiles[i]);
        mediaUserIds.add(''); // Media di contesto hanno user ID vuoto
      }
      print('📁 Context media files: ${_mediaFiles.length}');

      // Aggiungi i media degli utenti
      for (String userId in _userCertificationMedia.keys) {
        final userMedia = _userCertificationMedia[userId] ?? [];
        for (int i = 0; i < userMedia.length; i++) {
          allMedia.add(userMedia[i]);
          mediaUserIds.add(userId); // Media degli utenti hanno il loro user ID
        }
        print('📁 User $userId media files: ${userMedia.length}');
      }

      if (allMedia.isEmpty) {
        print('ℹ️ No media files to upload');
        return;
      }

      print('📁 Media upload order:');
      for (int i = 0; i < allMedia.length; i++) {
        final userId = i < mediaUserIds.length ? mediaUserIds[i] : 'NO_USER_ID';
        final isUserMedia = userId.isNotEmpty;
        print(
          '  File $i: ${allMedia[i].file.name} - User: ${isUserMedia ? userId : "CONTEXT"}',
        );
      }

      // Usa il servizio di upload unificato che supporta metadati
      final result =
          await CertificationUploadService.createCertificationWithMedia(
            idCertifier: '', // Non necessario per l'upload di media
            idLegalEntity: '', // Non necessario per l'upload di media
            idLocation: mediaLocationId,
            nUsers: 0, // Non necessario per l'upload di media
            idCertificationCategory: '', // Non necessario per l'upload di media
            mediaFiles: allMedia.map((item) => item.file).toList(),
            mediaMetadata: allMedia
                .map(
                  (item) => {
                    'title': item.title,
                    'description': item.description,
                  },
                )
                .toList(),
            acquisitionType: 'deferred',
            capturedAt: DateTime.now().toIso8601String(),
            userIds: mediaUserIds,
          );

      if (result != null) {
        print('✅ Media uploaded successfully: ${allMedia.length} files');
      } else {
        print('❌ Failed to upload media');
      }
    } catch (e) {
      print('💥 Error uploading media: $e');
      // Non bloccare la creazione della certificazione per errori sui media
    }
  }

  /// Mostra dialog di risultato unificato (successo o errore)
  void _showUnifiedResultDialog({
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppTheme.successGreen : AppTheme.errorRed,
              size: isTablet ? 28 : 24,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Text(
                title,
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
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppTheme.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSuccess) ...[
              SizedBox(height: isTablet ? 16 : 12),
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.successGreen,
                      size: isTablet ? 18 : 16,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Expanded(
                      child: Text(
                        'La certificazione è stata inviata e non può più essere modificata.',
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                // Chiudi la schermata e torna alla lista certificazioni
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess
                  ? AppTheme.successGreen
                  : AppTheme.errorRed,
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
              isSuccess ? 'Chiudi' : 'Riprova',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
            Text(AppLocalizations.of(context).getString('success_short')),
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
              // Naviga alla home senza selezionare nessun tab specifico
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            child: Text(AppLocalizations.of(context).getString('ok_short')),
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
            Text(AppLocalizations.of(context).getString('error_short')),
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
    try {
      // Mostra dialog per selezionare tipo di media
      final mediaType = await _showMediaTypeSelectionDialog();
      if (mediaType == null) return;

      XFile? selectedFile;
      final ImagePicker picker = ImagePicker();

      switch (mediaType) {
        case 'image':
          selectedFile = await picker.pickImage(source: ImageSource.gallery);
          break;
        case 'video':
          selectedFile = await picker.pickVideo(source: ImageSource.gallery);
          break;
        case 'audio':
          // Per audio, usiamo la galleria come fallback
          selectedFile = await picker.pickImage(source: ImageSource.gallery);
          break;
      }

      if (selectedFile != null) {
        // Su web, usiamo direttamente XFile per evitare problemi con File
        try {
          // Testiamo se il file può essere letto
          await selectedFile.readAsBytes();

          setState(() {
            _mediaFiles.add(MediaItem(file: selectedFile!, type: mediaType));
          });
          print(
            '✅ Media file added successfully: ${selectedFile.name} (${mediaType})',
          );
        } catch (fileError) {
          print('❌ Error with file ${selectedFile.name}: $fileError');
          _showErrorDialog(
            'Errore nel caricamento del file. Riprova con un altro file.',
          );
        }
      }
    } catch (e) {
      print('❌ Error adding media: $e');
      _showErrorDialog('Errore nella selezione del file. Riprova.');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  // Metodi per gestire i media certificativi per utente
  void _addUserCertificationMedia(String userId) async {
    try {
      // Mostra dialog per selezionare tipo di media
      final mediaType = await _showMediaTypeSelectionDialog();
      if (mediaType == null) return;

      XFile? selectedFile;
      final ImagePicker picker = ImagePicker();

      switch (mediaType) {
        case 'image':
          selectedFile = await picker.pickImage(source: ImageSource.gallery);
          break;
        case 'video':
          selectedFile = await picker.pickVideo(source: ImageSource.gallery);
          break;
        case 'audio':
          // Per audio, usiamo la galleria come fallback
          selectedFile = await picker.pickImage(source: ImageSource.gallery);
          break;
      }

      if (selectedFile != null) {
        final mediaItem = MediaItem(
          file: selectedFile!,
          title: '',
          description: '',
          type: mediaType,
        );

        setState(() {
          if (_userCertificationMedia[userId] == null) {
            _userCertificationMedia[userId] = [];
          }
          _userCertificationMedia[userId]!.add(mediaItem);
        });

        // Mostra dialog per modificare titolo e descrizione
        _showUserMediaEditDialog(
          userId,
          mediaItem,
          _userCertificationMedia[userId]!.length - 1,
        );
      }
    } catch (e) {
      print('❌ Error picking media for user $userId: $e');
      _showErrorDialog('Errore nella selezione del file. Riprova.');
    }
  }

  void _removeUserCertificationMedia(String userId, int index) {
    setState(() {
      _userCertificationMedia[userId]?.removeAt(index);
    });
  }

  // Dialog per selezionare il tipo di media
  Future<String?> _showMediaTypeSelectionDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleziona tipo di media',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMediaTypeOption(
                context,
                'image',
                'Immagine',
                Icons.image,
                AppTheme.primaryBlue,
              ),
              const SizedBox(height: 12),
              _buildMediaTypeOption(
                context,
                'video',
                'Video',
                Icons.videocam,
                AppTheme.errorRed,
              ),
              const SizedBox(height: 12),
              _buildMediaTypeOption(
                context,
                'audio',
                'Audio',
                Icons.audiotrack,
                AppTheme.successGreen,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annulla',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaTypeOption(
    BuildContext context,
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMediaEditDialog(String userId, MediaItem mediaItem, int index) {
    final titleController = TextEditingController(text: mediaItem.title);
    final descriptionController = TextEditingController(
      text: mediaItem.description,
    );
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.getString('edit_media')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EnterpriseTextField(
              controller: titleController,
              label: l10n.getString('title'),
              hint: 'Inserisci il titolo...',
            ),
            const SizedBox(height: 16),
            EnterpriseTextField(
              controller: descriptionController,
              label: l10n.getString('description'),
              hint: 'Inserisci la descrizione...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.getString('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userCertificationMedia[userId]![index] = MediaItem(
                  file: mediaItem.file,
                  title: titleController.text,
                  description: descriptionController.text,
                );
              });
              Navigator.of(context).pop();
            },
            child: Text(l10n.getString('save')),
          ),
        ],
      ),
    );
  }

  // Widget per la sezione media certificativi di ogni utente
  Widget _buildUserCertificationMediaSection(String userId, bool isTablet) {
    final l10n = AppLocalizations.of(context);
    final userMedia = _userCertificationMedia[userId] ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 28 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: AppTheme.pureWhite,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.getString('certification_media'),
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlack,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: isTablet ? 2 : 1),
                      Text(
                        'Media specifici per questo utente',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _addUserCertificationMedia(userId),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 12 : 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: AppTheme.pureWhite,
                              size: isTablet ? 20 : 18,
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Text(
                              l10n.getString('add'),
                              style: TextStyle(
                                color: AppTheme.pureWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 14 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 24 : 20),
            Container(
              height: isTablet ? 160 : 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightGrey.withValues(alpha: 0.3),
                    AppTheme.lightGrey.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderGrey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: userMedia.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: isTablet ? 48 : 40,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        Text(
                          l10n.getString('add_photos_videos'),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isTablet ? 4 : 2),
                        Text(
                          l10n.getString('drag_files_or_click'),
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: isTablet ? 12 : 11,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(isTablet ? 12 : 8),
                      itemCount: userMedia.length,
                      itemBuilder: (context, index) {
                        final mediaItem = userMedia[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.borderGrey.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: isTablet ? 90 : 80,
                                height: isTablet ? 90 : 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.lightGrey.withValues(alpha: 0.3),
                                      AppTheme.lightGrey.withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: FutureBuilder<Uint8List>(
                                    future: mediaItem.file.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          width: isTablet ? 90 : 80,
                                          height: isTablet ? 90 : 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.error_outline_rounded,
                                                  color: AppTheme.errorRed,
                                                  size: isTablet ? 28 : 24,
                                                );
                                              },
                                        );
                                      } else {
                                        return Icon(
                                          Icons.image_outlined,
                                          color: AppTheme.textSecondary,
                                          size: isTablet ? 28 : 24,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              // Contenuto
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mediaItem.title.isNotEmpty
                                            ? mediaItem.title
                                            : l10n.getString('no_title'),
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryBlack,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 6 : 4),
                                      Text(
                                        mediaItem.description.isNotEmpty
                                            ? mediaItem.description
                                            : l10n.getString('no_description'),
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 12,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w400,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Pulsanti azione
                              Padding(
                                padding: EdgeInsets.all(isTablet ? 12 : 8),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: () =>
                                            _showUserMediaEditDialog(
                                              userId,
                                              mediaItem,
                                              index,
                                            ),
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: AppTheme.primaryBlue,
                                          size: isTablet ? 20 : 18,
                                        ),
                                        tooltip: l10n.getString('edit'),
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 8 : 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorRed.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: () =>
                                            _removeUserCertificationMedia(
                                              userId,
                                              index,
                                            ),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.errorRed,
                                          size: isTablet ? 20 : 18,
                                        ),
                                        tooltip: l10n.getString('remove'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Metodi per gestire la posizione GPS
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Verifica se i servizi di localizzazione sono abilitati
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog(
          'I servizi di localizzazione sono disabilitati. Abilitali nelle impostazioni.',
        );
        return;
      }

      // Richiedi permessi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('I permessi di localizzazione sono stati negati.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationController.text = 'Roma, Italia';
        });
        _showErrorDialog(
          'I permessi di localizzazione sono stati negati permanentemente. Utilizzato Roma come posizione predefinita.',
        );
        return;
      }

      // Ottieni la posizione corrente
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy
            .medium, // Ridotto da high a medium per maggiore compatibilità
        timeLimit: const Duration(seconds: 15), // Aumentato timeout
      );

      // Verifica che le coordinate siano valide
      if (position.latitude.isNaN || position.longitude.isNaN) {
        throw Exception('Coordinate non valide ricevute');
      }

      // Converti le coordinate in indirizzo
      String address = await _getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _locationController.text = address;
        _isLoadingLocation = false;
      });

      print('📍 Posizione ottenuta: $address');
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('❌ Errore nel rilevamento della posizione: $e');

      // Messaggio di errore più specifico
      String errorMessage = 'Errore nel rilevamento della posizione.';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Timeout nel rilevamento della posizione. Utilizzo Roma come posizione predefinita.';
        // Imposta Roma come posizione predefinita
        setState(() {
          _locationController.text = 'Roma, Italia';
        });
        return;
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Permessi di localizzazione non concessi. Utilizzo Roma come posizione predefinita.';
        // Imposta Roma come posizione predefinita
        setState(() {
          _locationController.text = 'Roma, Italia';
        });
        return;
      } else if (e.toString().contains('service')) {
        errorMessage =
            'Servizio di localizzazione non disponibile. Utilizzo Roma come posizione predefinita.';
        // Imposta Roma come posizione predefinita
        setState(() {
          _locationController.text = 'Roma, Italia';
        });
        return;
      }

      // Fallback generale: usa Roma
      setState(() {
        _locationController.text = 'Roma, Italia';
      });
      _showErrorDialog(
        'Errore nel rilevamento della posizione. Utilizzato Roma come posizione predefinita.',
      );
    }
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Verifica che le coordinate siano valide
      if (lat.isNaN || lng.isNaN || lat == 0.0 && lng == 0.0) {
        print(
          '❌ Coordinate non valide per reverse geocoding: lat=$lat, lng=$lng',
        );
        return 'Roma, Italia';
      }

      // Su web, usa un fallback più robusto
      if (kIsWeb) {
        return await _getAddressFromCoordinatesWeb(lat, lng);
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Costruisci l'indirizzo in formato leggibile
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        String address = addressParts.join(', ');
        return address.isNotEmpty ? address : 'Roma, Italia';
      }

      print('⚠️ Nessun risultato dal reverse geocoding per lat=$lat, lng=$lng');
      return 'Roma, Italia';
    } catch (e) {
      print('❌ Errore nel reverse geocoding: $e');

      // Log più dettagliato per debugging
      if (e.toString().contains('network')) {
        print('🌐 Errore di rete durante reverse geocoding');
      } else if (e.toString().contains('timeout')) {
        print('⏰ Timeout durante reverse geocoding');
      } else if (e.toString().contains('null')) {
        print('🔍 Errore null durante reverse geocoding');
      }

      // Fallback per web
      if (kIsWeb) {
        return 'Roma, Italia';
      }

      return 'Roma, Italia';
    }
  }

  /// Fallback method per geocoding su web
  Future<String> _getAddressFromCoordinatesWeb(double lat, double lng) async {
    try {
      // Prova prima con il geocoding normale
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Costruisci l'indirizzo in formato leggibile
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        String address = addressParts.join(', ');
        return address.isNotEmpty ? address : 'Roma, Italia';
      }

      // Se non funziona, restituisci Roma
      return 'Roma, Italia';
    } catch (e) {
      print('❌ Errore nel reverse geocoding web: $e');
      // Fallback finale: restituisci Roma
      return 'Roma, Italia';
    }
  }

  void _showMediaEditDialog(MediaItem mediaItem, int index) {
    final titleController = TextEditingController(text: mediaItem.title);
    final descriptionController = TextEditingController(
      text: mediaItem.description,
    );
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Modifica Media',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          content: SizedBox(
            width: isTablet ? 400 : 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Anteprima immagine
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderGrey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FutureBuilder<Uint8List>(
                      future: mediaItem.file.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Icon(
                            Icons.image,
                            size: 48,
                            color: AppTheme.textSecondary,
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 20 : 16),

                // Campo titolo
                EnterpriseTextField(
                  controller: titleController,
                  label: 'Titolo',
                  hint: 'Inserisci un titolo per il media',
                  validator: (value) => null,
                ),
                SizedBox(height: isTablet ? 16 : 12),

                // Campo descrizione
                EnterpriseTextField(
                  controller: descriptionController,
                  label: 'Descrizione',
                  hint: 'Inserisci una descrizione per il media',
                  maxLines: 3,
                  validator: (value) => null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annulla',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            NeonButton(
              onPressed: () {
                setState(() {
                  final updatedMedia = mediaItem.copyWith(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                  );

                  _mediaFiles[index] = updatedMedia;
                });
                Navigator.of(context).pop();
              },
              text: 'Salva',
            ),
          ],
        );
      },
    );
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

  Future<void> _scanQRCode() async {
    try {
      // Naviga alla schermata di scansione QR
      final String? scannedData = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );

      if (scannedData != null && scannedData.isNotEmpty) {
        // Processa i dati scansionati
        await _processScannedQRData(scannedData);
      } else {
        // Mostra messaggio se la scansione è stata annullata
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Scansione annullata'),
              backgroundColor: AppTheme.textSecondary,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Errore nella scansione QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nella scansione: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _processScannedQRData(String scannedData) async {
    try {
      print('📱 Dati QR scansionati: $scannedData');

      // Prova a parsare i dati come JSON
      Map<String, dynamic>? qrData;
      try {
        qrData = json.decode(scannedData) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ I dati QR non sono in formato JSON valido');
      }

      if (qrData != null) {
        // Se è un JSON, estrai le informazioni utente
        final userData = _extractUserDataFromQR(qrData);
        if (userData != null) {
          await _addUserFromQR(userData);
        } else {
          _showQRDataDialog(scannedData);
        }
      } else {
        // Se non è JSON, mostra i dati raw
        _showQRDataDialog(scannedData);
      }
    } catch (e) {
      print('❌ Errore nel processamento dei dati QR: $e');
      _showQRDataDialog(scannedData);
    }
  }

  Map<String, dynamic>? _extractUserDataFromQR(Map<String, dynamic> qrData) {
    try {
      // Cerca campi comuni per i dati utente
      if (qrData.containsKey('user_id') ||
          qrData.containsKey('email') ||
          qrData.containsKey('userId')) {
        return qrData;
      }

      // Cerca in strutture nidificate
      if (qrData.containsKey('user')) {
        return qrData['user'] as Map<String, dynamic>?;
      }

      if (qrData.containsKey('data')) {
        final data = qrData['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print('❌ Errore nell\'estrazione dati utente: $e');
      return null;
    }
  }

  Future<void> _addUserFromQR(Map<String, dynamic> userData) async {
    try {
      // Crea un oggetto UserData dai dati QR
      final user = UserData(
        idUser: userData['user_id'] ?? userData['userId'] ?? const Uuid().v4(),
        email: userData['email'] ?? 'email@sconosciuta.com', // Email richiesta
        firstName: userData['first_name'] ?? userData['firstName'],
        lastName: userData['last_name'] ?? userData['lastName'],
        phone: userData['phone'],
        fullName: userData['full_name'] ?? userData['fullName'],
        createdAt: DateTime.now().toIso8601String(),
      );

      // Verifica se l'utente è già stato aggiunto
      final isAlreadyAdded = _addedUsers.any((u) => u.idUser == user.idUser);

      if (isAlreadyAdded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Utente già aggiunto alla certificazione'),
              backgroundColor: AppTheme.warningOrange,
            ),
          );
        }
        return;
      }

      // Aggiungi l'utente
      setState(() {
        _addedUsers.add(user);
        _userFieldValues[user.idUser] = {};
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utente ${user.fullName ?? user.email ?? 'Sconosciuto'} aggiunto',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      print('❌ Errore nell\'aggiunta utente da QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nell\'aggiunta utente: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showQRDataDialog(String scannedData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: const Text('Dati QR Scansionati'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contenuto del codice QR:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    scannedData,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Questi dati non sembrano contenere informazioni utente valide. '
                  'Puoi copiare il contenuto e usarlo manualmente.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
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

  void _addUserFromSearch(UserData user) {
    // Verifica se c'è già un utente (massimo 1 per certificazione)
    if (_addedUsers.isNotEmpty) {
      _showErrorDialog(
        'È possibile aggiungere solo un utente per certificazione',
      );
      return;
    }

    setState(() {
      _addedUsers.add(user);
      // Inizializza i valori dei campi per il nuovo utente
      _userFieldValues[user.idUser] = {};
    });

    _showSuccessDialog('Utente aggiunto con successo!');
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
              onPressed: _isCreating ? null : _handleSendCertification,
              text: _isCreating
                  ? l10n.getString('sending_in_progress')
                  : l10n.getString('send_certification'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper per visualizzare preview dei media
  Widget _buildMediaPreview(MediaItem mediaItem, bool isTablet) {
    final mediaType = mediaItem.type ?? 'image';

    switch (mediaType) {
      case 'image':
        return FutureBuilder<Uint8List>(
          future: mediaItem.file.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                width: isTablet ? 90 : 80,
                height: isTablet ? 90 : 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.errorRed,
                    size: isTablet ? 28 : 24,
                  );
                },
              );
            } else {
              return Icon(
                Icons.image_outlined,
                color: AppTheme.textSecondary,
                size: isTablet ? 28 : 24,
              );
            }
          },
        );
      case 'video':
        return Container(
          width: isTablet ? 90 : 80,
          height: isTablet ? 90 : 80,
          decoration: BoxDecoration(
            color: AppTheme.errorRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.play_circle_filled,
            color: AppTheme.errorRed,
            size: isTablet ? 40 : 36,
          ),
        );
      case 'audio':
        return Container(
          width: isTablet ? 90 : 80,
          height: isTablet ? 90 : 80,
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.audiotrack,
            color: AppTheme.successGreen,
            size: isTablet ? 40 : 36,
          ),
        );
      default:
        return Icon(
          Icons.insert_drive_file,
          color: AppTheme.textSecondary,
          size: isTablet ? 40 : 36,
        );
    }
  }
}
