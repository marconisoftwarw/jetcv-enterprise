import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LegalEntityRegistrationScreen extends StatefulWidget {
  const LegalEntityRegistrationScreen({super.key});

  @override
  State<LegalEntityRegistrationScreen> createState() =>
      _LegalEntityRegistrationScreenState();
}

class _LegalEntityRegistrationScreenState
    extends State<LegalEntityRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _identifierCodeController = TextEditingController();
  final _operationalAddressController = TextEditingController();
  final _headquartersAddressController = TextEditingController();
  final _legalRepresentativeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String? _selectedCountryCode;
  List<Map<String, String>> _countries = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _identifierCodeController.dispose();
    _operationalAddressController.dispose();
    _headquartersAddressController.dispose();
    _legalRepresentativeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    _countries = [
      {'code': 'US', 'name': 'United States', 'emoji': '🇺🇸'},
      {'code': 'IT', 'name': 'Italy', 'emoji': '🇮🇹'},
      {'code': 'GB', 'name': 'United Kingdom', 'emoji': '🇬🇧'},
      {'code': 'DE', 'name': 'Germany', 'emoji': '🇩🇪'},
      {'code': 'FR', 'name': 'France', 'emoji': '🇫🇷'},
      {'code': 'ES', 'name': 'Spain', 'emoji': '🇪🇸'},
      {'code': 'CA', 'name': 'Canada', 'emoji': '🇨🇦'},
      {'code': 'AU', 'name': 'Australia', 'emoji': '🇦🇺'},
    ];
    setState(() {});
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Submitted'),
          content: const Text(
            'Thank you for your registration! Our team will review your information and contact you within 2-3 business days.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Registration'),
        backgroundColor: Color(AppConfig.primaryColorValue),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(
                          AppConfig.primaryColorValue,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 40,
                        color: Color(AppConfig.primaryColorValue),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Register Your Company',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join our professional certification platform and streamline your business verification process.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Basic Information Section
              _buildSectionHeader('Basic Information', Icons.business),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _legalNameController,
                labelText: 'Legal Name *',
                hintText: 'Enter the legal name of your company',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Legal name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _identifierCodeController,
                labelText: 'Identifier Code *',
                hintText:
                    'Enter tax ID, VAT number, or business registration number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Identifier code is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _legalRepresentativeController,
                      labelText: 'Legal Representative *',
                      hintText: 'Enter the name of the legal representative',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Legal representative is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountryCode,
                      decoration: const InputDecoration(
                        labelText: 'Country *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Row(
                            children: [
                              Text(country['emoji'] ?? ''),
                              const SizedBox(width: 8),
                              Text(country['name'] ?? ''),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Country is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Contact Information Section
              _buildSectionHeader('Contact Information', Icons.contact_mail),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _emailController,
                      labelText: 'Email *',
                      hintText: 'Enter company email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone *',
                      hintText: 'Enter company phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _websiteController,
                labelText: 'Website (Optional)',
                hintText: 'Enter company website URL',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 32),

              // Address Information Section
              _buildSectionHeader('Address Information', Icons.location_on),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _operationalAddressController,
                labelText: 'Operational Address *',
                hintText: 'Enter the operational address of your company',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Operational address is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _headquartersAddressController,
                labelText: 'Headquarters Address *',
                hintText: 'Enter the headquarters address of your company',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Headquarters address is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Additional address fields
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _addressController,
                      labelText: 'Street Address (Optional)',
                      hintText: 'Enter street address',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      labelText: 'City (Optional)',
                      hintText: 'Enter city',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      labelText: 'State/Province (Optional)',
                      hintText: 'Enter state or province',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _postalCodeController,
                      labelText: 'Postal Code (Optional)',
                      hintText: 'Enter postal code',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Terms and Conditions
              Card(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By submitting this registration, you agree to our terms of service and privacy policy. We will review your information and contact you within 2-3 business days.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      text: 'Cancel',
                      variant: ButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _submitRegistration,
                      text: _isLoading
                          ? 'Submitting...'
                          : 'Submit Registration',
                      isLoading: _isLoading,
                      variant: ButtonVariant.filled,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Contact Information
              Center(
                child: Text(
                  'Questions? Contact us at support@jetcv.com',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(AppConfig.primaryColorValue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Color(AppConfig.primaryColorValue),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
