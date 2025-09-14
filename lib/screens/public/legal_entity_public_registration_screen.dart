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
import '../veriff/veriff_verification_screen.dart';

class LegalEntityPublicRegistrationScreen extends StatefulWidget {
  const LegalEntityPublicRegistrationScreen({super.key});

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
    // Check if this is a link-based registration
    // In a real app, you would get the current URL from the route
    // For now, we'll check if there are any URL parameters passed to the screen
    // This would typically be done through route parameters or deep linking

    try {
      // For demonstration purposes, we'll simulate URL parameters
      // In a real implementation, you would parse the actual URL parameters
      // For now, we'll check if there are any pre-filled values from the route
      final Map<String, String>? routeParams =
          ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

      if (routeParams != null) {
        // Pre-fill email if provided
        if (routeParams['email'] != null) {
          _entityEmailController.text = routeParams['email']!;
          _personalEmailController.text = routeParams['email']!;
        }

        // Pre-fill other fields if provided
        if (routeParams['legal_name'] != null) {
          _legalNameController.text = routeParams['legal_name']!;
        }
        if (routeParams['identifier_code'] != null) {
          _identifierCodeController.text = routeParams['identifier_code']!;
        }
        if (routeParams['legal_rapresentative'] != null) {
          _legalRepresentativeController.text =
              routeParams['legal_rapresentative']!;
        }
        if (routeParams['operational_address'] != null) {
          _operationalAddressController.text =
              routeParams['operational_address']!;
        }
        if (routeParams['operational_city'] != null) {
          _operationalCityController.text = routeParams['operational_city']!;
        }
        if (routeParams['operational_postal_code'] != null) {
          _operationalPostalCodeController.text =
              routeParams['operational_postal_code']!;
        }
        if (routeParams['operational_state'] != null) {
          _operationalStateController.text = routeParams['operational_state']!;
        }
        if (routeParams['operational_country'] != null) {
          _operationalCountryController.text =
              routeParams['operational_country']!;
        }
        if (routeParams['headquarter_address'] != null) {
          _headquarterAddressController.text =
              routeParams['headquarter_address']!;
        }
        if (routeParams['headquarter_city'] != null) {
          _headquarterCityController.text = routeParams['headquarter_city']!;
        }
        if (routeParams['headquarter_postal_code'] != null) {
          _headquarterPostalCodeController.text =
              routeParams['headquarter_postal_code']!;
        }
        if (routeParams['headquarter_state'] != null) {
          _headquarterStateController.text = routeParams['headquarter_state']!;
        }
        if (routeParams['headquarter_country'] != null) {
          _headquarterCountryController.text =
              routeParams['headquarter_country']!;
        }
        if (routeParams['phone'] != null) {
          _phoneController.text = routeParams['phone']!;
        }
        if (routeParams['pec'] != null) {
          _pecController.text = routeParams['pec']!;
        }
        if (routeParams['website'] != null) {
          _websiteController.text = routeParams['website']!;
        }
      }
    } catch (e) {
      print('Error loading URL parameters: $e');
      // Non bloccare l'inizializzazione se c'è un errore
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        ? 'Pricing'
                        : index == 1
                        ? 'Personale'
                        : 'Azienda',
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
                  'Errore nel caricamento dei piani: ${pricingProvider.errorMessage}',
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
              const Text(
                'Scegli il piano più adatto alle tue esigenze.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                        const Text(
                          '/anno',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    child: const Text(
                      'PIANO SELEZIONATO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
          const Text(
            'Informazioni Personali',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Inserisci le tue informazioni personali.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
                  text: 'Carica Foto Profilo',
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
                    labelText: 'Nome Completo *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il tuo nome completo';
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
                        return 'Inserisci la tua email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Inserisci un\'email valida';
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
                    labelText: 'Telefono',
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
          const Text(
            'Informazioni Entità Legale',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Inserisci le informazioni della tua azienda.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
                      text: 'Logo Azienda',
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
                      text: 'Foto Azienda',
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
                    labelText: 'Nome Entità Legale *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il nome dell\'entità legale';
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
                    labelText: 'Codice Identificativo *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il codice identificativo';
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
                    labelText: 'Email Aziendale *',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci l\'email aziendale';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Inserisci un\'email valida';
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
                    labelText: 'Rappresentante Legale *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci il rappresentante legale';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Operational address
                const Text(
                  'Indirizzo Operativo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _operationalAddressController,
                    labelText: 'Indirizzo',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _operationalCityController,
                        labelText: 'Città',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _operationalPostalCodeController,
                        labelText: 'CAP',
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
                        labelText: 'Provincia',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _operationalCountryController,
                        labelText: 'Paese',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Headquarter address
                const Text(
                  'Sede Legale',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _headquarterAddressController,
                    labelText: 'Indirizzo',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _headquarterCityController,
                        labelText: 'Città',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _headquarterPostalCodeController,
                        labelText: 'CAP',
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
                        labelText: 'Provincia',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _headquarterCountryController,
                        labelText: 'Paese',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Contact information
                const Text(
                  'Informazioni di Contatto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
                    controller: _phoneController,
                    labelText: 'Telefono',
                    keyboardType: TextInputType.phone,
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
          _showError('Seleziona un piano per continuare');
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
          'Errore nella creazione dell\'utente e dell\'entità legale',
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
            builder: (context) => VeriffVerificationScreen(
              userData: user.toJson(),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error completing registration: $e');
      _showError('Errore durante la registrazione: $e');
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
      _showError('Errore nella selezione dell\'immagine: $e');
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
      _showError('Errore nella selezione dell\'immagine: $e');
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
      _showError('Errore nella selezione dell\'immagine: $e');
    }
  }
}
