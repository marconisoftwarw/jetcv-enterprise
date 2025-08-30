import 'package:uuid/uuid.dart';

enum CertificationInformationType {
  text,
  number,
  date,
  boolean,
  select,
  multiselect,
  file,
  image,
  location,
  timestamp,
}

enum CertificationInformationScope {
  global,
  national,
  regional,
  local,
  company,
}

class CertificationInformation {
  final String idCertificationInformation;
  final String name;
  final int? order;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String label;
  final CertificationInformationType type;
  final String? idLegalEntity;
  final CertificationInformationScope scope;

  CertificationInformation({
    String? idCertificationInformation,
    required this.name,
    this.order,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.label,
    required this.type,
    this.idLegalEntity,
    this.scope = CertificationInformationScope.global,
  }) : idCertificationInformation =
           idCertificationInformation ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt;

  factory CertificationInformation.fromJson(Map<String, dynamic> json) {
    return CertificationInformation(
      idCertificationInformation: json['id_certification_information'],
      name: json['name'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      label: json['label'],
      type: _parseType(json['type']),
      idLegalEntity: json['id_legal_entity'],
      scope: _parseScope(json['scope']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification_information': idCertificationInformation,
      'name': name,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'label': label,
      'type': type.name,
      'id_legal_entity': idLegalEntity,
      'scope': scope.name,
    };
  }

  CertificationInformation copyWith({
    String? idCertificationInformation,
    String? name,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? label,
    CertificationInformationType? type,
    String? idLegalEntity,
    CertificationInformationScope? scope,
  }) {
    return CertificationInformation(
      idCertificationInformation:
          idCertificationInformation ?? this.idCertificationInformation,
      name: name ?? this.name,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      label: label ?? this.label,
      type: type ?? this.type,
      idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      scope: scope ?? this.scope,
    );
  }

  static CertificationInformationType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'text':
        return CertificationInformationType.text;
      case 'number':
        return CertificationInformationType.number;
      case 'date':
        return CertificationInformationType.date;
      case 'boolean':
        return CertificationInformationType.boolean;
      case 'select':
        return CertificationInformationType.select;
      case 'multiselect':
        return CertificationInformationType.multiselect;
      case 'file':
        return CertificationInformationType.file;
      case 'image':
        return CertificationInformationType.image;
      case 'location':
        return CertificationInformationType.location;
      case 'timestamp':
        return CertificationInformationType.timestamp;
      default:
        return CertificationInformationType.text;
    }
  }

  static CertificationInformationScope _parseScope(String? scope) {
    switch (scope?.toLowerCase()) {
      case 'global':
        return CertificationInformationScope.global;
      case 'national':
        return CertificationInformationScope.national;
      case 'regional':
        return CertificationInformationScope.regional;
      case 'local':
        return CertificationInformationScope.local;
      case 'company':
        return CertificationInformationScope.company;
      default:
        return CertificationInformationScope.global;
    }
  }

  // Getters utili
  String get typeDisplayName {
    switch (type) {
      case CertificationInformationType.text:
        return 'Testo';
      case CertificationInformationType.number:
        return 'Numero';
      case CertificationInformationType.date:
        return 'Data';
      case CertificationInformationType.boolean:
        return 'Sì/No';
      case CertificationInformationType.select:
        return 'Selezione Singola';
      case CertificationInformationType.multiselect:
        return 'Selezione Multipla';
      case CertificationInformationType.file:
        return 'File';
      case CertificationInformationType.image:
        return 'Immagine';
      case CertificationInformationType.location:
        return 'Posizione';
      case CertificationInformationType.timestamp:
        return 'Timestamp';
    }
  }

  String get scopeDisplayName {
    switch (scope) {
      case CertificationInformationScope.global:
        return 'Globale';
      case CertificationInformationScope.national:
        return 'Nazionale';
      case CertificationInformationScope.regional:
        return 'Regionale';
      case CertificationInformationScope.local:
        return 'Locale';
      case CertificationInformationScope.company:
        return 'Aziendale';
    }
  }

  bool get isCompanySpecific => scope == CertificationInformationScope.company;
  bool get isGlobal => scope == CertificationInformationScope.global;
  bool get hasOrder => order != null;
  bool get isRequired => name.isNotEmpty && label.isNotEmpty;
}
