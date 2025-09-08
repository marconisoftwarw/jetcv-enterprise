import 'package:uuid/uuid.dart';

// Enums based on DB schema
enum CertificationStatus { draft, sent, closed }

enum CertificationUserStatus { draft, accepted, rejected }

enum CertificationCategoryType { course, workshop, seminar, exam, other }

enum CertificationInformationType { text, number, date, boolean, file }

enum CertificationInformationScope { general, user }

enum AcquisitionType { manual, automatic, imported }

enum FileType { image, video, document, audio }

enum Gender { male, female, other, prefer_not_to_say }

enum UserType { individual, organization }

enum CreatedBy { user, system, admin }

// Main Certification model
class CertificationDB {
  final String idCertification;
  final String idCertificationHash;
  final String idCertifier;
  final String idLegalEntity;
  final CertificationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String serialNumber;
  final String idLocation;
  final int nUsers;
  final DateTime? sentAt;
  final DateTime? draftAt;
  final DateTime? closedAt;
  final String idCertificationCategory;

  CertificationDB({
    required this.idCertification,
    required this.idCertificationHash,
    required this.idCertifier,
    required this.idLegalEntity,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.serialNumber,
    required this.idLocation,
    required this.nUsers,
    this.sentAt,
    this.draftAt,
    this.closedAt,
    required this.idCertificationCategory,
  });

  factory CertificationDB.fromJson(Map<String, dynamic> json) {
    return CertificationDB(
      idCertification: json['id_certification'] ?? '',
      idCertificationHash: json['id_certification_hash'] ?? '',
      idCertifier: json['id_certifier'] ?? '',
      idLegalEntity: json['id_legal_entity'] ?? '',
      status: CertificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CertificationStatus.draft,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_t'] != null
          ? DateTime.parse(json['updated_t'])
          : null,
      serialNumber: json['serial_number'] ?? '',
      idLocation: json['id_location'] ?? '',
      nUsers: json['n_users'] ?? 0,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      draftAt: json['draft_at'] != null
          ? DateTime.parse(json['draft_at'])
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
      idCertificationCategory: json['id_certification_category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification': idCertification,
      'id_certification_hash': idCertificationHash,
      'id_certifier': idCertifier,
      'id_legal_entity': idLegalEntity,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_t': updatedAt?.toIso8601String(),
      'serial_number': serialNumber,
      'id_location': idLocation,
      'n_users': nUsers,
      'sent_at': sentAt?.toIso8601String(),
      'draft_at': draftAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'id_certification_category': idCertificationCategory,
    };
  }
}

// Certification Category model
class CertificationCategoryDB {
  final String idCertificationCategory;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CertificationCategoryType type;
  final int? order;
  final String? idLegalEntity;

  CertificationCategoryDB({
    required this.idCertificationCategory,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    this.order,
    this.idLegalEntity,
  });

  factory CertificationCategoryDB.fromJson(Map<String, dynamic> json) {
    return CertificationCategoryDB(
      idCertificationCategory: json['id_certification_category'] ?? '',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      type: CertificationCategoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CertificationCategoryType.other,
      ),
      order: json['order'],
      idLegalEntity: json['id_legal_entity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification_category': idCertificationCategory,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type.name,
      'order': order,
      'id_legal_entity': idLegalEntity,
    };
  }
}

// Certification Information model
class CertificationInformationDB {
  final String idCertificationInformation;
  final String name;
  final int? order;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String label;
  final CertificationInformationType? type;
  final String? idLegalEntity;
  final CertificationInformationScope? scope;

  CertificationInformationDB({
    required this.idCertificationInformation,
    required this.name,
    this.order,
    required this.createdAt,
    this.updatedAt,
    required this.label,
    this.type,
    this.idLegalEntity,
    this.scope,
  });

