import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon_button.dart';
import '../../widgets/enterprise_card.dart';
import '../../widgets/page_with_floating_language.dart';
import '../../l10n/app_localizations.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    return PageWithFloatingLanguage(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            // Hero Section with Modern App Bar
            SliverAppBar(
              expandedHeight: isDesktop ? 500 : (isTablet ? 400 : 350),
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                background: _buildHeroSection(
                  context,
                  l10n,
                  isDesktop,
                  isTablet,
                ),
              ),
              actions: [
                _buildNavButton(
                  context,
                  l10n.getString('public_cvs'),
                  () => Navigator.pushNamed(context, '/cv-list'),
                ),
                _buildNavButton(
                  context,
                  l10n.getString('pricing'),
                  () => Navigator.pushNamed(context, '/legal-entity/pricing'),
                ),
                _buildNavButton(
                  context,
                  l10n.getString('login'),
                  () => Navigator.pushNamed(context, '/login'),
                  isPrimary: true,
                ),
                const SizedBox(width: 16),
              ],
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
                    _buildMainCTASection(context, l10n, isDesktop, isTablet),

                    const SizedBox(height: 80),

                    // Features Grid
                    _buildFeaturesGrid(context, l10n, isDesktop, isTablet),

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
    );
  }

  // Hero Section Builder
  Widget _buildHeroSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.8),
            AppTheme.purple.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.pureWhite.withValues(alpha: 0.1),
                      AppTheme.pureWhite.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : (isTablet ? 40 : 24),
                vertical: 40,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo/Brand
                    Container(
                      width: isDesktop ? 120 : 100,
                      height: isDesktop ? 120 : 100,
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.pureWhite.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.pureWhite.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: isDesktop ? 60 : 50,
                        color: AppTheme.pureWhite,
                      ),
                    ),

                    SizedBox(height: isDesktop ? 32 : 24),

                    // Main Title
                    Text(
                      AppConfig.appName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.pureWhite,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        fontSize: isDesktop ? 48 : (isTablet ? 40 : 32),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isDesktop ? 16 : 12),

                    // Subtitle
                    Text(
                      l10n.getString('enterprise_certification_platform'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.pureWhite.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: isDesktop ? 20 : 18,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isDesktop ? 40 : 32),

                    // Hero CTA Buttons
                    if (isDesktop)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeroButton(
                            context,
                            l10n.getString('register_company'),
                            () => Navigator.pushNamed(
                              context,
                              '/legal-entity/register',
                            ),
                            isPrimary: true,
                          ),
                          const SizedBox(width: 20),
                          _buildHeroButton(
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
                          _buildHeroButton(
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
                          _buildHeroButton(
                            context,
                            l10n.getString('view_pricing'),
                            () => Navigator.pushNamed(
                              context,
                              '/legal-entity/pricing',
                            ),
                            isFullWidth: true,
                          ),
                        ],
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
          l10n.getString('professional_certification_platform'),
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
          l10n.getString('streamline_business_verification'),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
            fontSize: isDesktop ? 20 : 18,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        // CTA Buttons Grid
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildModernButton(
                  context,
                  l10n.getString('create_certification'),
                  () => _showLoginPrompt(context, l10n),
                  icon: Icons.verified_user_rounded,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildModernButton(
                  context,
                  l10n.getString('register_company'),
                  () => Navigator.pushNamed(context, '/legal-entity/register'),
                  icon: Icons.business_rounded,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildModernButton(
                  context,
                  l10n.getString('explore_cvs'),
                  () => Navigator.pushNamed(context, '/cv-list'),
                  icon: Icons.description_rounded,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildModernButton(
                context,
                l10n.getString('create_certification'),
                () => _showLoginPrompt(context, l10n),
                icon: Icons.verified_user_rounded,
                isPrimary: true,
                isFullWidth: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildModernButton(
                      context,
                      l10n.getString('register_company'),
                      () => Navigator.pushNamed(
                        context,
                        '/legal-entity/register',
                      ),
                      icon: Icons.business_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernButton(
                      context,
                      l10n.getString('explore_cvs'),
                      () => Navigator.pushNamed(context, '/cv-list'),
                      icon: Icons.description_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppTheme.pureWhite : AppTheme.textPrimary,
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
        'title': l10n.getString('identity_verification'),
        'description': l10n.getString('secure_reliable_verification'),
        'color': AppTheme.successGreen,
      },
      {
        'icon': Icons.business_rounded,
        'title': l10n.getString('legal_entity_management'),
        'description': l10n.getString('comprehensive_management'),
        'color': AppTheme.primaryBlue,
      },
      {
        'icon': Icons.security_rounded,
        'title': l10n.getString('secure_platform'),
        'description': l10n.getString('enterprise_grade_security'),
        'color': AppTheme.warningOrange,
      },
      {
        'icon': Icons.analytics_rounded,
        'title': l10n.getString('analytics_reporting'),
        'description': l10n.getString('advanced_analytics'),
        'color': AppTheme.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('key_features'),
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

  // Stats Section
  Widget _buildStatsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    final stats = [
      {'number': '10K+', 'label': l10n.getString('certifications_issued')},
      {'number': '500+', 'label': l10n.getString('companies_verified')},
      {'number': '99.9%', 'label': l10n.getString('uptime_guarantee')},
      {'number': '24/7', 'label': l10n.getString('support_available')},
    ];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 60 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.05),
            AppTheme.purple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            l10n.getString('trusted_by_thousands'),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: isDesktop ? 32 : 28,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isDesktop ? 48 : 32),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _buildStatCard(
                context,
                stat['number'] as String,
                stat['label'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  // Stat Card
  Widget _buildStatCard(BuildContext context, String number, String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textGray,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
}
