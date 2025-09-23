import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pricing.dart';
import '../../providers/pricing_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/responsive_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../theme/app_theme.dart';

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
    return ResponsiveLayout(
      showMenu: false,
      hideAppBar: false, // Mostra l'AppBar per questa pagina
      title: 'Seleziona Licenza',
      child: Consumer<PricingProvider>(
        builder: (context, pricingProvider, child) {
          if (pricingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pricingProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Errore: ${pricingProvider.errorMessage}',
                    style: TextStyle(color: Colors.red),
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
              child: Text('Nessun piano disponibile al momento'),
            );
          }

          return SingleChildScrollView(
            padding: ResponsivePadding.screen(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Scegli il piano più adatto alla tua azienda',
                  textType: TextType.titleLarge,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(
                  height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12,
                ),
                ResponsiveText(
                  'Seleziona una licenza per continuare con la registrazione della tua entità legale',
                  textType: TextType.bodyLarge,
                  style: TextStyle(color: AppTheme.textGray),
                ),
                SizedBox(
                  height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32,
                ),
                ResponsiveBreakpoints.isMobile(context)
                    ? Column(
                        children: availablePricings
                            .map(
                              (pricing) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildPricingCard(pricing),
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
                                  child: _buildPricingCard(pricing),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                SizedBox(
                  height: ResponsiveBreakpoints.isMobile(context) ? 24 : 32,
                ),
                if (selectedPricing != null) ...[
                  _buildSelectedPricingSummary(),
                  SizedBox(
                    height: ResponsiveBreakpoints.isMobile(context) ? 16 : 24,
                  ),
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
    );
  }

  Widget _buildPricingCard(Pricing pricing) {
    final isSelected = selectedPricing?.idPricing == pricing.idPricing;

    return ResponsiveCard(
      margin: const EdgeInsets.only(bottom: 16),
      backgroundColor: isSelected
          ? AppTheme.primaryBlue.withValues(alpha: 0.1)
          : AppTheme.pureWhite,
      border: isSelected
          ? Border.all(color: AppTheme.primaryBlue, width: 2)
          : Border.all(color: AppTheme.borderGray, width: 1),
      child: InkWell(
        onTap: () => setState(() => selectedPricing = pricing),
        borderRadius: BorderRadius.circular(
          ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
        ),
        child: Container(
          padding: ResponsivePadding.card(context),
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
                        ResponsiveText(
                          pricing.name,
                          textType: TextType.titleLarge,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveBreakpoints.isMobile(context)
                              ? 4
                              : 6,
                        ),
                        ResponsiveText(
                          pricing.description,
                          textType: TextType.bodyMedium,
                          style: TextStyle(color: AppTheme.textGray),
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'per ${pricing.validityDays} giorni',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Caratteristiche:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...pricing.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(feature, style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isSelected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '✓ Selezionato',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPricingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Piano Selezionato:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedPricing!.name} - ${selectedPricing!.formattedPrice}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Validità: ${selectedPricing!.validityDays} giorni',
            style: TextStyle(fontSize: 14),
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
