import 'package:uuid/uuid.dart';

class LegalEntity {
  final String idLegalEntity;
  final String idLegalEntityHash;
  final String legalName;
  final String identifierCode;
  final String operationalAddress;
  final String headquartersAddress;
  final String legalRepresentative;
  final String email;
  final String phone;
  final String? pec;
  final String? website;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? statusUpdatedAt;
  final String? statusUpdatedByIdUser;
  final String requestingIdUser;
  final String status;
  final String? logoPictureUrl;
  final String? companyPictureUrl;
  final String? address;
  final String? city;
  final String? state;
  final String? postalcode;
  final String? countrycode;

  LegalEntity({
    required this.idLegalEntity,
    required this.idLegalEntityHash,
    required this.legalName,
    required this.identifierCode,
    required this.operationalAddress,
    required this.headquartersAddress,
    required this.legalRepresentative,
    required this.email,
    required this.phone,
    this.pec,
    this.website,
    required this.createdAt,
    this.updatedAt,
    this.statusUpdatedAt,
    this.statusUpdatedByIdUser,
    required this.requestingIdUser,
    required this.status,
    this.logoPictureUrl,
    this.companyPictureUrl,
    this.address,
    this.city,
    this.state,
    this.postalcode,
    this.countrycode,
  });

  factory LegalEntity.fromJson(Map<String, dynamic> json) {
    return LegalEntity(
      idLegalEntity: json['idLegalEntity'] ?? '',
      idLegalEntityHash: json['idLegalEntityHash'] ?? '',
      legalName: json['legalName'] ?? '',
      identifierCode: json['identifierCode'] ?? '',
      operationalAddress: json['operationalAddress'] ?? '',
      headquartersAddress: json['headquartersAddress'] ?? '',
      legalRepresentative: json['legalRepresentative'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      pec: json['pec'],
      website: json['website'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      statusUpdatedAt: json['statusUpdatedAt'] != null 
          ? DateTime.parse(json['statusUpdatedAt']) 
          : null,
      statusUpdatedByIdUser: json['statusUpdatedByIdUser'],
      requestingIdUser: json['requestingIdUser'] ?? '',
      status: json['status'] ?? 'pending',
      logoPictureUrl: json['logoPictureUrl'],
      companyPictureUrl: json['companyPictureUrl'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalcode: json['postalcode'],
      countrycode: json['countrycode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLegalEntity': idLegalEntity,
      'idLegalEntityHash': idLegalEntityHash,
      'legalName': legalName,
      'identifierCode': identifierCode,
      'operationalAddress': operationalAddress,
      'headquartersAddress': headquartersAddress,
      'legalRepresentative': legalRepresentative,
      'email': email,
      'phone': phone,
      'pec': pec,
      'website': website,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'statusUpdatedAt': statusUpdatedAt?.toIso8601String(),
      'statusUpdatedByIdUser': statusUpdatedByIdUser,
      'requestingIdUser': requestingIdUser,
      'status': status,
      'logoPictureUrl': logoPictureUrl,
      'companyPictureUrl': companyPictureUrl,
      'address': address,
      'city': city,
      'state': state,
      'postalcode': postalcode,
      'countrycode': countrycode,
    };
  }

  LegalEntity copyWith({
    String? idLegalEntity,
    String? idLegalEntityHash,
    String? legalName,
    String? identifierCode,
    String? operationalAddress,
    String? headquartersAddress,
    String? legalRepresentative,
    String? email,
    String? phone,
    String? pec,
    String? website,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? statusUpdatedAt,
    String? statusUpdatedByIdUser,
    String? requestingIdUser,
    String? status,
    String? logoPictureUrl,
    String? companyPictureUrl,
    String? address,
    String? city,
    String? state,
    String? postalcode,
    String? countrycode,
  }) {
    return LegalEntity(
      idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      idLegalEntityHash: idLegalEntityHash ?? this.idLegalEntityHash,
      legalName: legalName ?? this.legalName,
      identifierCode: identifierCode ?? this.identifierCode,
      operationalAddress: operationalAddress ?? this.operationalAddress,
      headquartersAddress: headquartersAddress ?? this.headquartersAddress,
      legalRepresentative: legalRepresentative ?? this.legalRepresentative,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      pec: pec ?? this.pec,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      statusUpdatedByIdUser: statusUpdatedByIdUser ?? this.statusUpdatedByIdUser,
      requestingIdUser: requestingIdUser ?? this.requestingIdUser,
      status: status ?? this.status,
      logoPictureUrl: logoPictureUrl ?? this.logoPictureUrl,
      companyPictureUrl: companyPictureUrl ?? this.companyPictureUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalcode: postalcode ?? this.postalcode,
      countrycode: countrycode ?? this.countrycode,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'approved';
  
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'In attesa';
      case 'approved':
        return 'Approvata';
      case 'rejected':
        return 'Rifiutata';
      default:
        return 'Sconosciuto';
    }
  }
}
