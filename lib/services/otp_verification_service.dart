import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jetcv_enterprise/config/app_config.dart';

class OtpVerificationService {
  static const String _baseUrl =
      '${AppConfig.supabaseUrl}/functions/v1/verify-otp-and-get-user';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
    'apikey': AppConfig.supabaseAnonKey,
  };

  /// Verifica un OTP e ottiene i dati dell'utente
  static Future<OtpVerificationResult> verifyOtp(String code) async {
    try {
      print('🔍 Verifying OTP: $code');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: json.encode({'code': code}),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final result = OtpVerificationResult.fromJson(data);
        print('✅ OTP verification successful');
        return result;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Errore sconosciuto';
        print('❌ OTP verification failed: $errorMessage');
        return OtpVerificationResult.error(errorMessage);
      }
    } catch (e) {
      print('❌ Exception verifying OTP: $e');
      return OtpVerificationResult.error('Errore di connessione: $e');
    }
  }
}

class OtpVerificationResult {
  final bool success;
  final String? errorMessage;
  final OtpData? otp;
  final UserData? user;

  OtpVerificationResult({
    required this.success,
    this.errorMessage,
    this.otp,
    this.user,
  });

  factory OtpVerificationResult.fromJson(Map<String, dynamic> json) {
    if (json['ok'] == true) {
      return OtpVerificationResult(
        success: true,
        otp: OtpData.fromJson(json['otp']),
        user: UserData.fromJson(json['user']),
      );
    } else {
      return OtpVerificationResult(
        success: false,
        errorMessage: json['error'] ?? 'Errore sconosciuto',
      );
    }
  }

  factory OtpVerificationResult.error(String message) {
    return OtpVerificationResult(success: false, errorMessage: message);
  }
}

class OtpData {
  final String idOtp;
  final String idUser;

  OtpData({required this.idOtp, required this.idUser});

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      idOtp: json['id_otp'] as String,
      idUser: json['id_user'] as String,
    );
  }
}

class UserData {
  final String idUser;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? countryCode;
  final String? profilePicture;
  final String? gender;
  final String createdAt;
  final String? updatedAt;

  UserData({
    required this.idUser,
    this.firstName,
    this.lastName,
    this.fullName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.countryCode,
    this.profilePicture,
    this.gender,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      idUser: json['idUser'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      fullName: json['fullName'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      countryCode: json['countryCode'] as String?,
      profilePicture: json['profilePicture'] as String?,
      gender: json['gender'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return email;
  }

  String get location {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (countryCode != null && countryCode!.isNotEmpty) parts.add(countryCode!);
    return parts.join(', ');
  }

  @override
  String toString() {
    return 'UserData(idUser: $idUser, email: $email, displayName: $displayName)';
  }
}
