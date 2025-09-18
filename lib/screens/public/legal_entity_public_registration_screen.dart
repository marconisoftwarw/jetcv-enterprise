import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../models/pricing.dart';
import '../../models/user.dart' show AppUser;
import '../../models/legal_entity.dart';
import '../../services/supabase_service.dart';
import '../../services/image_upload_service.dart';

import '../../providers/pricing_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../l10n/app_localizations.dart';
import '../../services/url_parameter_service.dart';
import '../veriff/veriff_verification_screen.dart';

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
  final int _totalSteps = 3;

  // Pricing
  Pricing? _selectedPricing;

  // Personal information
  final _personalNameController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _personalPhoneController = TextEditingController();
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
  final _pecController = TextEditingController();
  final _websiteController = TextEditingController();
  File? _entityProfilePicture;
  File? _entityCompanyPicture;

  // Loading states
  bool _isLoading = false;

  // Services
  final SupabaseService _supabaseService = SupabaseService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Carica i dati dei pricing dopo che il widget è stato costruito
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
      print('🔍 Loading URL parameters for legal entity registration...');

      // Estrai parametri dall'URL corrente (per inviti via email)
      final uri = Uri.base;
      final queryParams = uri.queryParameters;

      print('🔍 Current URL: ${uri.toString()}');
      print('🔍 Query parameters: $queryParams');

      // Controlla anche i parametri del route (per navigazione interna)
      final Map<String, String>? routeParams =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

      // Parametri passati dal costruttore (dal routing)
      final Map<String, String>? widgetParams = widget.urlParameters;

      // Combina tutti i parametri disponibili (widget params hanno priorità)
      final allParams = <String, String>{
        ...queryParams,
        if (routeParams != null) ...routeParams,
        if (widgetParams != null) ...widgetParams,
      };

      print('🔍 Widget parameters: $widgetParams');
      print('🔍 Route parameters: $routeParams');

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
                    'Registrazione tramite invito - Campi precompilati',
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
        print('🔍 No combined params, trying to extract from current location...');
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
            print('🔍 Pre-filled email from location: ${locationParams['email']}');
          }
          
          if (locationParams['legal_name'] != null) {
            _legalNameController.text = locationParams['legal_name']!;
            print('🔍 Pre-filled legal_name from location: ${locationParams['legal_name']}');
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
                children: [
                  _buildPricingStep(),
                  _buildPersonalInfoStep(),
                  _buildLegalEntityStep(),
                ],
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
                        : index == 1
                        ? AppLocalizations.of(
                            context,
                          ).getString('personal_info')
                        : AppLocalizations.of(
                            context,
                          ).getString('company_info'),
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
            AppLocalizations.of(context).getString('personal_information'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).getString('enter_personal_info'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Profile picture
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _personalProfilePicture != null
                      ? FileImage(_personalProfilePicture!)
                      : null,
                  child: _personalProfilePicture == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: _pickPersonalProfilePicture,
                  text: AppLocalizations.of(
                    context,
                  ).getString('upload_profile_photo'),
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
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
                    labelText: 'Email *',
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
                  child: CustomTextField(
                    controller: _personalPhoneController,
                    labelText: AppLocalizations.of(context).getString('phone'),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalEntityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).getString('legal_entity_information'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).getString('enter_company_info'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Company pictures
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _entityProfilePicture != null
                          ? FileImage(_entityProfilePicture!)
                          : null,
                      child: _entityProfilePicture == null
                          ? const Icon(Icons.business, size: 40)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      onPressed: _pickEntityProfilePicture,
                      text: AppLocalizations.of(
                        context,
                      ).getString('company_logo'),
                      backgroundColor: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _entityCompanyPicture != null
                          ? FileImage(_entityCompanyPicture!)
                          : null,
                      child: _entityCompanyPicture == null
                          ? const Icon(Icons.photo_camera, size: 40)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      onPressed: _pickEntityCompanyPicture,
                      text: AppLocalizations.of(
                        context,
                      ).getString('company_photo'),
                      backgroundColor: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Legal entity form
          Form(
            key: _entityFormKey,
            child: Column(
              children: [
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

                // Operational address
                Text(
                  AppLocalizations.of(context).getString('operational_address'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _operationalAddressController,
                    labelText: AppLocalizations.of(
                      context,
                    ).getString('address'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _operationalCityController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('city'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _operationalPostalCodeController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('postal_code'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _operationalStateController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('province'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _operationalCountryController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('country'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Headquarter address
                Text(
                  AppLocalizations.of(context).getString('headquarters'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _headquarterAddressController,
                    labelText: AppLocalizations.of(
                      context,
                    ).getString('address'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _headquarterCityController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('city'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _headquarterPostalCodeController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('postal_code'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _headquarterStateController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('province'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _headquarterCountryController,
                        labelText: AppLocalizations.of(
                          context,
                        ).getString('country'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Contact information
                Text(
                  AppLocalizations.of(context).getString('contact_information'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _phoneController,
                    labelText: AppLocalizations.of(context).getString('phone'),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _pecController,
                    labelText: AppLocalizations.of(context).getString('pec'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _websiteController,
                    labelText: AppLocalizations.of(
                      context,
                    ).getString('website'),
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
      case 2:
        if (_entityFormKey.currentState == null ||
            !_entityFormKey.currentState!.validate()) {
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
      if (_entityProfilePicture != null) {
        entityProfileUrl = await _imageUploadService.uploadEntityProfilePicture(
          _entityProfilePicture!,
        );
      }
      if (_entityCompanyPicture != null) {
        entityCompanyUrl = await _imageUploadService.uploadEntityCompanyPicture(
          _entityCompanyPicture!,
        );
      }

      // 2. Create user
      final user = AppUser(
        idUser: const Uuid().v4(),
        idUserHash: const Uuid().v4(),
        firstName: _personalNameController.text.split(' ').first,
        lastName: _personalNameController.text.split(' ').length > 1
            ? _personalNameController.text.split(' ').skip(1).join(' ')
            : 'N/A',
        email: _personalEmailController.text,
        phone: _personalPhoneController.text,
        profilePicture: personalProfileUrl,
        fullName: _personalNameController.text,
      );

      // 3. Create legal entity data
      final legalEntity = LegalEntity(
        idLegalEntity: const Uuid().v4(),
        idLegalEntityHash: const Uuid().v4(),
        legalName: _legalNameController.text,
        identifierCode: _identifierCodeController.text,
        email: _entityEmailController.text,
        legalRapresentative: _legalRepresentativeController.text,
        operationalAddress: _operationalAddressController.text,
        operationalCity: _operationalCityController.text,
        operationalPostalCode: _operationalPostalCodeController.text,
        operationalState: _operationalStateController.text,
        operationalCountry: _operationalCountryController.text,
        headquarterAddress: _headquarterAddressController.text,
        headquarterCity: _headquarterCityController.text,
        headquarterPostalCode: _headquarterPostalCodeController.text,
        headquarterState: _headquarterStateController.text,
        headquarterCountry: _headquarterCountryController.text,
        phone: _phoneController.text,
        pec: _pecController.text,
        website: _websiteController.text,
        logoPicture: entityProfileUrl,
        companyPicture: entityCompanyUrl,
        status: LegalEntityStatus.pending,
      );

      // 4. Create both user and legal entity in one operation
      final result = await _supabaseService.createLegalEntityWithUser(
        userData: user.toJson(),
        legalEntityData: {
          ...legalEntity.toJson(),
          'createdByIdUser': user.idUser,
        },
      );

      if (result == null) {
        throw Exception(
          AppLocalizations.of(context).getString('user_entity_creation_error'),
        );
      }

      final createdUser = result['user'];
      final createdEntity = result['legalEntity'];

      // 5. Create pricing record (temporary/mock for now)
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
              ).getString('registration_completed_successfully'),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Veriff verification screen with user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VeriffVerificationScreen(userData: user.toJson()),
          ),
        );
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
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _entityProfilePicture = File(image.path);
        });
      }
    } catch (e) {
      _showError(
        '${AppLocalizations.of(context).getString('image_selection_error')}: $e',
      );
    }
  }

  Future<void> _pickEntityCompanyPicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _entityCompanyPicture = File(image.path);
        });
      }
    } catch (e) {
      _showError(
        '${AppLocalizations.of(context).getString('image_selection_error')}: $e',
      );
    }
  }
}
