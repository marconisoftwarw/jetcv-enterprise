import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pricing.dart';
import '../../providers/pricing_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Licenza'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<PricingProvider>(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scegli il piano più adatto alla tua azienda',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seleziona una licenza per continuare con la registrazione della tua entità legale',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ...availablePricings.map(
                  (pricing) => _buildPricingCard(pricing),
                ),
                const SizedBox(height: 32),
                if (selectedPricing != null) ...[
                  _buildSelectedPricingSummary(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () => _proceedToRegistration(),
                      text: 'Continua con la Registrazione',
                      backgroundColor: Colors.green,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: InkWell(
        onTap: () => setState(() => selectedPricing = pricing),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pricing.description,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
