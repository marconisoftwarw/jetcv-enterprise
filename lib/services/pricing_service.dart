import '../models/pricing.dart';
import '../config/app_config.dart';

class PricingService {
  // Carica tutti i pricing disponibili
  Future<List<Pricing>> getAvailablePricing() async {
    try {
      // TODO: Implementare chiamata al database
      // Per ora restituisco dati mock
      return _getMockPricing();
    } catch (e) {
      print('Error getting available pricing: $e');
      return [];
    }
  }

  // Carica pricing per tipo
  Future<List<Pricing>> getPricingByType(PricingType type) async {
    try {
      final allPricing = await getAvailablePricing();
      return allPricing.where((p) => p.type == type).toList();
    } catch (e) {
      print('Error getting pricing by type: $e');
      return [];
    }
  }

  // Carica pricing attivo
  Future<List<Pricing>> getActivePricing() async {
    try {
      final allPricing = await getAvailablePricing();
      return allPricing.where((p) => p.isAvailable).toList();
    } catch (e) {
      print('Error getting active pricing: $e');
      return [];
    }
  }

  // Carica pricing per legal entity
  Future<List<Pricing>> getPricingForLegalEntity(String legalEntityId) async {
    try {
      // TODO: Implementare logica per pricing specifici per legal entity
      final allPricing = await getAvailablePricing();
      return allPricing.where((p) => p.isAvailable).toList();
    } catch (e) {
      print('Error getting pricing for legal entity: $e');
      return [];
    }
  }

  // Crea un nuovo pricing
  Future<bool> createPricing(Pricing pricing) async {
    try {
      // TODO: Implementare chiamata al database
      print('Creating pricing: ${pricing.name}');
      return true;
    } catch (e) {
      print('Error creating pricing: $e');
      return false;
    }
  }

  // Aggiorna un pricing esistente
  Future<bool> updatePricing(Pricing pricing) async {
    try {
      // TODO: Implementare chiamata al database
      print('Updating pricing: ${pricing.name}');
      return true;
    } catch (e) {
      print('Error updating pricing: $e');
      return false;
    }
  }

  // Elimina un pricing
  Future<bool> deletePricing(String idPricing) async {
    try {
      // TODO: Implementare chiamata al database
      print('Deleting pricing: $idPricing');
      return true;
    } catch (e) {
      print('Error deleting pricing: $e');
      return false;
    }
  }

  // Verifica se un pricing è disponibile per una legal entity
  Future<bool> isPricingAvailableForLegalEntity(
    String idPricing,
    String legalEntityId,
  ) async {
    try {
      final pricing = await getPricingById(idPricing);
      if (pricing == null) return false;

      return pricing.isAvailable;
    } catch (e) {
      print('Error checking pricing availability: $e');
      return false;
    }
  }

  // Carica pricing per ID
  Future<Pricing?> getPricingById(String idPricing) async {
    try {
      final allPricing = await getAvailablePricing();
      return allPricing.firstWhere((p) => p.idPricing == idPricing);
    } catch (e) {
      print('Error getting pricing by ID: $e');
      return null;
    }
  }

  // Dati mock per sviluppo
  List<Pricing> _getMockPricing() {
    return [
      Pricing(
        name: 'Basic License',
        description: 'Licenza base per piccole aziende',
        price: 99.99,
        type: PricingType.basic,
        validityDays: 365,
        features: [
          'Fino a 5 utenti',
          'Certificazioni base',
          'Supporto email',
          'Dashboard base',
        ],
      ),
      Pricing(
        name: 'Professional License',
        description: 'Licenza professionale per aziende medie',
        price: 299.99,
        type: PricingType.professional,
        validityDays: 365,
        features: [
          'Fino a 20 utenti',
          'Tutte le certificazioni',
          'Supporto telefonico',
          'Dashboard avanzata',
          'Report personalizzati',
        ],
      ),
      Pricing(
        name: 'Enterprise License',
        description: 'Licenza enterprise per grandi aziende',
        price: 799.99,
        type: PricingType.enterprise,
        validityDays: 365,
        features: [
          'Utenti illimitati',
          'Tutte le certificazioni',
          'Supporto dedicato',
          'Dashboard personalizzata',
          'Report avanzati',
          'API access',
          'Integrazione personalizzata',
        ],
      ),
      Pricing(
        name: 'Custom License',
        description: 'Licenza personalizzata su misura',
        price: 1499.99,
        type: PricingType.custom,
        validityDays: 365,
        features: [
          'Tutto incluso',
          'Personalizzazione completa',
          'Supporto 24/7',
          'Sviluppo su misura',
          'Integrazione enterprise',
        ],
      ),
    ];
  }

  // Metodo per generare link di acquisto
  String generatePurchaseLink(Pricing pricing) {
    // TODO: Implementare logica per generare link di acquisto
    return '${AppConfig.appUrl}/purchase/${pricing.idPricing}';
  }

  // Metodo per verificare stato acquisto
  Future<bool> checkPurchaseStatus(String purchaseId) async {
    try {
      // TODO: Implementare verifica stato acquisto
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      print('Error checking purchase status: $e');
      return false;
    }
  }
}
