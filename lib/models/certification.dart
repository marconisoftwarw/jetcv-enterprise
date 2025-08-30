import 'package:uuid/uuid.dart';
import 'certification_support.dart';

enum CertificationStatus {
  draft,
  submitted,
  approved,
  rejected,
  expired,
  revoked,
  closed,
}

class Certification {
  final String idCertification;
  final String idCertificationHash;
  final String idCertifier;
  final String idLegalEntity;
  final CertificationStatus status;
  final DateTime createdAt;
  final DateTime? updatedT;
  final String serialNumber;
  final String idLocation;
  final int nUsers;
  final DateTime? sentAt;
  final DateTime? draftAt;
  final DateTime? closedAt;

  // Campi aggiuntivi per compatibilità con l'UI esistente
  String get title => 'Certificazione $serialNumber';
  String get code => serialNumber;
  String get description =>
      'Certificazione creata il ${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get type => 'Standard';
  bool get isOffline => false;
  bool get isSynchronized => true;

  Certification({
    String? idCertification,
    required this.idCertificationHash,
    required this.idCertifier,
    required this.idLegalEntity,
    this.status = CertificationStatus.draft,
    DateTime? createdAt,
    this.updatedT,
    String? serialNumber,
    required this.idLocation,
    this.nUsers = 0,
    this.sentAt,
    this.draftAt,
    this.closedAt,
  }) : idCertification = idCertification ?? const Uuid().v4(),
       serialNumber = serialNumber ?? _generateSerialNumber(),
       createdAt = createdAt ?? DateTime.now();

  static String _generateSerialNumber() {
    // Generate a base36 serial number in format: XXXXX-XXXXX
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final part1 = String.fromCharCodes(
      List.generate(
        5,
        (index) => chars.codeUnitAt((random + index) % chars.length),
      ),
    );
    final part2 = String.fromCharCodes(
      List.generate(
        5,
        (index) => chars.codeUnitAt((random + index + 5) % chars.length),
      ),
    );
    return '$part1-$part2';
  }

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      idCertification: json['id_certification'],
      idCertificationHash: json['id_certification_hash'],
      idCertifier: json['id_certifier'],
      idLegalEntity: json['id_legal_entity'],
      status: CertificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CertificationStatus.draft,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedT: json['updated_t'] != null
          ? DateTime.parse(json['updated_t'])
          : null,
      serialNumber: json['serial_number'],
      idLocation: json['id_location'],
      nUsers: json['n_users'] ?? 0,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      draftAt: json['draft_at'] != null
          ? DateTime.parse(json['draft_at'])
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_certification': idCertification,
      'id_certification_hash': idCertificationHash,
      'id_certifier': idCertifier,
      'id_legal_entity': idLegalEntity,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_t': updatedT?.toIso8601String(),
      'serial_number': serialNumber,
      'id_location': idLocation,
      'n_users': nUsers,
      'sent_at': sentAt?.toIso8601String(),
      'draft_at': draftAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
    };
  }

  Certification copyWith({
    String? idCertification,
    String? idCertificationHash,
    String? idCertifier,
    String? idLegalEntity,
    CertificationStatus? status,
    DateTime? createdAt,
    DateTime? updatedT,
    String? serialNumber,
    String? idLocation,
    int? nUsers,
    DateTime? sentAt,
    DateTime? draftAt,
    DateTime? closedAt,
  }) {
    return Certification(
      idCertification: idCertification ?? this.idCertification,
      idCertificationHash: idCertificationHash ?? this.idCertificationHash,
      idCertifier: idCertifier ?? this.idCertifier,
      idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedT: updatedT ?? this.updatedT,
      serialNumber: serialNumber ?? this.serialNumber,
      idLocation: idLocation ?? this.idLocation,
      nUsers: nUsers ?? this.nUsers,
      sentAt: sentAt ?? this.sentAt,
      draftAt: draftAt ?? this.draftAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case CertificationStatus.draft:
        return 'Bozza';
      case CertificationStatus.submitted:
        return 'Inviata';
      case CertificationStatus.approved:
        return 'Approvata';
      case CertificationStatus.rejected:
        return 'Rifiutata';
      case CertificationStatus.expired:
        return 'Scaduta';
      case CertificationStatus.revoked:
        return 'Revocata';
      case CertificationStatus.closed:
        return 'Chiusa';
    }
  }

  bool get isDraft => status == CertificationStatus.draft;
  bool get isSubmitted => status == CertificationStatus.submitted;
  bool get isApproved => status == CertificationStatus.approved;
  bool get isRejected => status == CertificationStatus.rejected;
  bool get isExpired => status == CertificationStatus.expired;
  bool get isRevoked => status == CertificationStatus.revoked;
  bool get isClosed => status == CertificationStatus.closed;
  bool get hasUsers => nUsers > 0;
  bool get isActive =>
      status == CertificationStatus.approved ||
      status == CertificationStatus.submitted;
  String get displaySerialNumber => serialNumber;

  // Getter per compatibilità con l'UI esistente
  String get location => 'Indirizzo non specificato';
}

class CertificationAttachment {
  final String idAttachment;
  final String idCertification;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;
  final String? description;

  CertificationAttachment({
    String? idAttachment,
    required this.idCertification,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    DateTime? createdAt,
    this.description,
  }) : idAttachment = idAttachment ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory CertificationAttachment.fromJson(Map<String, dynamic> json) {
    return CertificationAttachment(
      idAttachment: json['id_attachment'],
      idCertification: json['id_certification'],
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_attachment': idAttachment,
      'id_certification': idCertification,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }

  CertificationAttachment copyWith({
    String? idAttachment,
    String? idCertification,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
    String? description,
  }) {
    return CertificationAttachment(
      idAttachment: idAttachment ?? this.idAttachment,
      idCertification: idCertification ?? this.idCertification,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  String get fileSizeDisplay {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
