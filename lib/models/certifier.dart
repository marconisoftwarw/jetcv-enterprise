import 'package:uuid/uuid.dart';

class Certifier {
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

  Certifier({
    String? idCertifier,
    String? idCertifierHash,
    required this.idLegalEntity,
    this.idUser,
    this.active = true,
    this.role,
    DateTime? createdAt,
    this.updatedAt,
    this.invitationToken,
    this.kycPassed,
    this.idKycAttempt,
  }) : idCertifier = idCertifier ?? const Uuid().v4(),
       idCertifierHash = idCertifierHash ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Certifier.fromJson(Map<String, dynamic> json) {
    return Certifier(
      idCertifier: json['id_certifier'],
      idCertifierHash: json['id_certifier_hash'],
      idLegalEntity: json['id_legal_entity'],
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

  Certifier copyWith({
    String? idCertifier,
    String? idCertifierHash,
    String? idLegalEntity,
    String? idUser,
    bool? active,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? invitationToken,
    bool? kycPassed,
    String? idKycAttempt,
  }) {
    return Certifier(
      idCertifier: idCertifier ?? this.idCertifier,
      idCertifierHash: idCertifierHash ?? this.idCertifierHash,
      idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      idUser: idUser ?? this.idUser,
      active: active ?? this.active,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invitationToken: invitationToken ?? this.invitationToken,
      kycPassed: kycPassed ?? this.kycPassed,
      idKycAttempt: idKycAttempt ?? this.idKycAttempt,
    );
  }

  // Getters utili
  bool get hasUser => idUser != null;
  bool get hasKyc => kycPassed != null;
  bool get isKycPassed => kycPassed == true;
  bool get hasInvitationToken =>
      invitationToken != null && invitationToken!.isNotEmpty;
  String get roleDisplayName => role ?? 'Certificatore';
  String get statusDisplayName => active ? 'Attivo' : 'Inattivo';
}
