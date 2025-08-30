import 'package:uuid/uuid.dart';

class KYCAttempt {
  final String idKycAttempt;
  final String idUser;
  final String? requestBody;
  final String? success;
  final String? message;
  final String? receivedParams;
  final String? responseStatus;
  final String? responseVerificationId;
  final String? responseVerificationUrl;
  final String? responseVerificationSessionToken;
  final String? responseVerificationUrlStation;
  final String? responseSessionUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? sessionId;
  final bool? verificated;
  final DateTime? verificatedAt;

  KYCAttempt({
    String? idKycAttempt,
    required this.idUser,
    this.requestBody,
    this.success,
    this.message,
    this.receivedParams,
    this.responseStatus,
    this.responseVerificationId,
    this.responseVerificationUrl,
    this.responseVerificationSessionToken,
    this.responseVerificationUrlStation,
    this.responseSessionUrl,
    DateTime? createdAt,
    this.updatedAt,
    this.sessionId,
    this.verificated,
    this.verificatedAt,
  }) : idKycAttempt = idKycAttempt ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory KYCAttempt.fromJson(Map<String, dynamic> json) {
    return KYCAttempt(
      idKycAttempt: json['id_kyc_attempt'],
      idUser: json['id_user'],
      requestBody: json['request_body'],
      success: json['success'],
      message: json['message'],
      receivedParams: json['received_params'],
      responseStatus: json['response_status'],
      responseVerificationId: json['response_verification_id'],
      responseVerificationUrl: json['response_verification_url'],
      responseVerificationSessionToken:
          json['response_verification_session_token'],
      responseVerificationUrlStation: json['response_verification_url_station'],
      responseSessionUrl: json['response_session_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      sessionId: json['session_id'],
      verificated: json['verificated'],
      verificatedAt: json['verificated_at'] != null
          ? DateTime.parse(json['verificated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kyc_attempt': idKycAttempt,
      'id_user': idUser,
      'request_body': requestBody,
      'success': success,
      'message': message,
      'received_params': receivedParams,
      'response_status': responseStatus,
      'response_verification_id': responseVerificationId,
      'response_verification_url': responseVerificationUrl,
      'response_verification_session_token': responseVerificationSessionToken,
      'response_verification_url_station': responseVerificationUrlStation,
      'response_session_url': responseSessionUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'session_id': sessionId,
      'verificated': verificated,
      'verificated_at': verificatedAt?.toIso8601String(),
    };
  }

  KYCAttempt copyWith({
    String? idKycAttempt,
    String? idUser,
    String? requestBody,
    String? success,
    String? message,
    String? receivedParams,
    String? responseStatus,
    String? responseVerificationId,
    String? responseVerificationUrl,
    String? responseVerificationSessionToken,
    String? responseVerificationUrlStation,
    String? responseSessionUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sessionId,
    bool? verificated,
    DateTime? verificatedAt,
  }) {
    return KYCAttempt(
      idKycAttempt: idKycAttempt ?? this.idKycAttempt,
      idUser: idUser ?? this.idUser,
      requestBody: requestBody ?? this.requestBody,
      success: success ?? this.success,
      message: message ?? this.message,
      receivedParams: receivedParams ?? this.receivedParams,
      responseStatus: responseStatus ?? this.responseStatus,
      responseVerificationId:
          responseVerificationId ?? this.responseVerificationId,
      responseVerificationUrl:
          responseVerificationUrl ?? this.responseVerificationUrl,
      responseVerificationSessionToken:
          responseVerificationSessionToken ??
          this.responseVerificationSessionToken,
      responseVerificationUrlStation:
          responseVerificationUrlStation ?? this.responseVerificationUrlStation,
      responseSessionUrl: responseSessionUrl ?? this.responseSessionUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionId: sessionId ?? this.sessionId,
      verificated: verificated ?? this.verificated,
      verificatedAt: verificatedAt ?? this.verificatedAt,
    );
  }

  // Getters
  bool get isSuccessful => success == 'true';
  bool get isVerificated => verificated == true;
  bool get hasVerificationUrl =>
      responseVerificationUrl != null && responseVerificationUrl!.isNotEmpty;
  bool get hasVerificationUrlStation =>
      responseVerificationUrlStation != null &&
      responseVerificationUrlStation!.isNotEmpty;
  bool get hasSessionToken =>
      responseVerificationSessionToken != null &&
      responseVerificationSessionToken!.isNotEmpty;
  bool get hasSessionUrl =>
      responseSessionUrl != null && responseSessionUrl!.isNotEmpty;

  String get statusDisplayName {
    if (isVerificated) return 'Verificato';
    if (isSuccessful) return 'Completato';
    if (success == 'false') return 'Fallito';
    return 'In Elaborazione';
  }
}
