import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pricing.dart';
import '../../providers/pricing_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/responsive_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/public_top_bar.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class LegalEntityPricingScreen extends StatefulWidget {
  const LegalEntityPricingScreen({super.key});

  @override
  State<LegalEntityPricingScreen> createState() =>
      _LegalEntityPricingScreenState();
}

class _LegalEntityPricingScreenState extends State<LegalEntityPricingScreen> {
  Pricing? selectedPricing;

  @override
  void initState() {
    super.initState();
    // Carica i pricing disponibili
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PricingProvider>().loadPricings();
    });
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
          const PublicTopBar(showBackButton: true, title: 'Seleziona Licenza'),

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
                child: Consumer<PricingProvider>(
                  builder: (context, pricingProvider, child) {
                    if (pricingProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (pricingProvider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Errore: ${pricingProvider.errorMessage}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              onPressed: () => pricingProvider.loadPricings(),
                              text: 'Riprova',
                            ),
                          ],
                        ),
                      );
                    }

                    final availablePricings = pricingProvider.pricings
                        .where((pricing) => pricing.isAvailable)
                        .toList();

                    if (availablePricings.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nessun piano disponibile al momento',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 120 : (isTablet ? 60 : 32),
                        vertical: isDesktop ? 40 : 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Scegli il piano più adatto alla tua azienda',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: isDesktop ? 32 : 28,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isDesktop ? 16 : 12),
                                Text(
                                  'Seleziona una licenza per continuare con la registrazione della tua entità legale',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w400,
                                        fontSize: isDesktop
                                            ? 20
                                            : (isTablet ? 18 : 16),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isDesktop ? 48 : 32),

                          // Pricing Cards
                          isMobile
                              ? Column(
                                  children: availablePricings
                                      .map(
                                        (pricing) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: _buildPricingCard(
                                            pricing,
                                            isMobile,
                                            isTablet,
                                            isDesktop,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : Row(
                                  children: availablePricings
                                      .map(
                                        (pricing) => Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: _buildPricingCard(
                                              pricing,
                                              isMobile,
                                              isTablet,
                                              isDesktop,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                          SizedBox(height: isDesktop ? 32 : 24),

                          // Selected Pricing Summary
                          if (selectedPricing != null) ...[
                            _buildSelectedPricingSummary(
                              isMobile,
                              isTablet,
                              isDesktop,
                            ),
                            SizedBox(height: isDesktop ? 24 : 16),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                onPressed: () => _proceedToRegistration(),
                                text: 'Continua con la Registrazione',
                                backgroundColor: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    Pricing pricing,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final isSelected = selectedPricing?.idPricing == pricing.idPricing;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => selectedPricing = pricing),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.15),
                    ]
                  : [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pricing.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: isMobile ? 16 : 18,
                              ),
                        ),
                        SizedBox(height: isMobile ? 4 : 6),
                        Text(
                          pricing.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isMobile ? 12 : 13,
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
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      Text(
                        'per ${pricing.validityDays} giorni',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'Caratteristiche:',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              ...pricing.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: isMobile ? 14 : 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              if (isSelected)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 6 : 8,
                    horizontal: isMobile ? 12 : 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✓ Selezionato',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPricingSummary(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successGreen.withOpacity(0.2),
            AppTheme.successGreen.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: AppTheme.successGreen.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Piano Selezionato:',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            '${selectedPricing!.name} - ${selectedPricing!.formattedPrice}',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.successGreen,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            'Validità: ${selectedPricing!.validityDays} giorni',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToRegistration() {
    if (selectedPricing != null) {
      Navigator.pushNamed(
        context,
        '/legal-entity/register',
        arguments: {'pricing': selectedPricing},
      );
    }
  }
}
