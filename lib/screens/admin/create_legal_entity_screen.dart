import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/legal_entity_provider.dart';
import '../../widgets/custom_text_field.dart';

class CreateLegalEntityScreen extends StatefulWidget {
  const CreateLegalEntityScreen({super.key});

  @override
  State<CreateLegalEntityScreen> createState() =>
      _CreateLegalEntityScreenState();
}

class _CreateLegalEntityScreenState extends State<CreateLegalEntityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _identifierCodeController = TextEditingController();
  final _operationalAddressController = TextEditingController();
  final _headquartersAddressController = TextEditingController();
  final _legalRepresentativeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pecController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryCodeController = TextEditingController();
  bool _isLoading = false;

  String? _selectedCountryCode;
  List<Map<String, String>> _countries = [];

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
    _pecController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryCodeController.dispose();
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

  Future<void> _createLegalEntity() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LegalEntityProvider>();

    final entityData = {
      'status': 'pending', // Campo richiesto dalla Edge Function
      'legal_name': _legalNameController.text.trim(),
      'identifier_code': _identifierCodeController.text.trim(),
      'operational_address': _operationalAddressController.text.trim(),
      'operational_city': _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      'operational_state': _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      'operational_postal_code': _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      'operational_country': _selectedCountryCode,
      'headquarter_address': _headquartersAddressController.text.trim(),
      'legal_rapresentative': _legalRepresentativeController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'pec': _pecController.text.trim().isEmpty
          ? null
          : _pecController.text.trim(),
      'website': _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
    };

    final entity = await provider.createLegalEntity(entityData);

    if (entity != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entity.legalName} has been created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Legal Entity'),
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
              // Basic Information Section
              _buildSectionHeader('Basic Information', Icons.business),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _legalNameController,
                labelText: 'Legal Name *',
                hintText: 'Enter the legal name of the company',
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

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _pecController,
                      labelText: 'PEC (Optional)',
                      hintText: 'Enter PEC email if applicable',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _websiteController,
                      labelText: 'Website (Optional)',
                      hintText: 'Enter company website URL',
                      keyboardType: TextInputType.url,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Address Information Section
              _buildSectionHeader('Address Information', Icons.location_on),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _operationalAddressController,
                labelText: 'Operational Address *',
                hintText: 'Enter the operational address of the company',
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
                hintText: 'Enter the headquarters address of the company',
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

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createLegalEntity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConfig.primaryColorValue),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Create Entity'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Error Message
              Consumer<LegalEntityProvider>(
                builder: (context, provider, child) {
                  if (provider.errorMessage != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red[600]),
                            onPressed: provider.clearError,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
