import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_text_field.dart';
import '../../widgets/global_hamburger_menu.dart';
import '../../l10n/app_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  final bool hideMenu;

  const UserProfileScreen({super.key, this.hideMenu = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _jobTitleController;
  late TextEditingController _departmentController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;

  bool _isEditing = false;
  bool _isLoading = false;
  AppUser? _currentUser;
  bool _isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Inizializza i controller con valori vuoti
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _jobTitleController = TextEditingController();
    _departmentController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _zipCodeController = TextEditingController();
  }

  void _updateControllersWithUserData(AppUser user) {
    print('Profile Screen: Updating controllers with user data');
    print('User: ${user.displayName}');
    print('Email: ${user.email}');
    print('First Name: ${user.firstName}');
    print('Last Name: ${user.lastName}');
    print('Phone: ${user.phone}');
    print('Address: ${user.address}');
    print('City: ${user.city}');
    print('Type: ${user.type}');
    print('Profile Complete: ${user.isProfileComplete}');

    _currentUser = user;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _phoneController.text = user.phone ?? '';
    _jobTitleController.text = 'Non specificato';
    _departmentController.text = 'Non specificato';
    _addressController.text = user.address ?? '';
    _cityController.text = user.city ?? '';
    _zipCodeController.text = user.postalCode ?? 'Non specificato';

    // Forza il rebuild del widget
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    // final isDesktop = screenWidth > 1200;

    // Se hideMenu è true, restituisci solo il contenuto senza il menu
    if (widget.hideMenu) {
      return Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Carica i dati dell'utente se non sono disponibili
          if (authProvider.isAuthenticated &&
              authProvider.currentUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await authProvider.loadUserData();
            });
          }

          // Aggiorna i controller quando l'utente è disponibile
          if (authProvider.currentUser != null && _currentUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateControllersWithUserData(authProvider.currentUser!);
            });
          }

          if (authProvider.currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authProvider.isLoading)
                    CircularProgressIndicator(color: AppTheme.primaryBlue)
                  else
                    Icon(
                      Icons.person_off_rounded,
                      size: 64,
                      color: AppTheme.textGray,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.isLoading
                        ? l10n.getString('loading_profile')
                        : l10n.getString('no_user_data'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGray),
                  ),
                  if (!authProvider.isLoading) ...[
                    const SizedBox(height: 16),
                    NeonButton(
                      onPressed: () async {
                        await authProvider.loadUserData();
                      },
                      text: l10n.getString('retry'),
                      isOutlined: true,
                      neonColor: AppTheme.primaryBlue,
                    ),
                  ],
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con foto profilo e informazioni principali
                _buildProfileHeader(authProvider.currentUser!, l10n, isTablet),

                const SizedBox(height: 32),

                // Statistiche e metriche
                _buildStatsSection(authProvider.currentUser!, l10n, isTablet),

                const SizedBox(height: 32),

                // Form per le informazioni personali
                _buildPersonalInfoForm(l10n, isTablet),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MediaQuery.of(context).size.width <= 768
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isMenuExpanded = !_isMenuExpanded;
                  });
                },
              ),
              title: Text(
                l10n.getString('user_profile'),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                if (_isEditing)
                  IconButton(
                    onPressed: _saveProfile,
                    icon: Icon(
                      Icons.save_rounded,
                      color: AppTheme.successGreen,
                    ),
                    tooltip: l10n.getString('save'),
                  ),
                IconButton(
                  onPressed: _toggleEdit,
                  icon: Icon(
                    _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    color: _isEditing
                        ? AppTheme.errorRed
                        : AppTheme.primaryBlue,
                  ),
                  tooltip: _isEditing
                      ? l10n.getString('cancel')
                      : l10n.getString('edit'),
                ),
              ],
            )
          : AppBar(
              title: Text(
                l10n.getString('user_profile'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              surfaceTintColor: Colors.white,
              actions: [
                if (_isEditing)
                  IconButton(
                    onPressed: _saveProfile,
                    icon: Icon(
                      Icons.save_rounded,
                      color: AppTheme.successGreen,
                    ),
                    tooltip: l10n.getString('save_changes'),
                  ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        _initializeControllers();
                      }
                    });
                  },
                  icon: Icon(
                    _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    color: _isEditing
                        ? AppTheme.errorRed
                        : AppTheme.primaryBlue,
                  ),
                  tooltip: _isEditing
                      ? l10n.getString('cancel')
                      : l10n.getString('edit'),
                ),
              ],
            ),
      body: Stack(
        children: [
          Row(
            children: [
              // Navigation Rail - Solo su desktop o quando espanso su mobile
              if (MediaQuery.of(context).size.width > 768 || _isMenuExpanded)
                Container(
                  width: MediaQuery.of(context).size.width > 768 ? 280 : 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return GlobalHamburgerMenu(
                        selectedIndex: 3, // Profilo
                        onDestinationSelected: (index) {
                          setState(() {
                            _isMenuExpanded = false;
                          });
                          _handleNavigation(index);
                        },
                        isExpanded: _isMenuExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _isMenuExpanded = expanded;
                          });
                        },
                        context: context,
                        userType: authProvider.userType,
                      );
                    },
                  ),
                ),

              // Main Content
              Expanded(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    // Carica i dati dell'utente se non sono disponibili
                    if (authProvider.isAuthenticated &&
                        authProvider.currentUser == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        await authProvider.loadUserData();
                      });
                    }

                    // Aggiorna i controller quando l'utente è disponibile
                    if (authProvider.currentUser != null &&
                        _currentUser == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateControllersWithUserData(
                          authProvider.currentUser!,
                        );
                      });
                    }

                    if (authProvider.currentUser == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (authProvider.isLoading)
                              CircularProgressIndicator(
                                color: AppTheme.primaryBlue,
                              )
                            else
                              Icon(
                                Icons.person_off_rounded,
                                size: 64,
                                color: AppTheme.textGray,
                              ),
                            const SizedBox(height: 16),
                            Text(
                              authProvider.isLoading
                                  ? l10n.getString('loading_profile')
                                  : l10n.getString('no_user_data'),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppTheme.textGray),
                            ),
                            if (!authProvider.isLoading) ...[
                              const SizedBox(height: 16),
                              NeonButton(
                                onPressed: () async {
                                  await authProvider.loadUserData();
                                },
                                text: l10n.getString('retry'),
                                isOutlined: true,
                                neonColor: AppTheme.primaryBlue,
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con foto profilo e informazioni principali
                          _buildProfileHeader(
                            authProvider.currentUser!,
                            l10n,
                            isTablet,
                          ),

                          const SizedBox(height: 32),

                          // Statistiche e metriche
                          _buildStatsSection(
                            authProvider.currentUser!,
                            l10n,
                            isTablet,
                          ),

                          const SizedBox(height: 32),

                          // Form per le informazioni personali
                          _buildPersonalInfoForm(l10n, isTablet),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Overlay scuro su mobile quando il menu è aperto
          if (MediaQuery.of(context).size.width <= 768 && _isMenuExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuExpanded = false;
                  });
                },
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    AppUser user,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return EnterpriseCard(
      child: Column(
        children: [
          Row(
            children: [
              // Foto profilo con gradiente
              Container(
                width: isTablet ? 100 : 80,
                height: isTablet ? 100 : 80,
                decoration: BoxDecoration(
                  gradient: user.profilePicture != null
                      ? null
                      : AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: user.profilePicture != null
                      ? Image.network(
                          user.profilePicture!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  user.initials,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppTheme.pureWhite,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            user.initials,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppTheme.pureWhite,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 24),

              // Informazioni principali
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.roleDisplayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? l10n.getString('no_email'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGray),
                    ),
                    const SizedBox(height: 16),

                    // Badge stato profilo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: user.isProfileComplete
                                ? AppTheme.successGreen.withValues(alpha: 0.1)
                                : AppTheme.warningOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: user.isProfileComplete
                                  ? AppTheme.successGreen.withValues(alpha: 0.3)
                                  : AppTheme.warningOrange.withValues(
                                      alpha: 0.3,
                                    ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user.isProfileComplete
                                    ? Icons.check_circle
                                    : Icons.warning,
                                size: 16,
                                color: user.isProfileComplete
                                    ? AppTheme.successGreen
                                    : AppTheme.warningOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.isProfileComplete
                                    ? l10n.getString('profile_complete')
                                    : l10n.getString('profile_incomplete'),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: user.isProfileComplete
                                          ? AppTheme.successGreen
                                          : AppTheme.warningOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            user.type
                                    ?.toString()
                                    .split('.')
                                    .last
                                    .toUpperCase() ??
                                'USER',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_isEditing) ...[
            const SizedBox(height: 24),
            Divider(color: AppTheme.borderGray),
            const SizedBox(height: 24),

            // Upload foto profilo
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    onPressed: _uploadProfilePicture,
                    text: l10n.getString('change_profile_picture'),
                    icon: Icons.camera_alt_rounded,
                    isOutlined: true,
                    neonColor: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeonButton(
                    onPressed: _removeProfilePicture,
                    text: l10n.getString('remove_picture'),
                    icon: Icons.delete_rounded,
                    isOutlined: true,
                    neonColor: AppTheme.errorRed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(AppLocalizations l10n, bool isTablet) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.getString('personal_information'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('first_name'),
                        controller: _firstNameController,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.getString('first_name_required');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('last_name'),
                        controller: _lastNameController,
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.getString('last_name_required');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('phone'),
                        controller: _phoneController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_rounded),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('date_of_birth'),
                        enabled: false,
                        controller: TextEditingController(
                          text: _currentUser?.dateOfBirth != null
                              ? '${_currentUser!.dateOfBirth!.day}/${_currentUser!.dateOfBirth!.month}/${_currentUser!.dateOfBirth!.year}'
                              : l10n.getString('not_specified'),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                EnterpriseTextField(
                  label: l10n.getString('address'),
                  controller: _addressController,
                  enabled: _isEditing,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.location_on_rounded),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('city'),
                        controller: _cityController,
                        enabled: _isEditing,
                        prefixIcon: const Icon(Icons.location_city_rounded),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('postal_code'),
                        controller: _zipCodeController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.local_post_office_rounded),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('gender'),
                        enabled: false,
                        controller: TextEditingController(
                          text: _currentUser?.gender != null
                              ? _currentUser!.gender.toString().split('.').last
                              : l10n.getString('not_specified'),
                        ),
                        prefixIcon: const Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: EnterpriseTextField(
                        label: l10n.getString('language'),
                        enabled: false,
                        controller: TextEditingController(
                          text:
                              _currentUser?.languageCode ??
                              l10n.getString('not_specified'),
                        ),
                        prefixIcon: const Icon(Icons.language_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    AppUser user,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.getString('profile_statistics'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate the number of rows needed based on crossAxisCount
              final crossAxisCount = isTablet ? 4 : 2;
              final itemCount = 4; // Number of stat cards
              final rowCount = (itemCount / crossAxisCount).ceil();

              // Calculate the height needed for the GridView
              final childHeight = isTablet
                  ? 120
                  : 140; // Approximate height per card
              final mainAxisSpacing = 16.0;
              final totalHeight =
                  (rowCount * childHeight) + ((rowCount - 1) * mainAxisSpacing);

              return SizedBox(
                height: totalHeight,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: isTablet ? 1.2 : 1.1,
                  children: [
                    _buildStatCard(
                      l10n.getString('certifications'),
                      '0',
                      Icons.verified_rounded,
                      AppTheme.successGreen,
                      l10n.getString('total_certifications'),
                      '+0',
                      true,
                    ),
                    _buildStatCard(
                      l10n.getString('last_access'),
                      _formatLastAccess(user.updatedAt),
                      Icons.access_time_rounded,
                      AppTheme.primaryBlue,
                      l10n.getString('last_activity'),
                      null,
                      null,
                    ),
                    _buildStatCard(
                      l10n.getString('account_status'),
                      l10n.getString('active'),
                      Icons.check_circle_rounded,
                      AppTheme.successGreen,
                      l10n.getString('verified'),
                      null,
                      null,
                    ),
                    _buildStatCard(
                      l10n.getString('profile_completion'),
                      '${_calculateProfileCompletion(user)}%',
                      Icons.person_rounded,
                      AppTheme.warningOrange,
                      l10n.getString('completion_rate'),
                      null,
                      null,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    String subtitle,
    String? change,
    bool? isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 0,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive == true
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPositive == true
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }

  String _formatLastAccess(DateTime? lastAccess) {
    if (lastAccess == null) return 'Mai';

    final now = DateTime.now();
    final difference = now.difference(lastAccess);

    if (difference.inDays > 0) {
      return '${difference.inDays}g fa';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h fa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m fa';
    } else {
      return 'Ora';
    }
  }

  int _calculateProfileCompletion(AppUser user) {
    int completedFields = 0;
    int totalFields = 8;

    if (user.firstName != null && user.firstName!.isNotEmpty) completedFields++;
    if (user.lastName != null && user.lastName!.isNotEmpty) completedFields++;
    if (user.phone != null && user.phone!.isNotEmpty) completedFields++;
    if (user.address != null && user.address!.isNotEmpty) completedFields++;
    if (user.city != null && user.city!.isNotEmpty) completedFields++;
    if (user.state != null && user.state!.isNotEmpty) completedFields++;
    if (user.postalCode != null && user.postalCode!.isNotEmpty)
      completedFields++;
    if (user.countryCode != null && user.countryCode!.isNotEmpty)
      completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGray, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String description,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Metodi per le azioni
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implementare il salvataggio del profilo con Supabase
      await Future.delayed(const Duration(seconds: 1)); // Simulazione

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.pureWhite),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).getString('profile_updated_successfully'),
                ),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppTheme.pureWhite),
                const SizedBox(width: 8),
                Text(
                  '${AppLocalizations.of(context).getString('error_saving')}: $e',
                ),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _uploadProfilePicture() {
    // TODO: Implementare upload foto profilo con Supabase Storage
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('upload_profile_picture'),
    );
  }

  void _removeProfilePicture() {
    // TODO: Implementare rimozione foto profilo
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('remove_profile_picture'),
    );
  }

  void _changePassword() {
    // TODO: Implementare cambio password con Supabase Auth
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('change_password'),
    );
  }

  void _openNotificationSettings() {
    // TODO: Implementare impostazioni notifiche
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('notification_settings'),
    );
  }

  void _exportData() {
    // TODO: Implementare esportazione dati GDPR
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('export_data'),
    );
  }

  void _deleteAccount() {
    // TODO: Implementare eliminazione account con conferma
    _showFeatureInDevelopment(
      AppLocalizations.of(context).getString('delete_account'),
    );
  }

  void _showFeatureInDevelopment(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.construction, color: AppTheme.pureWhite),
            const SizedBox(width: 8),
            Text(
              '$feature - ${AppLocalizations.of(context).getString('feature_in_development')}',
            ),
          ],
        ),
        backgroundColor: AppTheme.warningOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAirbnbHeader(AppLocalizations l10n, bool isTablet) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: false,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user?.firstName != null && user?.lastName != null
                            ? '${user!.firstName} ${user.lastName}'
                            : l10n.getString('user_profile'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.getString('manage_your_profile'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset dei controller ai valori originali
        _initializeControllers();
      }
    });
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Certificazioni
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2: // Entità Legali
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 3: // Profilo
        // Rimani nella schermata corrente
        break;
      case 4: // Impostazioni
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }
}
