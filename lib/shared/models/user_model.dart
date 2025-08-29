import 'package:uuid/uuid.dart';

class User {
  final String idUser;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? countryCode;
  final String? profilePicture;
  final String? gender;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fullName;
  final String? type;
  final bool hasWallet;
  final String? idWallet;
  final bool hasCv;
  final String? idCv;
  final String idUserHash;
  final bool profileCompleted;
  final bool? kycCompleted;
  final bool? kycPassed;
  final String? languageCode;

  User({
    required this.idUser,
    this.firstName,
    this.lastName,
    this.email,
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
    this.fullName,
    this.type,
    required this.hasWallet,
    this.idWallet,
    required this.hasCv,
    this.idCv,
    required this.idUserHash,
    required this.profileCompleted,
    this.kycCompleted,
    this.kycPassed,
    this.languageCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['idUser'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      countryCode: json['countryCode'],
      profilePicture: json['profilePicture'],
      gender: json['gender'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      fullName: json['fullName'],
      type: json['type'],
      hasWallet: json['hasWallet'] ?? false,
      idWallet: json['idWallet'],
      hasCv: json['hasCv'] ?? false,
      idCv: json['idCv'],
      idUserHash: json['idUserHash'] ?? '',
      profileCompleted: json['profileCompleted'] ?? false,
      kycCompleted: json['kycCompleted'],
      kycPassed: json['kycPassed'],
      languageCode: json['languageCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'countryCode': countryCode,
      'profilePicture': profilePicture,
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'fullName': fullName,
      'type': type,
      'hasWallet': hasWallet,
      'idWallet': idWallet,
      'hasCv': hasCv,
      'idCv': idCv,
      'idUserHash': idUserHash,
      'profileCompleted': profileCompleted,
      'kycCompleted': kycCompleted,
      'kycPassed': kycPassed,
      'languageCode': languageCode,
    };
  }

  User copyWith({
    String? idUser,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? countryCode,
    String? profilePicture,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? type,
    bool? hasWallet,
    String? idWallet,
    bool? hasCv,
    String? idCv,
    String? idUserHash,
    bool? profileCompleted,
    bool? kycCompleted,
    bool? kycPassed,
    String? languageCode,
  }) {
    return User(
      idUser: idUser ?? this.idUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      profilePicture: profilePicture ?? this.profilePicture,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      type: type ?? this.type,
      hasWallet: hasWallet ?? this.hasWallet,
      idWallet: idWallet ?? this.idWallet,
      hasCv: hasCv ?? this.hasCv,
      idCv: idCv ?? this.idCv,
      idUserHash: idUserHash ?? this.idUserHash,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      kycCompleted: kycCompleted ?? this.kycCompleted,
      kycPassed: kycPassed ?? this.kycPassed,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  bool get isAdmin => type == 'admin';
  bool get isCertifier => type == 'certifier';
  String get displayName => fullName ?? '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
