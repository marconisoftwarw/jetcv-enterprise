import 'package:flutter/foundation.dart';
import '../models/pricing.dart';
import '../services/pricing_service.dart';

class PricingProvider extends ChangeNotifier {
  final PricingService _pricingService = PricingService();

  List<Pricing> _pricings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pricing> get pricings => _pricings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Carica i pricing disponibili
  Future<void> loadPricings() async {
    _setLoading(true);
    _clearError();

    try {
      final pricings = await _pricingService.getPricings();
      _pricings = pricings;
      print('✅ PricingProvider: Loaded ${pricings.length} pricing plans');
    } catch (e) {
      print('❌ PricingProvider: Error loading pricings: $e');
      _setError('Errore nel caricamento dei piani: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Ottiene un pricing specifico per ID
  Pricing? getPricingById(String id) {
    try {
      return _pricings.firstWhere((pricing) => pricing.idPricing == id);
    } catch (e) {
      return null;
    }
  }

  // Ottiene i pricing attivi
  List<Pricing> get activePricings {
    return _pricings.where((pricing) => pricing.isAvailable).toList();
  }

  // Ottiene i pricing per tipo
  List<Pricing> getPricingsByType(PricingType type) {
    return _pricings.where((pricing) => pricing.type == type).toList();
  }

  // Crea pricing temporanei fittizi per test
  void createMockPricings() {
    _pricings = [
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
        ],
      ),
    ];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
