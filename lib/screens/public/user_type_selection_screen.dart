import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/public_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 768;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar
          const PublicTopBar(),

          // Main Content
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
                child: Column(
                  children: [
                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 120 : (isTablet ? 60 : 32),
                            vertical: isDesktop ? 40 : 30,
                          ),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height -
                                      (isDesktop
                                          ? 240
                                          : (isTablet ? 200 : 200)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Logo and Title
                                    _buildHeader(
                                      context,
                                      isDesktop,
                                      isTablet,
                                      isMobile,
                                    ),

                                    SizedBox(height: isDesktop ? 60 : 40),

                                    // User Type Selection
                                    _buildUserTypeSelection(
                                      context,
                                      l10n,
                                      isDesktop,
                                      isTablet,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Logo
        Container(
          width: isDesktop ? 120 : (isTablet ? 100 : 80),
          height: isDesktop ? 120 : (isTablet ? 100 : 80),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Icon(
            Icons.verified_user_rounded,
            size: isDesktop ? 60 : (isTablet ? 50 : 40),
            color: Colors.white,
          ),
        ),

        SizedBox(height: isDesktop ? 32 : 24),

        // App Name
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFF06B6D4), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: Text(
            AppConfig.appName,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -2.0,
              fontSize: isDesktop ? 64 : (isTablet ? 48 : 32),
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: isDesktop ? 16 : 12),

        // Subtitle
        Text(
          l10n.getString('platform_subtitle'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        // Registro Pubblico Button (only on mobile)
        if (isMobile) ...[
          const SizedBox(height: 24),
          _buildRegistroPubblicoButton(context),
        ],
      ],
    );
  }

  Widget _buildUserTypeSelection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      children: [
        Text(
          l10n.getString('select_user_type'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 32 : 28,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildUserTypeCard(
                  context,
                  l10n.getString('certifier'),
                  l10n.getString('certifier_description'),
                  Icons.verified_user_rounded,
                  AppTheme.successGreen,
                  () => _navigateToCertifier(context),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildUserTypeCard(
                  context,
                  l10n.getString('company'),
                  l10n.getString('company_description'),
                  Icons.business_rounded,
                  AppTheme.primaryBlue,
                  () => _navigateToLegalEntity(context),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _buildUserTypeCard(
                  context,
                  l10n.getString('certifier'),
                  l10n.getString('certifier_description'),
                  Icons.verified_user_rounded,
                  AppTheme.successGreen,
                  () => _navigateToCertifier(context),
                  isMobile: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _buildUserTypeCard(
                  context,
                  l10n.getString('company'),
                  l10n.getString('company_description'),
                  Icons.business_rounded,
                  AppTheme.primaryBlue,
                  () => _navigateToLegalEntity(context),
                  isMobile: true,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isMobile = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          height: isMobile ? 180 : 280, // Altezza ridotta per mobile
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    width: isMobile ? 50 : 70,
                    height: isMobile ? 50 : 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 18),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isMobile ? 24 : 35,
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 14 : 18,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isMobile ? 4 : 8),
                ],
              ),

              Expanded(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    height: 1.3,
                    fontSize: isMobile ? 12 : 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: isMobile ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 20,
                  vertical: isMobile ? 4 : 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.getString('select'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCertifier(BuildContext context) {
    Navigator.pushNamed(context, '/certifier-info');
  }

  void _navigateToLegalEntity(BuildContext context) {
    Navigator.pushNamed(context, '/legal-entity-info');
  }

  Widget _buildRegistroPubblicoButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to CV list page
          Navigator.pushNamed(context, '/cv-list');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              l10n.getString('public_register'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    bool isDesktop,
    bool isMobile,
  ) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return SizedBox(
          height: isMobile
              ? 32
              : (isDesktop ? 40 : 36), // Stessa altezza del bottone Accedi
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: 0, // Rimuovo il padding verticale
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Center(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: localeProvider.locale,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: isMobile ? 14 : (isDesktop ? 18 : 16),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : (isDesktop ? 16 : 14),
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: const Color(0xFF1A1F3A),
                  items: localeProvider.getSupportedLanguages().map((language) {
                    return DropdownMenuItem<Locale>(
                      value: Locale(
                        language['code']!,
                        language['code']!.toUpperCase(),
                      ),
                      child: Text(
                        language['flag']!,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : (isDesktop ? 16 : 14),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      localeProvider.setLocale(newLocale);
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