  factory CertificationInformationDB.fromJson(Map<String, dynamic> json) {
    return CertificationInformationDB(
      idCertificationInformation: json['id_certification_information'] ?? '',
      name: json['name'] ?? '',
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      label: json['label'] ?? '',
      type: json['type'] != null
          ? CertificationInformationType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => CertificationInformationType.text,
            )
          : null,
      idLegalEntity: json['id_legal_entity'],
      scope: json['scope'] != null
          ? CertificationInformationScope.values.firstWhere(
              (e) => e.name == json['scope'],
              orElse: () => CertificationInformationScope.general,
            )
          : null,
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
      'type': type?.name,
      'id_legal_entity': idLegalEntity,
      'scope': scope?.name,
    };
  }
}

// Certification Information Value model
class CertificationInformationValueDB {
  final int idCertificationInformationValue;
  final String idCertificationInformation;
  final String? value;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? idCertification;
  final String? idCertificationUser;

  CertificationInformationValueDB({
    required this.idCertificationInformationValue,
    required this.idCertificationInformation,
    this.value,
    required this.createdAt,
    this.updatedAt,
    this.idCertification,
    this.idCertificationUser,
  });

  factory CertificationInformationValueDB.fromJson(Map<String, dynamic> json) {
    return CertificationInformationValueDB(
      idCertificationInformationValue:
          json['id_certification_information_value'] ?? 0,
      idCertificationInformation: json['id_certification_information'] ?? '',
      value: json['value'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      idCertification: json['id_certification'],
      idCertificationUser: json['id_certification_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification_information_value': idCertificationInformationValue,
      'id_certification_information': idCertificationInformation,
      'value': value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'id_certification': idCertification,
      'id_certification_user': idCertificationUser,
    };
  }
}

// Certification Media model
class CertificationMediaDB {
  final String idCertificationMedia;
  final String idMediaHash;
  final String idCertification;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? name;
  final String? description;
  final AcquisitionType acquisitionType;
  final DateTime capturedAt;
  final String? idLocation;
  final FileType fileType;

  CertificationMediaDB({
    required this.idCertificationMedia,
    required this.idMediaHash,
    required this.idCertification,
    required this.createdAt,
    this.updatedAt,
    this.name,
    this.description,
    required this.acquisitionType,
    required this.capturedAt,
    this.idLocation,
    required this.fileType,
  });

  factory CertificationMediaDB.fromJson(Map<String, dynamic> json) {
    return CertificationMediaDB(
      idCertificationMedia: json['id_certification_media'] ?? '',
      idMediaHash: json['id_media_hash'] ?? '',
      idCertification: json['id_certification'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      name: json['name'],
      description: json['description'],
      acquisitionType: AcquisitionType.values.firstWhere(
        (e) => e.name == json['acquisition_type'],
        orElse: () => AcquisitionType.manual,
      ),
      capturedAt: DateTime.parse(json['captured_at']),
      idLocation: json['id_location'],
      fileType: FileType.values.firstWhere(
        (e) => e.name == json['file_type'],
        orElse: () => FileType.image,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification_media': idCertificationMedia,
      'id_media_hash': idMediaHash,
      'id_certification': idCertification,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'name': name,
      'description': description,
      'acquisition_type': acquisitionType.name,
      'captured_at': capturedAt.toIso8601String(),
      'id_location': idLocation,
      'file_type': fileType.name,
    };
  }
}

// Certification User model
class CertificationUserDB {
  final String idCertificationUser;
  final String idCertification;
  final String idUser;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CertificationUserStatus status;
  final String serialNumber;
  final String? rejectionReason;
  final String idOtp;

  CertificationUserDB({
    required this.idCertificationUser,
    required this.idCertification,
    required this.idUser,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.serialNumber,
    this.rejectionReason,
    required this.idOtp,
  });

  factory CertificationUserDB.fromJson(Map<String, dynamic> json) {
    return CertificationUserDB(
      idCertificationUser: json['id_certification_user'] ?? '',
      idCertification: json['id_certification'] ?? '',
      idUser: json['id_user'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      status: CertificationUserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CertificationUserStatus.draft,
      ),
      serialNumber: json['serial_number'] ?? '',
      rejectionReason: json['rejection_reason'],
      idOtp: json['id_otp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification_user': idCertificationUser,
      'id_certification': idCertification,
      'id_user': idUser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status.name,
      'serial_number': serialNumber,
      'rejection_reason': rejectionReason,
      'id_otp': idOtp,
    };
  }
}

// Certifier model
class CertifierDB {
  final String idCertifier;
  final String idCertifierHash;
  final String idLegalEntity;
  final String? idUser;
  final bool active;
  final String? role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? invitationToken;
  final bool? kycPassed;
  final String? idKycAttempt;

  CertifierDB({
    required this.idCertifier,
    required this.idCertifierHash,
    required this.idLegalEntity,
    this.idUser,
    required this.active,
    this.role,
    required this.createdAt,
    this.updatedAt,
    this.invitationToken,
    this.kycPassed,
    this.idKycAttempt,
  });

  factory CertifierDB.fromJson(Map<String, dynamic> json) {
    return CertifierDB(
      idCertifier: json['id_certifier'] ?? '',
      idCertifierHash: json['id_certifier_hash'] ?? '',
      idLegalEntity: json['id_legal_entity'] ?? '',
      idUser: json['id_user'],
      active: json['active'] ?? true,
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      invitationToken: json['invitation_token'],
      kycPassed: json['kyc_passed'],
      idKycAttempt: json['id_kyc_attempt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certifier': idCertifier,
      'id_certifier_hash': idCertifierHash,
      'id_legal_entity': idLegalEntity,
      'id_user': idUser,
      'active': active,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'invitation_token': invitationToken,
      'kyc_passed': kycPassed,
      'id_kyc_attempt': idKycAttempt,
    };
  }
}

// Location model
class LocationDB {
  final String idLocation;
  final String idUser;
  final DateTime acquiredAt;
  final double latitude;
  final double longitude;
  final double? accuracyM;
  final bool? isMoked;
  final double? altitude;
  final double? altitudeAccuracyM;
  final String? name;
  final String? street;
  final String? locality;
  final String? subLocality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? postalCode;
  final String? isoCountryCode;
  final String? country;
  final String? thoroughfare;
  final String? subThoroughfare;
  final DateTime createdAt;

  LocationDB({
    required this.idLocation,
    required this.idUser,
    required this.acquiredAt,
    required this.latitude,
    required this.longitude,
    this.accuracyM,
    this.isMoked,
    this.altitude,
    this.altitudeAccuracyM,
    this.name,
    this.street,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.isoCountryCode,
    this.country,
    this.thoroughfare,
    this.subThoroughfare,
    required this.createdAt,
  });

  factory LocationDB.fromJson(Map<String, dynamic> json) {
    return LocationDB(
      idLocation: json['id_location'] ?? '',
      idUser: json['id_user'] ?? '',
      acquiredAt: DateTime.parse(json['acquired_at']),
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      accuracyM: json['accuracy_m']?.toDouble(),
      isMoked: json['is_moked'],
      altitude: json['altitude']?.toDouble(),
      altitudeAccuracyM: json['altitude_accuracy_m']?.toDouble(),
      name: json['name'],
      street: json['street'],
      locality: json['locality'],
      subLocality: json['sub_locality'],
      administrativeArea: json['administrative_area'],
      subAdministrativeArea: json['sub_administrative_area'],
      postalCode: json['postal_code'],
      isoCountryCode: json['iso_country_code'],
      country: json['country'],
      thoroughfare: json['thoroughfare'],
      subThoroughfare: json['sub_thoroughfare'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_location': idLocation,
      'id_user': idUser,
      'acquired_at': acquiredAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_m': accuracyM,
      'is_moked': isMoked,
      'altitude': altitude,
      'altitude_accuracy_m': altitudeAccuracyM,
      'name': name,
      'street': street,
      'locality': locality,
      'sub_locality': subLocality,
      'administrative_area': administrativeArea,
      'sub_administrative_area': subAdministrativeArea,
      'postal_code': postalCode,
      'iso_country_code': isoCountryCode,
      'country': country,
      'thoroughfare': thoroughfare,
      'sub_thoroughfare': subThoroughfare,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
