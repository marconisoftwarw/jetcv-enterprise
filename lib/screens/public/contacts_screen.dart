import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/public_top_bar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _priorityController = TextEditingController();

  String _selectedDepartment = '';
  String _selectedCountry = '';
  bool _isUrgent = false;
  bool _agreeToTerms = false;
  bool _subscribeNewsletter = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PublicTopBar(
            showBackButton: true,
            title: l10n.getString('contacts_title'),
          ),
          Expanded(
            child: Container(
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 120 : (isTablet ? 60 : 24),
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeaderSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Contact Form and Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact Form
                          Expanded(
                            flex: isDesktop ? 2 : 1,
                            child: _buildContactForm(
                              context,
                              l10n,
                              isDesktop,
                              isTablet,
                              isMobile,
                            ),
                          ),

                          if (isDesktop) ...[
                            const SizedBox(width: 60),
                            // Contact Info
                            Expanded(
                              flex: 1,
                              child: _buildContactInfo(
                                context,
                                l10n,
                                isDesktop,
                                isTablet,
                                isMobile,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (!isDesktop) ...[
                        SizedBox(height: isDesktop ? 60 : 40),
                        _buildContactInfo(
                          context,
                          l10n,
                          isDesktop,
                          isTablet,
                          isMobile,
                        ),
                      ],

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Team Section
                      _buildTeamSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Office Locations
                      _buildOfficeLocations(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 40 : 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40 : (isTablet ? 30 : 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.contact_support,
                  color: Color(0xFF6366F1),
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('contacts_title'),
                      style: TextStyle(
                        fontSize: isDesktop ? 36 : (isTablet ? 28 : 24),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1F3A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('contacts_subtitle'),
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.getString('contacts_description'),
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.getString('contact_form_title'),
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1F3A),
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            _buildSectionHeader(
              l10n.getString('personal_info_title'),
              Icons.person,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    controller: _nameController,
                    label: l10n.getString('name_label'),
                    hint: l10n.getString('name_hint'),
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getString('name_required');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField(
                    controller: _emailController,
                    label: l10n.getString('email_label'),
                    hint: l10n.getString('email_hint'),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getString('email_required');
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return l10n.getString('email_invalid');
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
                  child: _buildFormField(
                    controller: _companyController,
                    label: l10n.getString('company_label'),
                    hint: l10n.getString('company_hint'),
                    icon: Icons.business_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField(
                    controller: _phoneController,
                    label: l10n.getString('phone_label'),
                    hint: l10n.getString('phone_hint'),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Department and Priority Section
            _buildSectionHeader(
              l10n.getString('request_details_title'),
              Icons.assignment_outlined,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: l10n.getString('department_label'),
                    value: _selectedDepartment,
                    items: [
                      l10n.getString('department_sales'),
                      l10n.getString('department_support'),
                      l10n.getString('department_technical'),
                      l10n.getString('department_partnerships'),
                      l10n.getString('department_general'),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedDepartment = value ?? ''),
                    icon: Icons.business_center_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: l10n.getString('country_label'),
                    value: _selectedCountry,
                    items: [
                      l10n.getString('country_italy'),
                      l10n.getString('country_usa'),
                      l10n.getString('country_germany'),
                      l10n.getString('country_france'),
                      l10n.getString('country_uk'),
                      l10n.getString('country_other'),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCountry = value ?? ''),
                    icon: Icons.public_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    controller: _subjectController,
                    label: l10n.getString('subject_label'),
                    hint: l10n.getString('subject_hint'),
                    icon: Icons.subject_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getString('subject_required');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField(
                    controller: _priorityController,
                    label: l10n.getString('priority_label'),
                    hint: l10n.getString('priority_hint'),
                    icon: Icons.priority_high_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Urgent Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isUrgent,
                  onChanged: (value) =>
                      setState(() => _isUrgent = value ?? false),
                  activeColor: const Color(0xFFEF4444),
                ),
                Text(
                  l10n.getString('urgent_request'),
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Message Section
            _buildSectionHeader(
              l10n.getString('message_title'),
              Icons.message_outlined,
            ),
            const SizedBox(height: 16),

            _buildFormField(
              controller: _messageController,
              label: l10n.getString('message_label'),
              hint: l10n.getString('message_hint'),
              icon: Icons.message_outlined,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.getString('message_required');
                }
                if (value.length < 10) {
                  return l10n.getString('message_too_short');
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Terms and Newsletter
            Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) =>
                          setState(() => _agreeToTerms = value ?? false),
                      activeColor: const Color(0xFF6366F1),
                    ),
                    Expanded(
                      child: Text(
                        l10n.getString('agree_terms'),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _subscribeNewsletter,
                      onChanged: (value) =>
                          setState(() => _subscribeNewsletter = value ?? false),
                      activeColor: const Color(0xFF6366F1),
                    ),
                    Expanded(
                      child: Text(
                        l10n.getString('subscribe_newsletter'),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      l10n.getString('send_message'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getString('contact_info_title'),
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1F3A),
            ),
          ),
          const SizedBox(height: 24),

          _buildContactItem(
            icon: Icons.email,
            title: l10n.getString('email_contact'),
            subtitle: 'info@jetcv.com',
            color: const Color(0xFF6366F1),
          ),

          const SizedBox(height: 20),

          _buildContactItem(
            icon: Icons.phone,
            title: l10n.getString('phone_contact'),
            subtitle: '+39 02 1234 5678',
            color: const Color(0xFF10B981),
          ),

          const SizedBox(height: 20),

          _buildContactItem(
            icon: Icons.location_on,
            title: l10n.getString('address_contact'),
            subtitle: l10n.getString('address_full'),
            color: const Color(0xFFF59E0B),
          ),

          const SizedBox(height: 20),

          _buildContactItem(
            icon: Icons.access_time,
            title: l10n.getString('business_hours'),
            subtitle: l10n.getString('business_hours_full'),
            color: const Color(0xFF8B5CF6),
          ),

          const SizedBox(height: 32),

          // Response Time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF6366F1), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.getString('response_time'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1F3A),
                        ),
                      ),
                      Text(
                        l10n.getString('response_time_detail'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getString('team_section_title'),
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1F3A),
            ),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildTeamMember(
                name: 'Marco Rossi',
                position: l10n.getString('ceo_position'),
                email: 'marco.rossi@jetcv.com',
                avatar: 'M',
                color: const Color(0xFF6366F1),
              ),
              _buildTeamMember(
                name: 'Sarah Johnson',
                position: l10n.getString('cto_position'),
                email: 'sarah.johnson@jetcv.com',
                avatar: 'S',
                color: const Color(0xFF10B981),
              ),
              _buildTeamMember(
                name: 'Alessandro Bianchi',
                position: l10n.getString('sales_director_position'),
                email: 'alessandro.bianchi@jetcv.com',
                avatar: 'A',
                color: const Color(0xFFF59E0B),
              ),
              _buildTeamMember(
                name: 'Emma Wilson',
                position: l10n.getString('support_manager_position'),
                email: 'emma.wilson@jetcv.com',
                avatar: 'E',
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeLocations(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getString('office_locations_title'),
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1F3A),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildOfficeLocation(
                  city: 'Milano',
                  country: 'Italia',
                  address: l10n.getString('milan_address'),
                  phone: '+39 02 1234 5678',
                  color: const Color(0xFF6366F1),
                ),
              ),
              if (isDesktop) const SizedBox(width: 20),
              if (isDesktop)
                Expanded(
                  child: _buildOfficeLocation(
                    city: 'New York',
                    country: 'USA',
                    address: l10n.getString('ny_address'),
                    phone: '+1 555 123 4567',
                    color: const Color(0xFF10B981),
                  ),
                ),
            ],
          ),

          if (!isDesktop) ...[
            const SizedBox(height: 20),
            _buildOfficeLocation(
              city: 'New York',
              country: 'USA',
              address: l10n.getString('ny_address'),
              phone: '+1 555 123 4567',
              color: const Color(0xFF10B981),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F3A),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F3A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String position,
    required String email,
    required String avatar,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Text(
              avatar,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F3A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            position,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeLocation({
    required String city,
    required String country,
    required String address,
    required String phone,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$city, $country',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Text(
            phone,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).getString('form_success_title'),
          ),
          content: Text(
            AppLocalizations.of(context).getString('form_success_message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset form
                _formKey.currentState!.reset();
                _nameController.clear();
                _emailController.clear();
                _companyController.clear();
                _phoneController.clear();
                _subjectController.clear();
                _messageController.clear();
                _priorityController.clear();
                setState(() {
                  _selectedDepartment = '';
                  _selectedCountry = '';
                  _isUrgent = false;
                  _agreeToTerms = false;
                  _subscribeNewsletter = false;
                });
              },
              child: Text(AppLocalizations.of(context).getString('ok')),
            ),
          ],
        ),
      );
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).getString('agree_terms_required'),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
