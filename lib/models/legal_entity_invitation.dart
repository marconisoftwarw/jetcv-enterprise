import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

enum InvitationStatus { pending, accepted, rejected, expired }

class LegalEntityInvitation {
  final int? idInvitation;
  final String idLegalEntity;
  final String email;
  final String invitationToken;
  final InvitationStatus status;
  final DateTime sentAt;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;

  LegalEntityInvitation({
    this.idInvitation,
    required this.idLegalEntity,
    required this.email,
    required this.invitationToken,
    this.status = InvitationStatus.pending,
    DateTime? sentAt,
    this.expiresAt,
    this.acceptedAt,
    this.rejectedAt,
  }) : sentAt = sentAt ?? DateTime.now();

  // Factory constructor per creare un invito con token generato
  factory LegalEntityInvitation.create({
    required String idLegalEntity,
    required String email,
    DateTime? expiresAt,
  }) {
    return LegalEntityInvitation(
      idLegalEntity: idLegalEntity,
      email: email,
      invitationToken: Uuid().v4(),
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 7)),
    );
  }

  // Factory constructor per creare un invito con token esistente
  factory LegalEntityInvitation.withToken({
    required String idLegalEntity,
    required String email,
    required String invitationToken,
    DateTime? expiresAt,
  }) {
    return LegalEntityInvitation(
      idLegalEntity: idLegalEntity,
      email: email,
      invitationToken: invitationToken,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 7)),
    );
  }

  factory LegalEntityInvitation.fromJson(Map<String, dynamic> json) {
    return LegalEntityInvitation(
      idInvitation: json['id_invitation'],
      idLegalEntity: json['id_legal_entity'],
      email: json['email'],
      invitationToken: json['invitation_token'],
      status: _parseStatus(json['status']),
      sentAt: DateTime.parse(json['sent_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_invitation': idInvitation,
      'id_legal_entity': idLegalEntity,
      'email': email,
      'invitation_token': invitationToken,
      'status': status.name,
      'sent_at': sentAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
    };
  }

  LegalEntityInvitation copyWith({
    int? idInvitation,
    String? idLegalEntity,
    String? email,
    String? invitationToken,
    InvitationStatus? status,
    DateTime? sentAt,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
  }) {
    return LegalEntityInvitation(
      idInvitation: idInvitation ?? this.idInvitation,
      idLegalEntity: idLegalEntity ?? this.idLegalEntity,
      email: email ?? this.email,
      invitationToken: invitationToken ?? this.invitationToken,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
    );
  }

  static InvitationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'rejected':
        return InvitationStatus.rejected;
      case 'expired':
        return InvitationStatus.expired;
      default:
        return InvitationStatus.pending;
    }
  }

  // Getters utili
  bool get isPending => status == InvitationStatus.pending;
  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isRejected => status == InvitationStatus.rejected;
  bool get isExpired => status == InvitationStatus.expired;
  bool get isActive => isPending && !_isExpired;
  bool get _isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  String get statusDisplayName {
    switch (status) {
      case InvitationStatus.pending:
        return _isExpired ? 'Scaduto' : 'In attesa';
      case InvitationStatus.accepted:
        return 'Accettato';
      case InvitationStatus.rejected:
        return 'Rifiutato';
      case InvitationStatus.expired:
        return 'Scaduto';
    }
  }

  String get statusColor {
    switch (status) {
      case InvitationStatus.pending:
        return _isExpired ? '#FF6B6B' : '#FFA726';
      case InvitationStatus.accepted:
        return '#4CAF50';
      case InvitationStatus.rejected:
        return '#F44336';
      case InvitationStatus.expired:
        return '#9E9E9E';
    }
  }

  String get invitationLink =>
      '${AppConfig.appUrl}/invite/accept/$invitationToken';
}
