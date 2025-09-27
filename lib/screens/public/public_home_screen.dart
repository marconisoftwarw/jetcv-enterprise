import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/public_top_bar.dart';
import '../../widgets/responsive_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../l10n/app_localizations.dart';
import 'legal_entity_pricing_screen.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _particleAnimationController;

  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Hero animation (fade in + slide up)
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Floating animation for cards
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Particle animation for background
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _heroSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _heroAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _floatingAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleAnimationController,
        curve: Curves.linear,
      ),
    );

    // Start animations
    _heroAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
    _particleAnimationController.repeat();
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _floatingAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar
          const PublicTopBar(),

          // Main Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Ultra Modern Hero Section
                SliverAppBar(
                  expandedHeight: isDesktop ? 800 : (isTablet ? 650 : 400),
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: const Color(0xFF0A0E27),
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    background: _buildModernHeroSection(
                      context,
                      l10n,
                      isDesktop,
                      isTablet,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content Section
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
                      vertical: isDesktop ? 80 : 40,
                    ),
                    child: Column(
                      children: [
                        // Main CTA Section
                        _buildMainCTASection(
                          context,
                          l10n,
                          isDesktop,
                          isTablet,
                        ),

                        const SizedBox(height: 80),

                        // Features Grid
                        _buildFeaturesGrid(context, l10n, isDesktop, isTablet),

                        const SizedBox(height: 80),

                        // User Types Section
                        _buildUserTypesSection(
                          context,
                          l10n,
                          isDesktop,
                          isTablet,
                        ),

                        const SizedBox(height: 80),

                        // Pricing Section
                        _buildPricingSection(
                          context,
                          l10n,
                          isDesktop,
                          isTablet,
                        ),

                        const SizedBox(height: 80),

                        // Stats Section
                        _buildStatsSection(context, l10n, isDesktop, isTablet),

                        const SizedBox(height: 80),

                        // Testimonials Section
                        _buildTestimonialsSection(
                          context,
                          l10n,
                          isDesktop,
                          isTablet,
                        ),
                      ],
                    ),
                  ),
                ),

                // Modern Footer
                SliverToBoxAdapter(
                  child: _buildModernFooter(context, l10n, isDesktop),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ultra Modern Hero Section 2025
  Widget _buildModernHeroSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _heroAnimationController,
        _floatingAnimationController,
        _particleAnimationController,
      ]),
      builder: (context, child) {
        return Container(
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
          child: Stack(
            children: [
              // Animated Particles Background
              _buildParticleBackground(),

              // Glassmorphic Navigation Bar
              _buildGlassmorphicNavBar(context, l10n, isDesktop),

              // Main Hero Content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 120 : (isTablet ? 60 : 32),
                    vertical: isDesktop ? 80 : 60,
                  ),
                  child: FadeTransition(
                    opacity: _heroFadeAnimation,
                    child: SlideTransition(
                      position: _heroSlideAnimation,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Floating Brand Icon with Glow
                            Transform.translate(
                              offset: Offset(
                                0,
                                math.sin(
                                      _floatingAnimation.value * 2 * math.pi,
                                    ) *
                                    8,
                              ),
                              child: Container(
                                width: isDesktop ? 140 : (isTablet ? 100 : 80),
                                height: isDesktop ? 140 : (isTablet ? 100 : 80),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF06B6D4),
                                      Color(0xFF3B82F6),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF06B6D4,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 40,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 20),
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFF8B5CF6,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 60,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 40),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.verified_user_rounded,
                                  size: isDesktop ? 70 : (isTablet ? 50 : 40),
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: isDesktop ? 48 : (isTablet ? 24 : 16),
                            ),

                            // Animated Main Title with Gradient
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFFFFFF),
                                  Color(0xFF06B6D4),
                                  Color(0xFF8B5CF6),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                AppConfig.appName,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -2.0,
                                      fontSize: isDesktop
                                          ? 72
                                          : (isTablet ? 56 : 32),
                                      height: 1.1,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(
                              height: isDesktop ? 24 : (isTablet ? 12 : 8),
                            ),

                            // Modern Subtitle with Typewriter Effect
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: isDesktop ? 800 : 600,
                              ),
                              child: Text(
                                l10n.getString(
                                  'enterprise_certification_platform',
                                ),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontWeight: FontWeight.w400,
                                      fontSize: isDesktop
                                          ? 24
                                          : (isTablet ? 18 : 16),
                                      height: 1.5,
                                      letterSpacing: 0.5,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(
                              height: isDesktop ? 64 : (isTablet ? 32 : 24),
                            ),

                            // Modern CTA Buttons with Micro-interactions
                            if (isDesktop)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildModernCTAButton(
                                    context,
                                    l10n.getString('register_company'),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/legal-entity/register',
                                    ),
                                    isPrimary: true,
                                  ),
                                  const SizedBox(width: 24),
                                  _buildModernCTAButton(
                                    context,
                                    l10n.getString('view_pricing'),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/legal-entity/pricing',
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildModernCTAButton(
                                    context,
                                    l10n.getString('register_company'),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/legal-entity/register',
                                    ),
                                    isPrimary: true,
                                    isFullWidth: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildModernCTAButton(
                                    context,
                                    l10n.getString('view_pricing'),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/legal-entity/pricing',
                                    ),
                                    isFullWidth: true,
                                  ),
                                  const SizedBox(height: 16),
                                  // Login button for mobile
                                  _buildModernCTAButton(
                                    context,
                                    l10n.getString('login'),
                                    () =>
                                        Navigator.pushNamed(context, '/login'),
                                    isSecondary: true,
                                    isFullWidth: true,
                                  ),
                                ],
                              ),

                            if (isDesktop) ...[
                              const SizedBox(height: 80),
                              // Trust Indicators
                              _buildTrustIndicators(context, l10n),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Animated Particle Background
  Widget _buildParticleBackground() {
    return Positioned.fill(
      child: CustomPaint(painter: ParticlePainter(_particleAnimation.value)),
    );
  }

  // Glassmorphic Navigation Bar
  Widget _buildGlassmorphicNavBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(isDesktop ? 32 : 16),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: isDesktop ? 16 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: isDesktop ? 32 : 28,
                    height: isDesktop ? 32 : 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: isDesktop ? 20 : 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isDesktop ? 18 : 16,
                    ),
                  ),
                ],
              ),

              // Navigation Items
              Row(
                children: [
                  _buildGlassNavItem(
                    l10n.getString('public_cvs'),
                    () => Navigator.pushNamed(context, '/cv-list'),
                  ),
                  const SizedBox(width: 16),
                  _buildGlassNavButton(
                    l10n.getString('login'),
                    () => Navigator.pushNamed(context, '/login'),
                    isMobile: !isDesktop,
                  ),
                  if (isDesktop) ...[
                    // Spacer per evitare sovrapposizione con il button delle bandiere
                    const SizedBox(width: 80),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Glass Navigation Item
  Widget _buildGlassNavItem(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // Glass Navigation Button
  Widget _buildGlassNavButton(
    String text,
    VoidCallback onTap, {
    bool isMobile = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 8 : 10,
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Modern CTA Button with Micro-interactions
  Widget _buildModernCTAButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    bool isPrimary = false,
    bool isSecondary = false,
    bool isFullWidth = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isFullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: isPrimary ? 32 : 24,
            vertical: isPrimary ? 16 : 14,
          ),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  )
                : isSecondary
                ? null
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
            border: isSecondary
                ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                fontSize: isPrimary ? 16 : 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Trust Indicators
  Widget _buildTrustIndicators(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTrustItem('10K+', l10n.getString('certifications_issued')),
          _buildTrustItem('500+', l10n.getString('companies_verified')),
          _buildTrustItem('99.9%', l10n.getString('uptime_guarantee')),
          _buildTrustItem('24/7', l10n.getString('support_available')),
        ],
      ),
    );
  }

  Widget _buildTrustItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Navigation Button Builder
  Widget _buildNavButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.pureWhite.withValues(alpha: 0.2)
              : Colors.transparent,
          foregroundColor: AppTheme.pureWhite,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isPrimary
                ? BorderSide(color: AppTheme.pureWhite.withValues(alpha: 0.3))
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.pureWhite,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Hero Button Builder
  Widget _buildHeroButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    bool isPrimary = false,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.pureWhite
              : AppTheme.pureWhite.withValues(alpha: 0.2),
          foregroundColor: isPrimary
              ? AppTheme.primaryBlue
              : AppTheme.pureWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: AppTheme.pureWhite.withValues(alpha: 0.3)),
          ),
          elevation: isPrimary ? 8 : 0,
          shadowColor: AppTheme.pureWhite.withValues(alpha: 0.3),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isPrimary ? AppTheme.primaryBlue : AppTheme.pureWhite,
          ),
        ),
      ),
    );
  }

  // Main CTA Section
  Widget _buildMainCTASection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      children: [
        Text(
          'Piattaforma per Certificatori e Aziende',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            fontSize: isDesktop ? 42 : (isTablet ? 36 : 28),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 24 : 16),

        Text(
          'I certificatori possono verificare competenze e rilasciare certificazioni. Le aziende possono registrarsi e gestire le proprie certificazioni.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
            fontSize: isDesktop ? 20 : 18,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: isDesktop ? 48 : 32),
      ],
    );
  }

  // Modern Button Builder
  Widget _buildModernButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    IconData? icon,
    bool isPrimary = false,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.primaryBlue
              : AppTheme.pureWhite,
          foregroundColor: isPrimary
              ? AppTheme.pureWhite
              : AppTheme.textPrimary,
          elevation: isPrimary ? 8 : 2,
          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: AppTheme.borderGray),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? AppTheme.pureWhite : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Login Prompt
  void _showLoginPrompt(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.getString('please_login_to_create'),
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.pureWhite,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: l10n.getString('login'),
          textColor: AppTheme.primaryBlue,
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      ),
    );
  }

  // Features Grid
  Widget _buildFeaturesGrid(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    final features = [
      {
        'icon': Icons.verified_user_rounded,
        'title': 'Per Certificatori',
        'description':
            'Verifica competenze e rilascia certificazioni professionali in modo sicuro e tracciabile',
        'color': AppTheme.successGreen,
      },
      {
        'icon': Icons.business_rounded,
        'title': 'Per Aziende',
        'description':
            'Registra la tua azienda e gestisci le certificazioni dei tuoi dipendenti',
        'color': AppTheme.primaryBlue,
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Sicurezza Avanzata',
        'description':
            'Piattaforma sicura con crittografia end-to-end per proteggere i dati sensibili',
        'color': AppTheme.warningOrange,
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Gestione Completa',
        'description':
            'Dashboard avanzate per monitorare e gestire tutte le certificazioni',
        'color': AppTheme.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Per Certificatori e Aziende',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: isDesktop ? 32 : 28,
          ),
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: isDesktop ? 1.1 : 1.3,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(
              context,
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
              feature['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  // Modern Feature Card
  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.pureWhite, size: 28),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // User Types Section
  Widget _buildUserTypesSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Tipi di Utenti',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: isDesktop ? 32 : 28,
          ),
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildUserTypeCard(
                  context,
                  'Certificatori',
                  'I professionisti che verificano competenze e rilasciano certificazioni',
                  [
                    'Verifica competenze professionali',
                    'Rilascia certificazioni digitali',
                    'Gestisci il tuo profilo certificatore',
                    'Traccia tutte le certificazioni emesse',
                  ],
                  Icons.verified_user_rounded,
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildUserTypeCard(
                  context,
                  'Aziende',
                  'Le organizzazioni che gestiscono le certificazioni dei dipendenti',
                  [
                    'Registra la tua azienda',
                    'Gestisci certificazioni dipendenti',
                    'Visualizza piani e prezzi',
                    'Monitora le competenze aziendali',
                  ],
                  Icons.business_rounded,
                  AppTheme.primaryBlue,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildUserTypeCard(
                context,
                'Certificatori',
                'I professionisti che verificano competenze e rilasciano certificazioni',
                [
                  'Verifica competenze professionali',
                  'Rilascia certificazioni digitali',
                  'Gestisci il tuo profilo certificatore',
                  'Traccia tutte le certificazioni emesse',
                ],
                Icons.verified_user_rounded,
                AppTheme.successGreen,
              ),
              const SizedBox(height: 24),
              _buildUserTypeCard(
                context,
                'Aziende',
                'Le organizzazioni che gestiscono le certificazioni dei dipendenti',
                [
                  'Registra la tua azienda',
                  'Gestisci certificazioni dipendenti',
                  'Visualizza piani e prezzi',
                  'Monitora le competenze aziendali',
                ],
                Icons.business_rounded,
                AppTheme.primaryBlue,
              ),
            ],
          ),
      ],
    );
  }

  // User Type Card
  Widget _buildUserTypeCard(
    BuildContext context,
    String title,
    String description,
    List<String> features,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppTheme.pureWhite, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textGray,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ultra Modern Stats Section 2025
  Widget _buildStatsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    final stats = [
      {
        'number': '10K+',
        'label': l10n.getString('certifications_issued'),
        'icon': Icons.verified_rounded,
        'color': const Color(0xFF06B6D4),
      },
      {
        'number': '500+',
        'label': l10n.getString('companies_verified'),
        'icon': Icons.business_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'number': '99.9%',
        'label': l10n.getString('uptime_guarantee'),
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'number': '24/7',
        'label': l10n.getString('support_available'),
        'icon': Icons.support_agent_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return AnimatedBuilder(
      animation: _floatingAnimationController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF2D1B69)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A0E27).withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Glassmorphic overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(isDesktop ? 60 : 32),
                child: Column(
                  children: [
                    // Modern Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFF06B6D4),
                          Color(0xFF8B5CF6),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        l10n.getString('trusted_by_thousands'),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: isDesktop ? 48 : 32,
                              letterSpacing: -1.0,
                              height: 1.2,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: isDesktop ? 48 : 32),

                    // Modern Stats Grid
                    if (isDesktop)
                      Row(
                        children: stats.map((stat) {
                          final index = stats.indexOf(stat);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    index == 0 || index == stats.length - 1
                                    ? 0
                                    : 12,
                              ),
                              child: _buildModernStatCard(
                                context,
                                stat['number'] as String,
                                stat['label'] as String,
                                stat['icon'] as IconData,
                                stat['color'] as Color,
                                index,
                                isDesktop,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 2 : 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isTablet ? 1.8 : 3.0,
                        ),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final stat = stats[index];
                          return _buildModernStatCard(
                            context,
                            stat['number'] as String,
                            stat['label'] as String,
                            stat['icon'] as IconData,
                            stat['color'] as Color,
                            index,
                            isDesktop,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Ultra Modern Stat Card 2025
  Widget _buildModernStatCard(
    BuildContext context,
    String number,
    String label,
    IconData icon,
    Color color,
    int index,
    bool isDesktop,
  ) {
    return Transform.translate(
      offset: Offset(
        0,
        math.sin(_floatingAnimation.value * 2 * math.pi + index * 0.5) * 5,
      ),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Icon with Glow
            Container(
              width: isDesktop ? 48 : 40,
              height: isDesktop ? 48 : 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: isDesktop ? 24 : 20),
            ),

            SizedBox(height: isDesktop ? 16 : 12),

            // Animated Number with Gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.white, color],
              ).createShader(bounds),
              child: Text(
                number,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isDesktop ? 28 : 22,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isDesktop ? 8 : 6),

            // Centered Label with Perfect Typography
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: isDesktop ? 12 : 10,
                  height: 1.2,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Testimonials Section
  Widget _buildTestimonialsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('what_our_customers_say'),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 32 : 28,
          ),
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildTestimonialCard(context, l10n)),
              const SizedBox(width: 24),
              Expanded(child: _buildTestimonialCard(context, l10n)),
              const SizedBox(width: 24),
              Expanded(child: _buildTestimonialCard(context, l10n)),
            ],
          )
        else
          Column(
            children: [
              _buildTestimonialCard(context, l10n),
              const SizedBox(height: 24),
              _buildTestimonialCard(context, l10n),
            ],
          ),
      ],
    );
  }

  // Testimonial Card
  Widget _buildTestimonialCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star_rounded,
                color: AppTheme.warningOrange,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            l10n.getString('testimonial_text'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textGray,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                child: Icon(Icons.person, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.getString('customer_name'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.getString('customer_title'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textGray),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern Footer
  Widget _buildModernFooter(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 80 : 40),
      decoration: BoxDecoration(
        color: AppTheme.textPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConfig.appName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppTheme.pureWhite,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.getString(
                          'professional_certification_platform_footer',
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.pureWhite.withValues(alpha: 0.8),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFooterColumn(context, l10n, [
                        l10n.getString('public_cvs'),
                        l10n.getString('pricing'),
                        l10n.getString('about'),
                      ]),
                      _buildFooterColumn(context, l10n, [
                        l10n.getString('privacy_policy'),
                        l10n.getString('terms_of_service'),
                        l10n.getString('contact'),
                      ]),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.getString('professional_certification_platform_footer'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.pureWhite.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

          const SizedBox(height: 40),

          Divider(color: AppTheme.pureWhite.withValues(alpha: 0.2)),

          const SizedBox(height: 24),

          Text(
            '© 2024 ${AppConfig.appName}. ${l10n.getString('all_rights_reserved')}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.pureWhite.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Footer Column
  Widget _buildFooterColumn(
    BuildContext context,
    AppLocalizations l10n,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.pureWhite.withValues(alpha: 0.8),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // Pricing Section
  Widget _buildPricingSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Piani per Aziende',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontSize: isDesktop ? 32 : 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Solo le aziende pagano per utilizzare la piattaforma. I certificatori accedono gratuitamente.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
            fontSize: isDesktop ? 18 : 16,
          ),
        ),
        const SizedBox(height: 24),

        // Note for Certifiers
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.successGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.successGreen, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'I certificatori accedono gratuitamente alla piattaforma per verificare competenze e rilasciare certificazioni.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),
        ResponsiveBreakpoints.isMobile(context)
            ? Column(
                children: [
                  _buildPricingCard(
                    context,
                    'Starter',
                    'Perfetto per piccole aziende',
                    '€29',
                    '/mese',
                    [
                      'Fino a 10 certificazioni',
                      'Supporto email',
                      'Dashboard base',
                    ],
                    AppTheme.primaryBlue,
                    false,
                  ),
                  const SizedBox(height: 24),
                  _buildPricingCard(
                    context,
                    'Professional',
                    'Ideale per aziende in crescita',
                    '€79',
                    '/mese',
                    [
                      'Fino a 100 certificazioni',
                      'Supporto prioritario',
                      'Analytics avanzate',
                    ],
                    AppTheme.successGreen,
                    true,
                  ),
                  const SizedBox(height: 24),
                  _buildPricingCard(
                    context,
                    'Enterprise',
                    'Per grandi organizzazioni',
                    '€199',
                    '/mese',
                    [
                      'Certificazioni illimitate',
                      'Supporto dedicato',
                      'API personalizzate',
                    ],
                    AppTheme.purple,
                    false,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildPricingCard(
                      context,
                      'Starter',
                      'Perfetto per piccole aziende',
                      '€29',
                      '/mese',
                      [
                        'Fino a 10 certificazioni',
                        'Supporto email',
                        'Dashboard base',
                      ],
                      AppTheme.primaryBlue,
                      false,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildPricingCard(
                      context,
                      'Professional',
                      'Ideale per aziende in crescita',
                      '€79',
                      '/mese',
                      [
                        'Fino a 100 certificazioni',
                        'Supporto prioritario',
                        'Analytics avanzate',
                      ],
                      AppTheme.successGreen,
                      true,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildPricingCard(
                      context,
                      'Enterprise',
                      'Per grandi organizzazioni',
                      '€199',
                      '/mese',
                      [
                        'Certificazioni illimitate',
                        'Supporto dedicato',
                        'API personalizzate',
                      ],
                      AppTheme.purple,
                      false,
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 48),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LegalEntityPricingScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 24,
                vertical: isDesktop ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            child: Text(
              'Vedi tutti i piani',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    String title,
    String description,
    String price,
    String period,
    List<String> features,
    Color color,
    bool isPopular,
  ) {
    return ResponsiveCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? color : AppTheme.borderGray,
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PIÙ POPOLARE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isPopular) const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  period,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGray),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: features
                  .map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: color, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalEntityPricingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? color : AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Scegli Piano',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle Painter for animated background
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create animated particles
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.0 + animationValue * 50) % size.width;
      final y = (i * 23.0 + animationValue * 30) % size.height;
      final radius = (math.sin(animationValue * 2 * math.pi + i) * 2 + 3).abs();

      paint.color = [
        const Color(0xFF06B6D4).withValues(alpha: 0.1),
        const Color(0xFF3B82F6).withValues(alpha: 0.1),
        const Color(0xFF8B5CF6).withValues(alpha: 0.1),
      ][i % 3];

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Create larger floating orbs
    for (int i = 0; i < 5; i++) {
      final x = (i * 200.0 + animationValue * 20) % size.width;
      final y = (i * 150.0 + animationValue * 15) % size.height;
      final radius = 30.0 + math.sin(animationValue * math.pi + i) * 10;

      paint.color = [
        const Color(0xFF06B6D4).withValues(alpha: 0.05),
        const Color(0xFF8B5CF6).withValues(alpha: 0.05),
      ][i % 2];

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
