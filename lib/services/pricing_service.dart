import '../models/pricing.dart';
import '../config/app_config.dart';

class PricingService {
  // Per ora restituisce pricing fittizi
  // In futuro si può integrare con un database reale
  Future<List<Pricing>> getPricings() async {
    // Simula un delay di rete
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Pricing(
        name: 'Starter',
        description: 'Piano base per piccole aziende',
        price: 99.00,
        type: PricingType.basic,
        validityDays: 365,
        features: [
          'Registrazione entità legale',
          'Gestione profilo aziendale',
          'Supporto email',
          'Dashboard base',
          'Fino a 10 certificazioni',
        ],
      ),
      Pricing(
        name: 'Professional',
        description: 'Piano professionale per aziende medie',
        price: 199.00,
        type: PricingType.professional,
        validityDays: 365,
        features: [
          'Tutto del piano Starter',
          'Gestione certificazioni avanzata',
          'Supporto telefonico',
          'Dashboard avanzata',
          'Report personalizzati',
          'Fino a 50 certificazioni',
          'Integrazione API',
        ],
      ),
      Pricing(
        name: 'Enterprise',
        description: 'Piano enterprise per grandi aziende',
        price: 399.00,
        type: PricingType.enterprise,
        validityDays: 365,
        features: [
          'Tutto del piano Professional',
          'API personalizzate',
          'Supporto dedicato',
          'Integrazione personalizzata',
          'Training team',
          'SLA garantito',
          'Certificazioni illimitate',
          'White-label disponibile',
        ],
      ),
    ];
  }

  // Ottiene un pricing specifico per ID
  Future<Pricing?> getPricingById(String id) async {
    final pricings = await getPricings();
    try {
      return pricings.firstWhere((pricing) => pricing.idPricing == id);
    } catch (e) {
      return null;
    }
  }

  // Ottiene i pricing attivi
  Future<List<Pricing>> getActivePricings() async {
    final pricings = await getPricings();
    return pricings.where((pricing) => pricing.isAvailable).toList();
  }

  // Ottiene i pricing per tipo
  Future<List<Pricing>> getPricingsByType(PricingType type) async {
    final pricings = await getPricings();
    return pricings.where((pricing) => pricing.type == type).toList();
  }

  // Valida un pricing
  bool validatePricing(Pricing pricing) {
    return pricing.isAvailable && !pricing.isExpired;
  }

  // Calcola il prezzo con sconti (per future implementazioni)
  double calculateDiscountedPrice(
    Pricing pricing, {
    double discountPercentage = 0,
  }) {
    if (discountPercentage <= 0) return pricing.price;
    return pricing.price * (1 - discountPercentage / 100);
  }
}
