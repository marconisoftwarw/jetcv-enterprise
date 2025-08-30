import 'package:uuid/uuid.dart';

enum CertificationUserStatus {
  draft,
  pending,
  approved,
  rejected,
  completed,
  expired,
}

class CertificationUser {
  final String idCertificationUser;
  final String idCertification;
  final String idUser;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CertificationUserStatus status;
  final String serialNumber;
  final String? rejectionReason;
  final String idOtp;

  CertificationUser({
    String? idCertificationUser,
    required this.idCertification,
    required this.idUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = CertificationUserStatus.draft,
    String? serialNumber,
    this.rejectionReason,
    required this.idOtp,
  }) : idCertificationUser = idCertificationUser ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt,
       serialNumber = serialNumber ?? _generateSerialNumber();

  factory CertificationUser.fromJson(Map<String, dynamic> json) {
    return CertificationUser(
      idCertificationUser: json['id_certification_user'],
      idCertification: json['id_certification'],
      idUser: json['id_user'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      status: _parseStatus(json['status']),
      serialNumber: json['serial_number'],
      rejectionReason: json['rejection_reason'],
      idOtp: json['id_otp'],
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

  CertificationUser copyWith({
    String? idCertificationUser,
    String? idCertification,
    String? idUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    CertificationUserStatus? status,
    String? serialNumber,
    String? rejectionReason,
    String? idOtp,
  }) {
    return CertificationUser(
      idCertificationUser: idCertificationUser ?? this.idCertificationUser,
      idCertification: idCertification ?? this.idCertification,
      idUser: idUser ?? this.idUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      serialNumber: serialNumber ?? this.serialNumber,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      idOtp: idOtp ?? this.idOtp,
    );
  }

  static CertificationUserStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'draft':
        return CertificationUserStatus.draft;
      case 'pending':
        return CertificationUserStatus.pending;
      case 'approved':
        return CertificationUserStatus.approved;
      case 'rejected':
        return CertificationUserStatus.rejected;
      case 'completed':
        return CertificationUserStatus.completed;
      case 'expired':
        return CertificationUserStatus.expired;
      default:
        return CertificationUserStatus.draft;
    }
  }

  static String _generateSerialNumber() {
    // Genera un serial number nel formato AAAAA-BBBBB
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;

    String generatePart() {
      String result = '';
      for (int i = 0; i < 5; i++) {
        result += chars[random % chars.length];
      }
      return result;
    }

    return '${generatePart()}-${generatePart()}';
  }

  // Getters utili
  bool get isDraft => status == CertificationUserStatus.draft;
  bool get isPending => status == CertificationUserStatus.pending;
  bool get isApproved => status == CertificationUserStatus.approved;
  bool get isRejected => status == CertificationUserStatus.rejected;
  bool get isCompleted => status == CertificationUserStatus.completed;
  bool get isExpired => status == CertificationUserStatus.expired;
  bool get canBeApproved => isPending;
  bool get canBeRejected => isPending;
  bool get hasRejectionReason =>
      rejectionReason != null && rejectionReason!.isNotEmpty;

  String get statusDisplayName {
    switch (status) {
      case CertificationUserStatus.draft:
        return 'Bozza';
      case CertificationUserStatus.pending:
        return 'In Attesa';
      case CertificationUserStatus.approved:
        return 'Approvato';
      case CertificationUserStatus.rejected:
        return 'Rifiutato';
      case CertificationUserStatus.completed:
        return 'Completato';
      case CertificationUserStatus.expired:
        return 'Scaduto';
    }
  }

  String get statusColor {
    switch (status) {
      case CertificationUserStatus.draft:
        return '#9E9E9E';
      case CertificationUserStatus.pending:
        return '#FFA726';
      case CertificationUserStatus.approved:
        return '#4CAF50';
      case CertificationUserStatus.rejected:
        return '#F44336';
      case CertificationUserStatus.completed:
        return '#2196F3';
      case CertificationUserStatus.expired:
        return '#FF6B6B';
    }
  }
}
