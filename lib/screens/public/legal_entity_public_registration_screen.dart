import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../models/pricing.dart';
import '../../models/user.dart' show AppUser;
import '../../models/legal_entity.dart';
import '../../services/supabase_service.dart';
import '../../services/edge_function_service.dart';
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
  final _personalPasswordController = TextEditingController();
  final _personalPhoneController = TextEditingController();
  String _personalCountryCode = '+39'; // Default to Italy

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

  // Loading states
  bool _isLoading = false;

  // Services
  final SupabaseService _supabaseService = SupabaseService();

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
    _personalPasswordController.dispose();
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
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D1B69),
              Color(0xFF6366F1),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Top Navigation Bar
                _buildTopNavigationBar(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Progress indicator
                          _buildProgressIndicator(),

                          const SizedBox(height: 32),

                          // Content
                          IndexedStack(
                            index: _currentStep,
                            children: [
                              _buildPricingStep(),
                              _buildPersonalInfoStep(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Complete button (only show on second step) - positioned at bottom
                if (_currentStep == 1) _buildCompleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF06B6D4),
                      Color(0xFF3B82F6),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'JetCV Enterprise',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ],
          ),

          // Back Button
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            )
                          : isActive
                          ? const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                      shape: BoxShape.circle,
                      boxShadow: isActive || isCompleted
                          ? [
                              BoxShadow(
                                color:
                                    (isCompleted ? Colors.green : Colors.blue)
                                        .withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    index == 0 ? 'Seleziona Piano' : 'Informazioni Azienda',
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Caricamento piani...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (pricingProvider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Errore nel caricamento dei piani',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  pricingProvider.errorMessage ?? 'Errore sconosciuto',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => pricingProvider.loadPricings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seleziona il Piano',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scegli il piano più adatto alle esigenze della tua azienda',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Pricing cards
            ...pricingProvider.pricings.map(
              (pricing) => _buildPricingCard(pricing),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPricingCard(Pricing pricing) {
    final isSelected = _selectedPricing?.idPricing == pricing.idPricing;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPricing = pricing;
            // Auto-advance to next step when plan is selected
            if (_currentStep == 0) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  setState(() {
                    _currentStep = 1;
                  });
                }
              });
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
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
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pricing.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : Colors.white.withOpacity(0.7),
                            height: 1.4,
                          ),
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
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF10B981),
                          letterSpacing: -1.0,
                        ),
                      ),
                      Text(
                        'all\'anno',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Features
              ...pricing.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : Colors.white.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isSelected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Piano Selezionato',
                        style: TextStyle(
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with selected plan
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informazioni Azienda',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Completa i dati della tua azienda per completare la registrazione',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
              if (_selectedPricing != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Piano Selezionato',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_selectedPricing!.name} - ${_selectedPricing!.formattedPrice}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Form
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
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
                        controller: _personalPasswordController,
                        labelText:
                            '${AppLocalizations.of(context).getString('password')} *',

                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            ).getString('enter_password');
                          }
                          if (value.length < 6) {
                            return AppLocalizations.of(
                              context,
                            ).getString('password_min_length');
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
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                            r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
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
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF10B981).withOpacity(0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Completa Registrazione',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cliccando su "Completa Registrazione" accetti i termini e condizioni',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Create user first using Supabase service
      final user = AppUser(
        idUser: const Uuid().v4(),
        idUserHash: const Uuid().v4(),
        firstName: _personalNameController.text.split(' ').first,
        lastName: _personalNameController.text.split(' ').length > 1
            ? _personalNameController.text.split(' ').skip(1).join(' ')
            : 'N/A',
        email: _personalEmailController.text,
        phone: '$_personalCountryCode${_personalPhoneController.text}',
        profilePicture: null, // Will be uploaded after login
        fullName: _personalNameController.text,
      );

      // 2. Prepare legal entity data for edge function
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

      // 3. Call edge function to create both user and legal entity
      final edgeFunctionResult =
          await EdgeFunctionService.createLegalEntityWithUser(
            userData: user.toJson(),
            legalEntityData: legalEntityData,
            password: _personalPasswordController.text,
          );

      if (edgeFunctionResult == null || !edgeFunctionResult['ok']) {
        throw Exception(
          'Failed to create user and legal entity via edge function',
        );
      }

      final createdEntityId = edgeFunctionResult['idLegalEntity'];
      print('✅ Legal entity created with ID: $createdEntityId');

      // 4. Handle pricing if selected
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

      // 5. Show success message
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
}
