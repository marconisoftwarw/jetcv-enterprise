import 'package:uuid/uuid.dart';

enum LegalEntityStatus { pending, approved, rejected }

class LegalEntity {
  final String idLegalEntity;
  final String idLegalEntityHash;
  final String? legalName;
  final String? identifierCode;
  final String? operationalAddress;
  final String? operationalCity;
  final String? operationalPostalCode;
  final String? operationalState;
  final String? operationalCountry;
  final String? headquarterAddress;
  final String? headquarterCity;
  final String? headquarterPostalCode;
  final String? headquarterState;
  final String? headquarterCountry;
  final String? legalRapresentative;
  final String? email;
  final String? phone;
  final String? pec;
  final String? website;
  final LegalEntityStatus status;
  final String? logoPicture;
  final String? companyPicture;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? invitationToken;

  LegalEntity({
    required this.idLegalEntity,
    required this.idLegalEntityHash,
    this.legalName,
    this.identifierCode,
    this.operationalAddress,
    this.operationalCity,
    this.operationalPostalCode,
    this.operationalState,
    this.operationalCountry,
    this.headquarterAddress,
    this.headquarterCity,
    this.headquarterPostalCode,
    this.headquarterState,
    this.headquarterCountry,
    this.legalRapresentative,
    this.email,
    this.phone,
    this.pec,
    this.website,
    this.status = LegalEntityStatus.pending,
    this.logoPicture,
    this.companyPicture,
    DateTime? createdAt,
    this.updatedAt,
    this.invitationToken,
  }) : createdAt = createdAt ?? DateTime.now();

  factory LegalEntity.fromJson(Map<String, dynamic> json) {
    return LegalEntity(
      idLegalEntity: json['id_legal_entity'] ?? const Uuid().v4(),
      idLegalEntityHash: json['id_legal_entity_hash'] ?? '',
      legalName: json['legal_name'],
      identifierCode: json['identifier_code'],
      operationalAddress: json['operational_address'],
      operationalCity: json['operational_city'],
      operationalPostalCode: json['operational_postal_code'],
      operationalState: json['operational_state'],
      operationalCountry: json['operational_country'],
      headquarterAddress: json['headquarter_address'],
      headquarterCity: json['headquarter_city'],
      headquarterPostalCode: json['headquarter_postal_code'],
      headquarterState: json['headquarter_state'],
      headquarterCountry: json['headquarter_country'],
      legalRapresentative: json['legal_rapresentative'],
      email: json['email'],
      phone: json['phone'],
      pec: json['pec'],
      website: json['website'],
      status: LegalEntityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => LegalEntityStatus.pending,
      ),
      logoPicture: json['logo_picture'],
      companyPicture: json['company_picture'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      invitationToken: json['invitation_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_legal_entity': idLegalEntity,
      'id_legal_entity_hash': idLegalEntityHash,
      'legal_name': legalName,
      'identifier_code': identifierCode,
      'operational_address': operationalAddress,
      'operational_city': operationalCity,
      'operational_postal_code': operationalPostalCode,
      'operational_state': operationalState,
      'operational_country': operationalCountry,
      'headquarter_address': headquarterAddress,
      'headquarter_city': headquarterCity,
      'headquarter_postal_code': headquarterPostalCode,
      'headquarter_state': headquarterState,
      'headquarter_country': headquarterCountry,
      'legal_rapresentative': legalRapresentative,
      'email': email,
      'phone': phone,
      'pec': pec,
      'website': website,
      'status': status.toString().split('.').last,
      'logo_picture': logoPicture,
      'company_picture': companyPicture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'invitation_token': invitationToken,
    };
  }

  LegalEntity copyWith({
    String? idLegalEntity,
    String? idLegalEntityHash,
    String? legalName,
    String? identifierCode,
    String? operationalAddress,
    String? operationalCity,
    String? operationalPostalCode,
    String? operationalState,
    String? operationalCountry,
    String? headquarterAddress,
    String? headquarterCity,
    String? headquarterPostalCode,
    String? headquarterState,
    String? headquarterCountry,
    String? legalRapresentative,
    String? email,
    String? phone,
    String? pec,
    String? website,
    LegalEntityStatus? status,
    String? logoPicture,
    String? companyPicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? invitationToken,
  }) {
    return LegalEntity(
      idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      idLegalEntityHash: idLegalEntityHash ?? this.idLegalEntityHash,
      legalName: legalName ?? this.legalName,
      identifierCode: identifierCode ?? this.identifierCode,
      operationalAddress: operationalAddress ?? this.operationalAddress,
      operationalCity: operationalCity ?? this.operationalCity,
      operationalPostalCode:
          operationalPostalCode ?? this.operationalPostalCode,
      operationalState: operationalState ?? this.operationalState,
      operationalCountry: operationalCountry ?? this.operationalCountry,
      headquarterAddress: headquarterAddress ?? this.headquarterAddress,
      headquarterCity: headquarterCity ?? this.headquarterCity,
      headquarterPostalCode:
          headquarterPostalCode ?? this.headquarterPostalCode,
      headquarterState: headquarterState ?? this.headquarterState,
      headquarterCountry: headquarterCountry ?? this.headquarterCountry,
      legalRapresentative: legalRapresentative ?? this.legalRapresentative,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      pec: pec ?? this.pec,
      website: website ?? this.website,
      status: status ?? this.status,
      logoPicture: logoPicture ?? this.logoPicture,
      companyPicture: companyPicture ?? this.companyPicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invitationToken: invitationToken ?? this.invitationToken,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case LegalEntityStatus.pending:
        return 'In Attesa';
      case LegalEntityStatus.approved:
        return 'Approvata';
      case LegalEntityStatus.rejected:
        return 'Rifiutata';
    }
  }

  bool get isPending => status == LegalEntityStatus.pending;
  bool get isApproved => status == LegalEntityStatus.approved;
  bool get isRejected => status == LegalEntityStatus.rejected;

  String get displayAddress {
    final parts = <String>[];
    if (operationalAddress != null && operationalAddress!.isNotEmpty)
      parts.add(operationalAddress!);
    if (operationalCity != null && operationalCity!.isNotEmpty)
      parts.add(operationalCity!);
    if (operationalState != null && operationalState!.isNotEmpty)
      parts.add(operationalState!);
    if (operationalPostalCode != null && operationalPostalCode!.isNotEmpty)
      parts.add(operationalPostalCode!);
    if (operationalCountry != null && operationalCountry!.isNotEmpty)
      parts.add(operationalCountry!);

    return parts.isEmpty
        ? 'Indirizzo operativo non specificato'
        : parts.join(', ');
  }

  String get displayHeadquarters {
    final parts = <String>[];
    if (headquarterAddress != null && headquarterAddress!.isNotEmpty)
      parts.add(headquarterAddress!);
    if (headquarterCity != null && headquarterCity!.isNotEmpty)
      parts.add(headquarterCity!);
    if (headquarterState != null && headquarterState!.isNotEmpty)
      parts.add(headquarterState!);
    if (headquarterPostalCode != null && headquarterPostalCode!.isNotEmpty)
      parts.add(headquarterPostalCode!);
    if (headquarterCountry != null && headquarterCountry!.isNotEmpty)
      parts.add(headquarterCountry!);

    return parts.isEmpty ? 'Sede legale non specificata' : parts.join(', ');
  }
}
