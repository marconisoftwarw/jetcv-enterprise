import 'package:flutter/material.dart';
import '../../widgets/public_top_bar.dart';
import '../../l10n/app_localizations.dart';

class LegalEntityInfoScreen extends StatelessWidget {
  const LegalEntityInfoScreen({super.key});

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
          const PublicTopBar(showBackButton: true, title: 'Entità Legale'),

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
                    horizontal: isDesktop ? 120 : (isTablet ? 60 : 32),
                    vertical: isDesktop ? 40 : 30,
                  ),
                  child: Column(
                    children: [
                      // Hero Section
                      _buildHeroSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Services Section
                      _buildServicesSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // Benefits Section
                      _buildBenefitsSection(
                        context,
                        l10n,
                        isDesktop,
                        isTablet,
                        isMobile,
                      ),

                      SizedBox(height: isDesktop ? 60 : 40),

                      // How It Works Section
                      _buildHowItWorksSection(
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
      children: [
        // Icon
        Container(
          width: isDesktop ? 120 : (isTablet ? 100 : 80),
          height: isDesktop ? 120 : (isTablet ? 100 : 80),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Icon(
            Icons.business_rounded,
            size: isDesktop ? 60 : (isTablet ? 50 : 40),
            color: Colors.white,
          ),
        ),

        SizedBox(height: isDesktop ? 32 : 24),

        // Title
        Text(
          l10n.getString('legal_entity_title'),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: isDesktop ? 48 : (isTablet ? 36 : 28),
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 16 : 12),

        // Subtitle
        Text(
          l10n.getString('legal_entity_subtitle'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
            fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      children: [
        Text(
          l10n.getString('legal_entity_services_title'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 32 : 28,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        isDesktop
            ? Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      l10n,
                      'legal_entity_service_1',
                      Icons.people,
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      l10n,
                      'legal_entity_service_2',
                      Icons.assessment,
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      l10n,
                      'legal_entity_service_3',
                      Icons.analytics,
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildServiceCard(
                    context,
                    l10n,
                    'legal_entity_service_1',
                    Icons.people,
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildServiceCard(
                    context,
                    l10n,
                    'legal_entity_service_2',
                    Icons.assessment,
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildServiceCard(
                    context,
                    l10n,
                    'legal_entity_service_3',
                    Icons.analytics,
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    AppLocalizations l10n,
    String key,
    IconData icon,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isDesktop ? 80 : (isTablet ? 70 : 60),
            height: isDesktop ? 80 : (isTablet ? 70 : 60),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isDesktop ? 40 : (isTablet ? 35 : 30),
            ),
          ),

          SizedBox(height: isDesktop ? 24 : 20),

          Text(
            l10n.getString('${key}_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isDesktop ? 16 : 12),

          Text(
            l10n.getString('${key}_description'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      children: [
        Text(
          l10n.getString('legal_entity_benefits_title'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 32 : 28,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        ...List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: isDesktop ? 20 : 16),
            child: _buildBenefitItem(
              context,
              l10n,
              'legal_entity_benefit_${index + 1}',
              isDesktop,
              isTablet,
              isMobile,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    AppLocalizations l10n,
    String key,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 50 : (isTablet ? 45 : 40),
            height: isDesktop ? 50 : (isTablet ? 45 : 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.white,
              size: isDesktop ? 24 : (isTablet ? 22 : 20),
            ),
          ),

          SizedBox(width: isDesktop ? 20 : 16),

          Expanded(
            child: Text(
              l10n.getString(key),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      children: [
        Text(
          l10n.getString('legal_entity_how_it_works_title'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: isDesktop ? 32 : 28,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isDesktop ? 48 : 32),

        isDesktop
            ? Row(
                children: [
                  Expanded(
                    child: _buildStepCard(
                      context,
                      l10n,
                      'legal_entity_step_1',
                      '1',
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStepCard(
                      context,
                      l10n,
                      'legal_entity_step_2',
                      '2',
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStepCard(
                      context,
                      l10n,
                      'legal_entity_step_3',
                      '3',
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildStepCard(
                    context,
                    l10n,
                    'legal_entity_step_1',
                    '1',
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildStepCard(
                    context,
                    l10n,
                    'legal_entity_step_2',
                    '2',
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                  const SizedBox(height: 24),
                  _buildStepCard(
                    context,
                    l10n,
                    'legal_entity_step_3',
                    '3',
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    AppLocalizations l10n,
    String key,
    String stepNumber,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isDesktop ? 60 : (isTablet ? 50 : 45),
            height: isDesktop ? 60 : (isTablet ? 50 : 45),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 24 : 20),

          Text(
            l10n.getString('${key}_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isDesktop ? 16 : 12),

          Text(
            l10n.getString('${key}_description'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
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
      padding: EdgeInsets.all(isDesktop ? 48 : (isTablet ? 40 : 32)),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.getString('legal_entity_cta_title'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isDesktop ? 32 : 28,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isDesktop ? 24 : 20),

          Text(
            l10n.getString('legal_entity_cta_description'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isDesktop ? 32 : 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/legal-entity/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : (isTablet ? 28 : 24),
                    vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  l10n.getString('become_legal_entity'),
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
