import 'package:uuid/uuid.dart';

class OTP {
  final String idOtp;
  final String idUser;
  final String code;
  final String codeHash;
  final String? tag;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String? usedByIdUser;
  final DateTime? burnedAt;

  OTP({
    String? idOtp,
    required this.idUser,
    required this.code,
    required this.codeHash,
    this.tag,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.expiresAt,
    this.usedAt,
    this.usedByIdUser,
    this.burnedAt,
  }) : idOtp = idOtp ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt;

  factory OTP.fromJson(Map<String, dynamic> json) {
    return OTP(
      idOtp: json['id_otp'],
      idUser: json['id_user'],
      code: json['code'],
      codeHash: json['code_hash'],
      tag: json['tag'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      expiresAt: DateTime.parse(json['expires_at']),
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      usedByIdUser: json['used_by_id_user'],
      burnedAt: json['burned_at'] != null
          ? DateTime.parse(json['burned_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_otp': idOtp,
      'id_user': idUser,
      'code': code,
      'code_hash': codeHash,
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'used_by_id_user': usedByIdUser,
      'burned_at': burnedAt?.toIso8601String(),
    };
  }

  OTP copyWith({
    String? idOtp,
    String? idUser,
    String? code,
    String? codeHash,
    String? tag,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? usedAt,
    String? usedByIdUser,
    DateTime? burnedAt,
  }) {
    return OTP(
      idOtp: idOtp ?? this.idOtp,
      idUser: idUser ?? this.idUser,
      code: code ?? this.code,
      codeHash: codeHash ?? this.codeHash,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
      usedByIdUser: usedByIdUser ?? this.usedByIdUser,
      burnedAt: burnedAt ?? this.burnedAt,
    );
  }

  // Getters utili
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isUsed => usedAt != null;
  bool get isBurned => burnedAt != null;
  bool get isValid => !isExpired && !isUsed && !isBurned;
  bool get isExpiringSoon {
    final now = DateTime.now();
    final timeUntilExpiry = expiresAt.difference(now);
    return timeUntilExpiry.inMinutes <= 5;
  }

  Duration get timeUntilExpiry {
    final now = DateTime.now();
    return expiresAt.difference(now);
  }

  String get formattedExpiryTime {
    final duration = timeUntilExpiry;
    if (duration.isNegative) {
      return 'Scaduto';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get statusDisplayName {
    if (isBurned) return 'Bruciato';
    if (isUsed) return 'Utilizzato';
    if (isExpired) return 'Scaduto';
    if (isExpiringSoon) return 'Scade Presto';
    return 'Valido';
  }

  String get statusColor {
    if (isBurned) return '#F44336';
    if (isUsed) return '#9E9E9E';
    if (isExpired) return '#FF6B6B';
    if (isExpiringSoon) return '#FFA726';
    return '#4CAF50';
  }
}
