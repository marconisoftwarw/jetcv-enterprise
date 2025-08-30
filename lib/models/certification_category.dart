import 'package:uuid/uuid.dart';

enum CertificationCategoryType {
  iso9001,
  iso14001,
  iso45001,
  iso27001,
  iso22000,
  iso13485,
  iso20000,
  iso50001,
  iso22301,
  iso31000,
  iso55001,
  iso17025,
  iso17020,
  iso17021,
  iso17065,
}

enum CertificationCategoryScope { global, national, regional, local, company }

class CertificationCategory {
  final String idCertificationCategory;
  final String name;
  final CertificationCategoryType type;
  final int? order;
  final String? idLegalEntity;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CertificationCategoryScope scope;

  CertificationCategory({
    String? idCertificationCategory,
    required this.name,
    required this.type,
    this.order,
    this.idLegalEntity,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.scope = CertificationCategoryScope.global,
  }) : idCertificationCategory = idCertificationCategory ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt;

  factory CertificationCategory.fromJson(Map<String, dynamic> json) {
    return CertificationCategory(
      idCertificationCategory: json['id_certification_category'],
      name: json['name'],
      type: _parseType(json['type']),
      order: json['order'],
      idLegalEntity: json['id_legal_entity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      scope: _parseScope(json['scope']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification_category': idCertificationCategory,
      'name': name,
      'type': type.name,
      'order': order,
      'id_legal_entity': idLegalEntity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'scope': scope.name,
    };
  }

  CertificationCategory copyWith({
    String? idCertificationCategory,
    String? name,
    CertificationCategoryType? type,
    int? order,
    String? idLegalEntity,
    DateTime? createdAt,
    DateTime? updatedAt,
    CertificationCategoryScope? scope,
  }) {
    return CertificationCategory(
      idCertificationCategory:
          idCertificationCategory ?? this.idCertificationCategory,
      name: name ?? this.name,
      type: type ?? this.type,
      order: order ?? this.order,
      idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scope: scope ?? this.scope,
    );
  }

  static CertificationCategoryType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'iso9001':
        return CertificationCategoryType.iso9001;
      case 'iso14001':
        return CertificationCategoryType.iso14001;
      case 'iso45001':
        return CertificationCategoryType.iso45001;
      case 'iso27001':
        return CertificationCategoryType.iso27001;
      case 'iso22000':
        return CertificationCategoryType.iso22000;
      case 'iso13485':
        return CertificationCategoryType.iso13485;
      case 'iso20000':
        return CertificationCategoryType.iso20000;
      case 'iso50001':
        return CertificationCategoryType.iso50001;
      case 'iso22301':
        return CertificationCategoryType.iso22301;
      case 'iso31000':
        return CertificationCategoryType.iso31000;
      case 'iso55001':
        return CertificationCategoryType.iso55001;
      case 'iso17025':
        return CertificationCategoryType.iso17025;
      case 'iso17020':
        return CertificationCategoryType.iso17020;
      case 'iso17021':
        return CertificationCategoryType.iso17021;
      case 'iso17065':
        return CertificationCategoryType.iso17065;
      default:
        return CertificationCategoryType.iso9001;
    }
  }

  static CertificationCategoryScope _parseScope(String? scope) {
    switch (scope?.toLowerCase()) {
      case 'global':
        return CertificationCategoryScope.global;
      case 'national':
        return CertificationCategoryScope.national;
      case 'regional':
        return CertificationCategoryScope.regional;
      case 'local':
        return CertificationCategoryScope.local;
      case 'company':
        return CertificationCategoryScope.company;
      default:
        return CertificationCategoryScope.global;
    }
  }

  // Getters utili
  String get typeDisplayName {
    switch (type) {
      case CertificationCategoryType.iso9001:
        return 'ISO 9001 - Gestione Qualità';
      case CertificationCategoryType.iso14001:
        return 'ISO 14001 - Gestione Ambientale';
      case CertificationCategoryType.iso45001:
        return 'ISO 45001 - Salute e Sicurezza';
      case CertificationCategoryType.iso27001:
        return 'ISO 27001 - Sicurezza Informatica';
      case CertificationCategoryType.iso22000:
        return 'ISO 22000 - Sicurezza Alimentare';
      case CertificationCategoryType.iso13485:
        return 'ISO 13485 - Dispositivi Medici';
      case CertificationCategoryType.iso20000:
        return 'ISO 20000 - Gestione Servizi IT';
      case CertificationCategoryType.iso50001:
        return 'ISO 50001 - Gestione Energia';
      case CertificationCategoryType.iso22301:
        return 'ISO 22301 - Continuità Operativa';
      case CertificationCategoryType.iso31000:
        return 'ISO 31000 - Gestione Rischi';
      case CertificationCategoryType.iso55001:
        return 'ISO 55001 - Gestione Asset';
      case CertificationCategoryType.iso17025:
        return 'ISO 17025 - Competenza Laboratori';
      case CertificationCategoryType.iso17020:
        return 'ISO 17020 - Ispettori';
      case CertificationCategoryType.iso17021:
        return 'ISO 17021 - Organismi Certificazione';
      case CertificationCategoryType.iso17065:
        return 'ISO 17065 - Organismi Validazione';
    }
  }

  String get scopeDisplayName {
    switch (scope) {
      case CertificationCategoryScope.global:
        return 'Globale';
      case CertificationCategoryScope.national:
        return 'Nazionale';
      case CertificationCategoryScope.regional:
        return 'Regionale';
      case CertificationCategoryScope.local:
        return 'Locale';
      case CertificationCategoryScope.company:
        return 'Aziendale';
    }
  }

  bool get isCompanySpecific => scope == CertificationCategoryScope.company;
}
