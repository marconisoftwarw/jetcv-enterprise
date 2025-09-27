import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/public_top_bar.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

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
          // Top Bar
          const PublicTopBar(showBackButton: true, title: 'Funzionalità'),
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 120 : (isTablet ? 60 : 24),
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section with Social Proof
                      _buildHeroSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 40 : 30),

                      // Social Proof Section
                      _buildSocialProofSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // What We Do Section
                      _buildWhatWeDoSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Key Features Section
                      _buildKeyFeaturesSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // ROI Calculator Section
                      _buildROICalculatorSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Testimonials Section
                      _buildTestimonialsSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Competitive Advantages Section
                      _buildCompetitiveAdvantagesSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Platform Benefits Section
                      _buildPlatformBenefitsSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Technology Stack Section
                      _buildTechnologyStackSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Urgency Section
                      _buildUrgencySection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // CTA Section
                      _buildCTASection(
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

  Widget _buildHeroSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Badge di urgenza
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 8 : 6,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            l10n.getString('limited_time_offer'),
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 24 : 16),

        // Titolo principale con emoji
        Text(
          l10n.getString('features_title'),
          style: TextStyle(
            fontSize: isDesktop ? 48 : (isTablet ? 36 : 28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 16 : 12),

        // Sottotitolo persuasivo
        Text(
          l10n.getString('features_subtitle'),
          style: TextStyle(
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 24 : 16),

        // Statistiche impressionanti
        Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                l10n.getString('stat_1_number'),
                l10n.getString('stat_1_label'),
                isDesktop,
                isTablet,
              ),
              Container(
                width: 1,
                height: isDesktop ? 40 : 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                context,
                l10n.getString('stat_2_number'),
                l10n.getString('stat_2_label'),
                isDesktop,
                isTablet,
              ),
              Container(
                width: 1,
                height: isDesktop ? 40 : 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                context,
                l10n.getString('stat_3_number'),
                l10n.getString('stat_3_label'),
                isDesktop,
                isTablet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String number,
    String label,
    bool isDesktop,
    bool isTablet,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
          ),
        ),
        SizedBox(height: isDesktop ? 4 : 2),
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWhatWeDoSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('what_we_do_title'),
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.getString('what_we_do_description'),
                style: TextStyle(
                  fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 20),
              _buildFeatureGrid(context, l10n, isDesktop, isTablet, isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final features = [
      {
        'icon': Icons.verified_user,
        'title': l10n.getString('feature_certification'),
        'desc': l10n.getString('feature_certification_desc'),
      },
      {
        'icon': Icons.business,
        'title': l10n.getString('feature_enterprise'),
        'desc': l10n.getString('feature_enterprise_desc'),
      },
      {
        'icon': Icons.analytics,
        'title': l10n.getString('feature_analytics'),
        'desc': l10n.getString('feature_analytics_desc'),
      },
      {
        'icon': Icons.security,
        'title': l10n.getString('feature_security'),
        'desc': l10n.getString('feature_security_desc'),
      },
      {
        'icon': Icons.language,
        'title': l10n.getString('feature_internationalization'),
        'desc': l10n.getString('feature_internationalization_desc'),
      },
      {
        'icon': Icons.mobile_friendly,
        'title': l10n.getString('feature_responsive'),
        'desc': l10n.getString('feature_responsive_desc'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
        crossAxisSpacing: isDesktop ? 24 : 16,
        mainAxisSpacing: isDesktop ? 24 : 16,
        childAspectRatio: isDesktop ? 1.2 : (isTablet ? 1.1 : 1.3),
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                feature['icon'] as IconData,
                color: const Color(0xFF6366F1),
                size: isDesktop ? 32 : 28,
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Text(
                feature['title'] as String,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              Text(
                feature['desc'] as String,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyFeaturesSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('key_features_title'),
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        ...List.generate(
          6,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: isDesktop ? 20 : 16),
            child: _buildFeatureItem(
              context,
              l10n,
              'key_feature_${index + 1}',
              Icons.check_circle,
              isDesktop,
              isTablet,
              isMobile,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    AppLocalizations l10n,
    String key,
    IconData icon,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: isDesktop ? 24 : 20),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Text(
              l10n.getString(key),
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitiveAdvantagesSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('competitive_advantages_title'),
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D1B69), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ...List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: isDesktop ? 20 : 18,
                      ),
                      SizedBox(width: isDesktop ? 12 : 10),
                      Expanded(
                        child: Text(
                          l10n.getString('competitive_advantage_${index + 1}'),
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProsAndConsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('pros_cons_title'),
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildProsConsColumn(
                  context,
                  l10n,
                  'pros',
                  Icons.thumb_up,
                  const Color(0xFF10B981),
                  isDesktop,
                  isTablet,
                  isMobile,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _buildProsConsColumn(
                  context,
                  l10n,
                  'cons',
                  Icons.thumb_down,
                  const Color(0xFFEF4444),
                  isDesktop,
                  isTablet,
                  isMobile,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildProsConsColumn(
                context,
                l10n,
                'pros',
                Icons.thumb_up,
                const Color(0xFF10B981),
                isDesktop,
                isTablet,
                isMobile,
              ),
              SizedBox(height: 24),
              _buildProsConsColumn(
                context,
                l10n,
                'cons',
                Icons.thumb_down,
                const Color(0xFFEF4444),
                isDesktop,
                isTablet,
                isMobile,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProsConsColumn(
    BuildContext context,
    AppLocalizations l10n,
    String type,
    IconData icon,
    Color color,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isDesktop ? 24 : 20),
              SizedBox(width: isDesktop ? 12 : 8),
              Text(
                l10n.getString('${type}_title'),
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 12 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    type == 'pros' ? Icons.check : Icons.close,
                    color: color,
                    size: isDesktop ? 16 : 14,
                  ),
                  SizedBox(width: isDesktop ? 12 : 8),
                  Expanded(
                    child: Text(
                      l10n.getString('${type}_${index + 1}'),
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 13,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
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

  Widget _buildPlatformBenefitsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('platform_benefits_title'),
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              ...List.generate(
                6,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: isDesktop ? 20 : 16),
                  child: Row(
                    children: [
                      Container(
                        width: isDesktop ? 40 : 32,
                        height: isDesktop ? 40 : 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.rocket_launch,
                          color: const Color(0xFF6366F1),
                          size: isDesktop ? 20 : 16,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 16 : 12),
                      Expanded(
                        child: Text(
                          l10n.getString('platform_benefit_${index + 1}'),
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnologyStackSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('technology_stack_title'),
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            l10n.getString('technology_stack_description'),
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialProofSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1B69), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.getString('trusted_by_companies'),
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: isDesktop ? 24 : 20,
                ),
                SizedBox(width: 8),
                Text(
                  l10n.getString('average_rating'),
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  l10n.getString('based_on_reviews'),
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo(
    BuildContext context,
    String company,
    bool isDesktop,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: isDesktop ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        company,
        style: TextStyle(
          color: Colors.white,
          fontSize: isDesktop ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildROICalculatorSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate,
                color: const Color(0xFF10B981),
                size: isDesktop ? 32 : 28,
              ),
              SizedBox(width: isDesktop ? 16 : 12),
              Text(
                l10n.getString('roi_calculator_title'),
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          Text(
            l10n.getString('roi_calculator_subtitle'),
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildROICard(
                    context,
                    l10n.getString('roi_savings_title'),
                    l10n.getString('roi_savings_amount'),
                    l10n.getString('roi_savings_desc'),
                    const Color(0xFF10B981),
                    isDesktop,
                    isTablet,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildROICard(
                    context,
                    l10n.getString('roi_time_title'),
                    l10n.getString('roi_time_amount'),
                    l10n.getString('roi_time_desc'),
                    const Color(0xFF3B82F6),
                    isDesktop,
                    isTablet,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildROICard(
                    context,
                    l10n.getString('roi_efficiency_title'),
                    l10n.getString('roi_efficiency_amount'),
                    l10n.getString('roi_efficiency_desc'),
                    const Color(0xFF8B5CF6),
                    isDesktop,
                    isTablet,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildROICard(
                  context,
                  l10n.getString('roi_savings_title'),
                  l10n.getString('roi_savings_amount'),
                  l10n.getString('roi_savings_desc'),
                  const Color(0xFF10B981),
                  isDesktop,
                  isTablet,
                ),
                SizedBox(height: 16),
                _buildROICard(
                  context,
                  l10n.getString('roi_time_title'),
                  l10n.getString('roi_time_amount'),
                  l10n.getString('roi_time_desc'),
                  const Color(0xFF3B82F6),
                  isDesktop,
                  isTablet,
                ),
                SizedBox(height: 16),
                _buildROICard(
                  context,
                  l10n.getString('roi_efficiency_title'),
                  l10n.getString('roi_efficiency_amount'),
                  l10n.getString('roi_efficiency_desc'),
                  const Color(0xFF8B5CF6),
                  isDesktop,
                  isTablet,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildROICard(
    BuildContext context,
    String title,
    String amount,
    String description,
    Color color,
    bool isDesktop,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: isDesktop ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 6),
          Text(
            description,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('testimonials_title'),
          style: TextStyle(
            fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildTestimonialCard(
                  context,
                  l10n.getString('testimonial_1_text'),
                  l10n.getString('testimonial_1_author'),
                  l10n.getString('testimonial_1_position'),
                  l10n.getString('testimonial_1_company'),
                  isDesktop,
                  isTablet,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildTestimonialCard(
                  context,
                  l10n.getString('testimonial_2_text'),
                  l10n.getString('testimonial_2_author'),
                  l10n.getString('testimonial_2_position'),
                  l10n.getString('testimonial_2_company'),
                  isDesktop,
                  isTablet,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: _buildTestimonialCard(
                  context,
                  l10n.getString('testimonial_3_text'),
                  l10n.getString('testimonial_3_author'),
                  l10n.getString('testimonial_3_position'),
                  l10n.getString('testimonial_3_company'),
                  isDesktop,
                  isTablet,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildTestimonialCard(
                context,
                l10n.getString('testimonial_1_text'),
                l10n.getString('testimonial_1_author'),
                l10n.getString('testimonial_1_position'),
                l10n.getString('testimonial_1_company'),
                isDesktop,
                isTablet,
              ),
              SizedBox(height: 20),
              _buildTestimonialCard(
                context,
                l10n.getString('testimonial_2_text'),
                l10n.getString('testimonial_2_author'),
                l10n.getString('testimonial_2_position'),
                l10n.getString('testimonial_2_company'),
                isDesktop,
                isTablet,
              ),
              SizedBox(height: 20),
              _buildTestimonialCard(
                context,
                l10n.getString('testimonial_3_text'),
                l10n.getString('testimonial_3_author'),
                l10n.getString('testimonial_3_position'),
                l10n.getString('testimonial_3_company'),
                isDesktop,
                isTablet,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTestimonialCard(
    BuildContext context,
    String text,
    String author,
    String position,
    String company,
    bool isDesktop,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                color: Colors.yellow,
                size: isDesktop ? 20 : 16,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            text,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Row(
            children: [
              CircleAvatar(
                radius: isDesktop ? 20 : 16,
                backgroundColor: const Color(0xFF6366F1),
                child: Text(
                  author[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 12 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$position, $company',
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencySection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.timer, color: Colors.white, size: isDesktop ? 48 : 40),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            l10n.getString('urgency_title'),
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            l10n.getString('urgency_description'),
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          Container(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.yellow,
                  size: isDesktop ? 24 : 20,
                ),
                SizedBox(width: 8),
                Text(
                  l10n.getString('urgency_offer'),
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 48 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1B69), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.getString('features_cta_title'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            l10n.getString('features_cta_description'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: isDesktop ? 32 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 24,
                    vertical: isDesktop ? 16 : 12,
                  ),
                  textStyle: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.getString('get_started')),
              ),
              SizedBox(width: isDesktop ? 16 : 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/cv-list'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 24,
                    vertical: isDesktop ? 16 : 12,
                  ),
                  textStyle: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.getString('explore_public_cvs')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
