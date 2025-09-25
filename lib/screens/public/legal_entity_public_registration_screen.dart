import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../models/pricing.dart';
import '../../models/user.dart' show AppUser;
import '../../models/legal_entity.dart';
import '../../services/supabase_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/edge_function_service.dart';
import '../../services/legal_entity_image_service.dart';
import '../../providers/pricing_provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/international_phone_field.dart';
import '../../l10n/app_localizations.dart';
import '../../services/url_parameter_service.dart';

class LegalEntityPublicRegistrationScreen extends StatefulWidget {
  final Map<String, String>? urlParameters;

  const LegalEntityPublicRegistrationScreen({super.key, this.urlParameters});

  @override
  State<LegalEntityPublicRegistrationScreen> createState() =>
      _LegalEntityPublicRegistrationScreenState();
}

class _LegalEntityPublicRegistrationScreenState
    extends State<LegalEntityPublicRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personalFormKey = GlobalKey<FormState>();
  final _entityFormKey = GlobalKey<FormState>();

  // Step management
  int _currentStep = 0;
  final int _totalSteps = 2;

  // Pricing
  Pricing? _selectedPricing;

  // Personal information
  final _personalNameController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _personalPhoneController = TextEditingController();
  String _personalCountryCode = '+39'; // Default to Italy
  File? _personalProfilePicture;

  // Legal entity information
  final _legalNameController = TextEditingController();
  final _identifierCodeController = TextEditingController();
  final _entityEmailController = TextEditingController();
  final _legalRepresentativeController = TextEditingController();
  final _operationalAddressController = TextEditingController();
  final _operationalCityController = TextEditingController();
  final _operationalPostalCodeController = TextEditingController();
  final _operationalStateController = TextEditingController();
  final _operationalCountryController = TextEditingController();
  final _headquarterAddressController = TextEditingController();
  final _headquarterCityController = TextEditingController();
  final _headquarterPostalCodeController = TextEditingController();
  final _headquarterStateController = TextEditingController();
  final _headquarterCountryController = TextEditingController();
  final _phoneController = TextEditingController();
  String _entityCountryCode = '+39'; // Default to Italy
  final _pecController = TextEditingController();
  final _websiteController = TextEditingController();
  File? _entityProfilePicture;
  File? _entityCompanyPicture;

  // For web platform - store image data as Uint8List
  Uint8List? _entityProfilePictureData;
  Uint8List? _entityCompanyPictureData;

  // Loading states
  bool _isLoading = false;
  bool _isPickingImage = false;

  // Services
  final SupabaseService _supabaseService = SupabaseService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Carica i dati dei pricing e parametri URL dopo che il widget è stato costruito
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPricingData();
      _loadUrlParameters();
    });
  }

  Future<void> _loadPricingData() async {
    final pricingProvider = context.read<PricingProvider>();
    await pricingProvider.loadPricings();
  }

  @override
  void dispose() {
    _personalNameController.dispose();
    _personalEmailController.dispose();
    _personalPhoneController.dispose();
    _legalNameController.dispose();
    _identifierCodeController.dispose();
    _entityEmailController.dispose();
    _legalRepresentativeController.dispose();
    _operationalAddressController.dispose();
    _operationalCityController.dispose();
    _operationalPostalCodeController.dispose();
    _operationalStateController.dispose();
    _operationalCountryController.dispose();
    _headquarterAddressController.dispose();
    _headquarterCityController.dispose();
    _headquarterPostalCodeController.dispose();
    _headquarterStateController.dispose();
    _headquarterCountryController.dispose();
    _phoneController.dispose();
    _pecController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _loadUrlParameters() {
    try {
      // Estrai parametri dall'URL corrente (per inviti via email)
      final uri = Uri.base;
      final queryParams = uri.queryParameters;

      // Controlla anche i parametri del route (per navigazione interna)
      final Map<String, String>? routeParams =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

      // Parametri passati dal costruttore (dal routing)
      final Map<String, String>? widgetParams = widget.urlParameters;

      // Prova anche a estrarre parametri dall'URL completo se necessario
      Map<String, String> additionalParams = {};
      try {
        // Se non ci sono parametri nella query string, prova a estrarre dall'URL completo
        if (queryParams.isEmpty) {
          final currentLocation = ModalRoute.of(context)?.settings.name;
          if (currentLocation != null) {
            final locationUri = Uri.parse(currentLocation);
            additionalParams = Map<String, String>.from(
              locationUri.queryParameters,
            );
          }
        }

        // Prova anche a estrarre dall'URL del browser direttamente
        if (additionalParams.isEmpty) {
          try {
            // Usa Uri.base per accedere all'URL del browser (compatibile con tutte le piattaforme)
            final browserUrl = Uri.base.toString();
            print('🔍 Browser URL: $browserUrl');
            final browserUri = Uri.parse(browserUrl);
            if (browserUri.queryParameters.isNotEmpty) {
              additionalParams = Map<String, String>.from(
                browserUri.queryParameters,
              );
              print('🔍 Additional params from browser URL: $additionalParams');
            }
          } catch (e) {
            print(
              '🔍 Error extracting from browser URL (not web or error): $e',
            );
          }
        }
      } catch (e) {
        print('🔍 Error extracting additional params: $e');
      }

      // Combina tutti i parametri disponibili (widget params hanno priorità)
      final allParams = <String, String>{
        ...queryParams,
        ...additionalParams,
        if (routeParams != null) ...routeParams,
        if (widgetParams != null) ...widgetParams,
      };

      print('🔍 Widget parameters: $widgetParams');
      print('🔍 Route parameters: $routeParams');
      print('🔍 Additional parameters: $additionalParams');

      print('🔍 Combined parameters: $allParams');

      if (allParams.isNotEmpty) {
        // Pre-fill email if provided (sia per l'entità che per la persona)
        if (allParams['email'] != null) {
          _entityEmailController.text = allParams['email']!;
          _personalEmailController.text = allParams['email']!;
          print('🔍 Pre-filled email: ${allParams['email']}');
        }

        // Pre-fill legal entity fields if provided
        if (allParams['legal_name'] != null) {
          _legalNameController.text = allParams['legal_name']!;
          print('🔍 Pre-filled legal_name: ${allParams['legal_name']}');
        }
        if (allParams['identifier_code'] != null) {
          _identifierCodeController.text = allParams['identifier_code']!;
          print(
            '🔍 Pre-filled identifier_code: ${allParams['identifier_code']}',
          );
        }
        if (allParams['legal_rapresentative'] != null) {
          _legalRepresentativeController.text =
              allParams['legal_rapresentative']!;
          // Pre-fill anche il nome personale dal rappresentante legale
          final representativeName = allParams['legal_rapresentative']!;
          _personalNameController.text = representativeName;
          print('🔍 Pre-filled legal_rapresentative: $representativeName');
        }
        if (allParams['entity_email'] != null) {
          _entityEmailController.text = allParams['entity_email']!;
          print('🔍 Pre-filled entity_email: ${allParams['entity_email']}');
        }
        if (allParams['operational_address'] != null) {
          _operationalAddressController.text =
              allParams['operational_address']!;
        }
        if (allParams['operational_city'] != null) {
          _operationalCityController.text = allParams['operational_city']!;
        }
        if (allParams['operational_postal_code'] != null) {
          _operationalPostalCodeController.text =
              allParams['operational_postal_code']!;
        }
        if (allParams['operational_state'] != null) {
          _operationalStateController.text = allParams['operational_state']!;
        }
        if (allParams['operational_country'] != null) {
          _operationalCountryController.text =
              allParams['operational_country']!;
        }
        if (allParams['headquarter_address'] != null) {
          _headquarterAddressController.text =
              allParams['headquarter_address']!;
        }
        if (allParams['headquarter_city'] != null) {
          _headquarterCityController.text = allParams['headquarter_city']!;
        }
        if (allParams['headquarter_postal_code'] != null) {
          _headquarterPostalCodeController.text =
              allParams['headquarter_postal_code']!;
        }
        if (allParams['headquarter_state'] != null) {
          _headquarterStateController.text = allParams['headquarter_state']!;
        }
        if (allParams['headquarter_country'] != null) {
          _headquarterCountryController.text =
              allParams['headquarter_country']!;
        }
        if (allParams['phone'] != null) {
          _phoneController.text = allParams['phone']!;
        }
        if (allParams['pec'] != null) {
          _pecController.text = allParams['pec']!;
        }
        if (allParams['website'] != null) {
          _websiteController.text = allParams['website']!;
        }

        // Se abbiamo un token di invito, mostra un messaggio informativo
        if (allParams['token'] != null) {
          print('🔍 Invitation token found: ${allParams['token']}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    ).getString('invitation_registration_message'),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
      } else {
        // Se non ci sono parametri combinati, prova a estrarre dall'URL completo
        print(
          '🔍 No combined params, trying to extract from current location...',
        );
        final currentLocation = ModalRoute.of(context)?.settings.name;
        if (currentLocation != null && currentLocation.contains('?')) {
          print('🔍 Found URL with parameters: $currentLocation');
          final uri = Uri.parse(currentLocation);
          final locationParams = uri.queryParameters;
          print('🔍 Location parameters: $locationParams');

          // Precompila con i parametri trovati
          if (locationParams['email'] != null) {
            _entityEmailController.text = locationParams['email']!;
            _personalEmailController.text = locationParams['email']!;
            print(
              '🔍 Pre-filled email from location: ${locationParams['email']}',
            );
          }

          if (locationParams['legal_name'] != null) {
            _legalNameController.text = locationParams['legal_name']!;
            print(
              '🔍 Pre-filled legal_name from location: ${locationParams['legal_name']}',
            );
          }
        }
      }
    } catch (e) {
      print('Error loading URL parameters: $e');
      // Non bloccare l'inizializzazione se c'è un errore
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug per verificare se la schermata viene caricata correttamente
    print('🔍 LegalEntityPublicRegistrationScreen build called');
    print('🔍 Widget urlParameters: ${widget.urlParameters}');
    print('🔍 Current route: ${ModalRoute.of(context)?.settings.name}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getString('legal_entity_registration'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Content
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [_buildPricingStep(), _buildPersonalInfoStep()],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isActive
                          ? Colors.blue
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0
                        ? AppLocalizations.of(context).getString('pricing')
                        : AppLocalizations.of(
                            context,
                          ).getString('legal_entity'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.blue : Colors.grey,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPricingStep() {
    return Consumer<PricingProvider>(
      builder: (context, pricingProvider, child) {
        if (pricingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pricingProvider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  '${AppLocalizations.of(context).getString('pricing_plans_loading_error')}: ${pricingProvider.errorMessage}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => pricingProvider.loadPricings(),
                  child: Text(AppLocalizations.of(context).getString('retry')),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).getString('select_plan'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).getString('choose_plan_subtitle'),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Pricing cards
              ...pricingProvider.pricings.map(
                (pricing) => _buildPricingCard(pricing),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPricingCard(Pricing pricing) {
    final isSelected = _selectedPricing?.idPricing == pricing.idPricing;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected ? Colors.blue.shade50 : null,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPricing = pricing;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pricing.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pricing.description,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          pricing.formattedPrice,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : Colors.green,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).getString('per_year'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Features
                ...pricing.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: isSelected ? Colors.blue : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(feature, style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isSelected)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalizations.of(context).getString('plan_selected'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).getString('personal_and_company_info'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(
              context,
            ).getString('enter_personal_company_info'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Personal information form
          Form(
            key: _personalFormKey,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _personalNameController,
                    labelText:
                        '${AppLocalizations.of(context).getString('full_name')} *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_full_name');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _personalEmailController,
                    labelText:
                        '${AppLocalizations.of(context).getString('email_label')} *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_email');
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_valid_email');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: InternationalPhoneField(
                    controller: _personalPhoneController,
                    label: AppLocalizations.of(context).getString('phone'),
                    initialCountryCode: _personalCountryCode,
                    onCountryCodeChanged: (countryCode) {
                      setState(() {
                        _personalCountryCode = countryCode;
                      });
                    },
                    onPhoneNumberChanged: (phoneNumber) {
                      // Il controller viene aggiornato automaticamente
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Sezione Azienda
                Text(
                  AppLocalizations.of(context).getString('company_data'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Company pictures
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final imageSize = isMobile ? 60.0 : 80.0;
                    final buttonHeight = isMobile ? 40.0 : 48.0;

                    return Column(
                      children: [
                        // Logo and Company Picture in a row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: imageSize * 2,
                                        height: imageSize * 2,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _entityProfilePicture != null
                                                ? Colors.green.shade400
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _entityProfilePicture != null
                                              ? kIsWeb &&
                                                        _entityProfilePictureData !=
                                                            null
                                                    ? Image.memory(
                                                        _entityProfilePictureData!,
                                                        fit: BoxFit.cover,
                                                        width: imageSize * 2,
                                                        height: imageSize * 2,
                                                      )
                                                    : Image.file(
                                                        _entityProfilePicture!,
                                                        fit: BoxFit.cover,
                                                        width: imageSize * 2,
                                                        height: imageSize * 2,
                                                      )
                                              : Container(
                                                  color: Colors.grey.shade100,
                                                  child: Icon(
                                                    Icons.business,
                                                    size: imageSize,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      // Remove button (only show when image is loaded)
                                      if (_entityProfilePicture != null)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: _removeEntityProfilePicture,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Loading indicator
                                      if (_isPickingImage)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: buttonHeight,
                                          child: CustomButton(
                                            onPressed: _isPickingImage
                                                ? null
                                                : _pickEntityProfilePicture,
                                            text: _entityProfilePicture != null
                                                ? AppLocalizations.of(
                                                        context,
                                                      ).getString(
                                                        'change_logo',
                                                      ) ??
                                                      'Cambia Logo'
                                                : AppLocalizations.of(
                                                    context,
                                                  ).getString(
                                                    'company_logo_label',
                                                  ),
                                            backgroundColor:
                                                _entityProfilePicture != null
                                                ? Colors.orange.shade600
                                                : Colors.blue.shade600,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (_entityProfilePicture != null) ...[
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          height: buttonHeight,
                                          child: CustomButton(
                                            onPressed:
                                                _removeEntityProfilePicture,
                                            text: '✕',
                                            backgroundColor:
                                                Colors.red.shade600,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  // Status indicator
                                  if (_entityProfilePicture != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '✓ ${AppLocalizations.of(context).getString('ready_for_preview') ?? 'Pronto per anteprima'}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: imageSize * 2,
                                        height: imageSize * 2,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _entityCompanyPicture != null
                                                ? Colors.green.shade400
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: _entityCompanyPicture != null
                                              ? kIsWeb &&
                                                        _entityCompanyPictureData !=
                                                            null
                                                    ? Image.memory(
                                                        _entityCompanyPictureData!,
                                                        fit: BoxFit.cover,
                                                        width: imageSize * 2,
                                                        height: imageSize * 2,
                                                      )
                                                    : Image.file(
                                                        _entityCompanyPicture!,
                                                        fit: BoxFit.cover,
                                                        width: imageSize * 2,
                                                        height: imageSize * 2,
                                                      )
                                              : Container(
                                                  color: Colors.grey.shade100,
                                                  child: Icon(
                                                    Icons.photo_camera,
                                                    size: imageSize,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      // Remove button (only show when image is loaded)
                                      if (_entityCompanyPicture != null)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: _removeEntityCompanyPicture,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Loading indicator
                                      if (_isPickingImage)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: buttonHeight,
                                          child: CustomButton(
                                            onPressed: _isPickingImage
                                                ? null
                                                : _pickEntityCompanyPicture,
                                            text: _entityCompanyPicture != null
                                                ? AppLocalizations.of(
                                                        context,
                                                      ).getString(
                                                        'change_company_photo',
                                                      ) ??
                                                      'Cambia Foto'
                                                : AppLocalizations.of(
                                                    context,
                                                  ).getString(
                                                    'company_photo_label',
                                                  ),
                                            backgroundColor:
                                                _entityCompanyPicture != null
                                                ? Colors.orange.shade600
                                                : Colors.green.shade600,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (_entityCompanyPicture != null) ...[
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          height: buttonHeight,
                                          child: CustomButton(
                                            onPressed:
                                                _removeEntityCompanyPicture,
                                            text: '✕',
                                            backgroundColor:
                                                Colors.red.shade600,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  // Status indicator
                                  if (_entityCompanyPicture != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '✓ ${AppLocalizations.of(context).getString('ready_for_preview') ?? 'Pronto per anteprima'}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Image info text
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        ).getString('image_upload_info') ??
                                        'Le immagini verranno caricate dopo il login. Puoi selezionarle ora per l\'anteprima.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Formati supportati: JPG, PNG, GIF, WebP, AVIF, HEIC, BMP, TIFF',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Campi aziendali
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _legalNameController,
                    labelText:
                        '${AppLocalizations.of(context).getString('legal_entity_name')} *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_legal_entity_name');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _identifierCodeController,
                    labelText:
                        '${AppLocalizations.of(context).getString('identifier_code')} *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_identifier_code');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _entityEmailController,
                    labelText:
                        '${AppLocalizations.of(context).getString('company_email')} *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_company_email');
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_valid_email');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _legalRepresentativeController,
                    labelText:
                        '${AppLocalizations.of(context).getString('legal_representative')} *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        ).getString('enter_legal_representative');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: InternationalPhoneField(
                    controller: _phoneController,
                    label: AppLocalizations.of(
                      context,
                    ).getString('company_phone'),
                    initialCountryCode: _entityCountryCode,
                    onCountryCodeChanged: (countryCode) {
                      setState(() {
                        _entityCountryCode = countryCode;
                      });
                    },
                    onPhoneNumberChanged: (phoneNumber) {
                      // Il controller viene aggiornato automaticamente
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _pecController,
                    labelText: 'PEC',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _websiteController,
                    labelText: 'Sito Web',
                    keyboardType: TextInputType.url,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                onPressed: _previousStep,
                text: AppLocalizations.of(context).getString('back'),
                backgroundColor: Colors.grey,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              onPressed: _isLoading ? null : () => _nextStep(),
              text: _currentStep == _totalSteps - 1
                  ? AppLocalizations.of(
                      context,
                    ).getString('complete_registration')
                  : AppLocalizations.of(context).getString('next'),
              backgroundColor: _currentStep == _totalSteps - 1
                  ? Colors.green
                  : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() async {
    if (_currentStep == _totalSteps - 1) {
      await _completeRegistration();
    } else {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedPricing == null) {
          _showError(
            AppLocalizations.of(context).getString('select_plan_to_continue'),
          );
          return false;
        }
        break;
      case 1:
        if (_personalFormKey.currentState == null ||
            !_personalFormKey.currentState!.validate()) {
          return false;
        }
        break;
    }
    return true;
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Upload profile pictures
      String? personalProfileUrl;
      String? entityProfileUrl;
      String? entityCompanyUrl;

      if (_personalProfilePicture != null) {
        personalProfileUrl = await _imageUploadService.uploadProfilePicture(
          _personalProfilePicture!,
        );
      }

      // 2. Create user first using Supabase service
      final user = AppUser(
        idUser: const Uuid().v4(),
        idUserHash: const Uuid().v4(),
        firstName: _personalNameController.text.split(' ').first,
        lastName: _personalNameController.text.split(' ').length > 1
            ? _personalNameController.text.split(' ').skip(1).join(' ')
            : 'N/A',
        email: _personalEmailController.text,
        phone: '$_personalCountryCode${_personalPhoneController.text}',
        profilePicture: personalProfileUrl,
        fullName: _personalNameController.text,
      );

      // 3. Prepare legal entity data for edge function
      final legalEntityId = const Uuid().v4();
      final legalEntityData = {
        'id_legal_entity': legalEntityId,
        'id_legal_entity_hash': const Uuid().v4(),
        'legal_name': _legalNameController.text,
        'identifier_code': _identifierCodeController.text,
        'operational_address': _operationalAddressController.text,
        'operational_city': _operationalCityController.text,
        'operational_postal_code': _operationalPostalCodeController.text,
        'operational_state': _operationalStateController.text,
        'operational_country': _operationalCountryController.text,
        'headquarter_address': _headquarterAddressController.text,
        'headquarter_city': _headquarterCityController.text,
        'headquarter_postal_code': _headquarterPostalCodeController.text,
        'headquarter_state': _headquarterStateController.text,
        'headquarter_country': _headquarterCountryController.text,
        'legal_rapresentative': _legalRepresentativeController.text,
        'email': _entityEmailController.text,
        'phone': '$_entityCountryCode${_phoneController.text}',
        'pec': _pecController.text,
        'website': _websiteController.text,
        'status': 'pending',
        'logo_picture': null, // Will be uploaded after creation
        'company_picture': null, // Will be uploaded after creation
        'created_at': DateTime.now().toIso8601String(),
        'created_by_id_user': user.idUser,
      };

      // 4. Call edge function to create both user and legal entity
      final edgeFunctionResult =
          await EdgeFunctionService.createLegalEntityWithUser(
            userData: user.toJson(),
            legalEntityData: legalEntityData,
          );

      if (edgeFunctionResult == null || !edgeFunctionResult['ok']) {
        throw Exception(
          'Failed to create user and legal entity via edge function',
        );
      }

      final createdEntity = edgeFunctionResult['data']['legalEntity'];

      // 5. Note: Entity images will be uploaded after user authentication
      // For public registration, we skip image upload and let user upload them after login
      print('ℹ️ Entity images will be uploaded after user authentication');
      print('ℹ️ User can upload logo and company photo after logging in');

      // 6. Handle pricing if selected
      if (_selectedPricing != null) {
        // TODO: Implement actual pricing purchase and database storage
        print(
          'Selected pricing: ${_selectedPricing!.name} - ${_selectedPricing!.formattedPrice}',
        );
        // In a real implementation, this would:
        // - Process payment
        // - Create pricing record in database
        // - Link pricing to legal entity
        // - Set expiration date
      }

      // 6. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).getString('registration_completed_successfully') ?? 
              'Registrazione completata con successo! Puoi caricare logo e foto azienda dopo il login.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('❌ Error completing registration: $e');
      _showError(
        '${AppLocalizations.of(context).getString('registration_error')}: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickPersonalProfilePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _personalProfilePicture = File(image.path);
        });
      }
    } catch (e) {
      _showError(
        '${AppLocalizations.of(context).getString('image_selection_error')}: $e',
      );
    }
  }

  Future<void> _pickEntityProfilePicture() async {
    if (_isPickingImage) return; // Prevent multiple simultaneous picks

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Debug: Print file information (can be removed in production)
        print('🔍 Selected image path: ${image.path}');
        print('🔍 File name: ${image.name}');
        print('🔍 File extension: ${image.name.split('.').last.toLowerCase()}');

        // Validate image file using XFile name for web blob URLs
        bool isValidFormat = false;
        if (image.path.startsWith('blob:')) {
          // For web blob URLs, validate using XFile name
          final fileName = image.name.toLowerCase();
          final validExtensions = [
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.webp',
            '.avif',
            '.heic',
            '.bmp',
            '.tiff',
          ];
          isValidFormat = validExtensions.any((ext) => fileName.endsWith(ext));
          print('🔍 Web blob validation result: $isValidFormat');
        } else {
          // For regular file paths, use the existing validation
          isValidFormat = LegalEntityImageService.validateImageFile(file);
        }

        if (!isValidFormat) {
          print('❌ Image validation failed for: ${image.path}');
          _showError(
            AppLocalizations.of(context).getString('invalid_image_format'),
          );
          return;
        }

        // Check file size (50MB limit for edge functions)
        if (!await LegalEntityImageService.isFileSizeValid(
          file,
          maxSizeMB: 50.0,
        )) {
          _showError(AppLocalizations.of(context).getString('file_too_large'));
          return;
        }

        // Load image data for web platform
        Uint8List? imageData;
        if (kIsWeb) {
          imageData = await image.readAsBytes();
        }

        setState(() {
          _entityProfilePicture = file;
          if (kIsWeb) {
            _entityProfilePictureData = imageData;
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  ).getString('logo_loaded_successfully') ??
                  'Logo caricato con successo!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError(
        '${AppLocalizations.of(context).getString('image_selection_error')}: $e',
      );
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeEntityProfilePicture() {
    setState(() {
      _entityProfilePicture = null;
      if (kIsWeb) {
        _entityProfilePictureData = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).getString('logo_removed') ??
              'Logo rimosso',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickEntityCompanyPicture() async {
    if (_isPickingImage) return; // Prevent multiple simultaneous picks

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Debug: Print file information (can be removed in production)
        print('🔍 Selected company image path: ${image.path}');
        print('🔍 File name: ${image.name}');
        print('🔍 File extension: ${image.name.split('.').last.toLowerCase()}');

        // Validate image file using XFile name for web blob URLs
        bool isValidFormat = false;
        if (image.path.startsWith('blob:')) {
          // For web blob URLs, validate using XFile name
          final fileName = image.name.toLowerCase();
          final validExtensions = [
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.webp',
            '.avif',
            '.heic',
            '.bmp',
            '.tiff',
          ];
          isValidFormat = validExtensions.any((ext) => fileName.endsWith(ext));
          print('🔍 Web blob validation result: $isValidFormat');
        } else {
          // For regular file paths, use the existing validation
          isValidFormat = LegalEntityImageService.validateImageFile(file);
        }

        if (!isValidFormat) {
          print('❌ Company image validation failed for: ${image.path}');
          _showError(
            AppLocalizations.of(context).getString('invalid_image_format'),
          );
          return;
        }

        // Check file size (50MB limit for edge functions)
        if (!await LegalEntityImageService.isFileSizeValid(
          file,
          maxSizeMB: 50.0,
        )) {
          _showError(AppLocalizations.of(context).getString('file_too_large'));
          return;
        }

        // Load image data for web platform
        Uint8List? imageData;
        if (kIsWeb) {
          imageData = await image.readAsBytes();
        }

        setState(() {
          _entityCompanyPicture = file;
          if (kIsWeb) {
            _entityCompanyPictureData = imageData;
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  ).getString('company_photo_loaded_successfully') ??
                  'Foto azienda caricata con successo!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError(
        '${AppLocalizations.of(context).getString('image_selection_error')}: $e',
      );
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeEntityCompanyPicture() {
    setState(() {
      _entityCompanyPicture = null;
      if (kIsWeb) {
        _entityCompanyPictureData = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).getString('company_photo_removed') ??
              'Foto azienda rimossa',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
