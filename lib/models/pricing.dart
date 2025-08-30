import 'package:uuid/uuid.dart';

enum PricingType { basic, professional, enterprise, custom }

enum PricingStatus { active, inactive, deprecated }

class Pricing {
  final String idPricing;
  final String name;
  final String description;
  final double price;
  final String currency;
  final PricingType type;
  final PricingStatus status;
  final int validityDays;
  final List<String> features;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? validFrom;
  final DateTime? validTo;

  Pricing({
    String? idPricing,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'EUR',
    required this.type,
    this.status = PricingStatus.active,
    required this.validityDays,
    required this.features,
    DateTime? createdAt,
    this.updatedAt,
    this.validFrom,
    this.validTo,
  }) : idPricing = idPricing ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      idPricing: json['id_pricing'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] ?? 'EUR',
      type: _parsePricingType(json['type']),
      status: _parsePricingStatus(json['status']),
      validityDays: json['validity_days'] ?? 365,
      features: List<String>.from(json['features'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validTo: json['valid_to'] != null
          ? DateTime.parse(json['valid_to'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pricing': idPricing,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type.name,
      'status': status.name,
      'validity_days': validityDays,
      'features': features,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'valid_from': validFrom?.toIso8601String(),
      'valid_to': validTo?.toIso8601String(),
    };
  }

  Pricing copyWith({
    String? idPricing,
    String? name,
    String? description,
    double? price,
    String? currency,
    PricingType? type,
    PricingStatus? status,
    int? validityDays,
    List<String>? features,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? validFrom,
    DateTime? validTo,
  }) {
    return Pricing(
      idPricing: idPricing ?? this.idPricing,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      validityDays: validityDays ?? this.validityDays,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
    );
  }

  static PricingType _parsePricingType(String? type) {
    switch (type?.toLowerCase()) {
      case 'basic':
        return PricingType.basic;
      case 'professional':
        return PricingType.professional;
      case 'enterprise':
        return PricingType.enterprise;
      case 'custom':
        return PricingType.custom;
      default:
        return PricingType.basic;
    }
  }

  static PricingStatus _parsePricingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return PricingStatus.active;
      case 'inactive':
        return PricingStatus.inactive;
      case 'deprecated':
        return PricingStatus.deprecated;
      default:
        return PricingStatus.active;
    }
  }

  // Getters utili
  bool get isActive => status == PricingStatus.active;
  bool get isExpired => validTo != null && DateTime.now().isAfter(validTo!);
  bool get isAvailable => isActive && !isExpired;
  String get formattedPrice => '€${price.toStringAsFixed(2)}';
  String get typeDisplayName {
    switch (type) {
      case PricingType.basic:
        return 'Base';
      case PricingType.professional:
        return 'Professionale';
      case PricingType.enterprise:
        return 'Enterprise';
      case PricingType.custom:
        return 'Personalizzato';
    }
  }
}
