enum UserType {
  admin, // Amministratore del sistema
  user, // Utente standard
  certifier, // Certificatore
  manager, // Manager
  operator, // Operatore
  viewer, // Visualizzatore
  legalRepresentative, // Rappresentante legale
  technicalManager, // Responsabile tecnico
  qualityManager, // Responsabile qualità
  safetyManager, // Responsabile sicurezza
  hrManager, // Responsabile HR
}

enum Gender { male, female, other, preferNotToSay }

enum UserRole {
  admin,
  certifier,
  manager,
  operator,
  viewer,
  legalRepresentative,
  technicalManager,
  qualityManager,
  safetyManager,
  hrManager,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Amministratore';
      case UserRole.certifier:
        return 'Certificatore';
      case UserRole.manager:
        return 'Manager';
      case UserRole.operator:
        return 'Operatore';
      case UserRole.viewer:
        return 'Visualizzatore';
      case UserRole.legalRepresentative:
        return 'Rappresentante Legale';
      case UserRole.technicalManager:
        return 'Responsabile Tecnico';
      case UserRole.qualityManager:
        return 'Responsabile Qualità';
      case UserRole.safetyManager:
        return 'Responsabile Sicurezza';
      case UserRole.hrManager:
        return 'Responsabile HR';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Accesso completo a tutte le funzionalità';
      case UserRole.certifier:
        return 'Può emettere e gestire certificazioni';
      case UserRole.manager:
        return 'Gestione operativa e supervisione';
      case UserRole.operator:
        return 'Operazioni quotidiane e inserimento dati';
      case UserRole.viewer:
        return 'Solo visualizzazione, nessuna modifica';
      case UserRole.legalRepresentative:
        return 'Rappresentante legale dell\'azienda';
      case UserRole.technicalManager:
        return 'Responsabile degli aspetti tecnici';
      case UserRole.qualityManager:
        return 'Gestione sistemi qualità';
      case UserRole.safetyManager:
        return 'Responsabile sicurezza e conformità';
      case UserRole.hrManager:
        return 'Gestione risorse umane';
    }
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.admin:
        return [
          'create_users',
          'edit_users',
          'delete_users',
          'manage_certifications',
          'manage_legal_entities',
          'view_all_data',
          'export_data',
          'manage_settings',
        ];
      case UserRole.certifier:
        return [
          'create_certifications',
          'edit_certifications',
          'approve_certifications',
          'reject_certifications',
          'view_certifications',
        ];
      case UserRole.manager:
        return [
          'create_users',
          'edit_users',
          'view_all_data',
          'manage_certifications',
          'export_data',
        ];
      case UserRole.operator:
        return [
          'create_certifications',
          'edit_own_certifications',
          'view_own_data',
        ];
      case UserRole.viewer:
        return ['view_own_data', 'view_certifications'];
      case UserRole.legalRepresentative:
        return [
          'view_all_data',
          'manage_legal_entities',
          'approve_contracts',
          'sign_documents',
        ];
      case UserRole.technicalManager:
        return [
          'manage_certifications',
          'view_technical_data',
          'approve_technical_certifications',
        ];
      case UserRole.qualityManager:
        return [
          'manage_quality_certifications',
          'view_quality_data',
          'create_quality_reports',
        ];
      case UserRole.safetyManager:
        return [
          'manage_safety_certifications',
          'view_safety_data',
          'create_safety_reports',
        ];
      case UserRole.hrManager:
        return [
          'create_users',
          'edit_users',
          'view_user_data',
          'manage_user_roles',
        ];
    }
  }
}

class AppUser {
  final String idUser;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? profilePicture;
  final UserType? type;
  final String? fullName;
  final bool hasWallet;
  final String? idWallet;
  final bool hasCv;
  final String? idCv;
  final String idUserHash;
  final bool profileCompleted;
  final String? languageCode;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? countryCode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.idUser,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profilePicture,
    this.type,
    this.fullName,
    this.hasWallet = false,
    this.idWallet,
    this.hasCv = false,
    this.idCv,
    required this.idUserHash,
    this.profileCompleted = false,
    this.languageCode,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.countryCode,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      idUser: json['idUser'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      type: json['type'] != null ? _parseUserType(json['type']) : null,
      fullName: json['fullName'],
      hasWallet: json['hasWallet'] ?? false,
      idWallet: json['idWallet'],
      hasCv: json['hasCv'] ?? false,
      idCv: json['idCv'],
      idUserHash: json['idUserHash'],
      profileCompleted: json['profileCompleted'] ?? false,
      languageCode: json['languageCode'],
      gender: json['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.toString().split('.').last == json['gender'],
              orElse: () => Gender.preferNotToSay,
            )
          : null,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      countryCode: json['countryCode'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'type': type != null ? _userTypeToDatabaseValue(type!) : null,
      'fullName': fullName,
      'hasWallet': hasWallet,
      'idWallet': idWallet,
      'hasCv': hasCv,
      'idCv': idCv,
      'idUserHash': idUserHash,
      'profileCompleted': profileCompleted,
      'languageCode': languageCode,
      'gender': gender?.toString().split('.').last,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'countryCode': countryCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Metodo helper per convertire UserType in valore per il database
  static String _userTypeToDatabaseValue(UserType type) {
    switch (type) {
      case UserType.admin:
        return 'admin';
      case UserType.user:
        return 'user';
      case UserType.certifier:
        return 'certifier';
      case UserType.manager:
        return 'manager';
      case UserType.operator:
        return 'operator';
      case UserType.viewer:
        return 'viewer';
      case UserType.legalRepresentative:
        return 'legal_representative';
      case UserType.technicalManager:
        return 'technical_manager';
      case UserType.qualityManager:
        return 'quality_manager';
      case UserType.safetyManager:
        return 'safety_manager';
      case UserType.hrManager:
        return 'hr_manager';
    }
  }

  // Metodo helper per parsare UserType dal database
  static UserType _parseUserType(dynamic value) {
    if (value == null) return UserType.user;

    final String stringValue = value.toString().toLowerCase();

    // Mappatura dei valori del database ai valori dell'enum
    switch (stringValue) {
      case 'admin':
      case 'administrator':
        return UserType.admin;
      case 'user':
      case 'individual':
      case 'standard':
        return UserType.user;
      case 'certifier':
      case 'certificatore':
        return UserType.certifier;
      case 'manager':
      case 'management':
        return UserType.manager;
      case 'operator':
      case 'operatore':
        return UserType.operator;
      case 'viewer':
      case 'visualizzatore':
        return UserType.viewer;
      case 'legal_representative':
      case 'legalrepresentative':
      case 'rappresentante_legale':
        return UserType.legalRepresentative;
      case 'technical_manager':
      case 'technicalmanager':
      case 'responsabile_tecnico':
        return UserType.technicalManager;
      case 'quality_manager':
      case 'qualitymanager':
      case 'responsabile_qualita':
        return UserType.qualityManager;
      case 'safety_manager':
      case 'safetymanager':
      case 'responsabile_sicurezza':
        return UserType.safetyManager;
      case 'hr_manager':
      case 'hrmanager':
      case 'responsabile_hr':
        return UserType.hrManager;
      default:
        print(
          'Warning: Unknown UserType value: $value, defaulting to UserType.user',
        );
        return UserType.user;
    }
  }

  AppUser copyWith({
    String? idUser,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profilePicture,
    UserType? type,
    String? fullName,
    bool? hasWallet,
    String? idWallet,
    bool? hasCv,
    String? idCv,
    String? idUserHash,
    bool? profileCompleted,
    String? languageCode,
    Gender? gender,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? countryCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      idUser: idUser ?? this.idUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      type: type ?? this.type,
      fullName: fullName ?? this.fullName,
      hasWallet: hasWallet ?? this.hasWallet,
      idWallet: idWallet ?? this.idWallet,
      hasCv: hasCv ?? this.hasCv,
      idCv: idCv ?? this.idCv,
      idUserHash: idUserHash ?? this.idUserHash,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      languageCode: languageCode ?? this.languageCode,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else if (fullName != null) {
      return fullName!;
    } else {
      return 'Utente';
    }
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0].toUpperCase()}${lastName![0].toUpperCase()}';
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    } else if (lastName != null) {
      return lastName![0].toUpperCase();
    } else {
      return 'U';
    }
  }

  bool get isProfileComplete {
    return firstName != null &&
        lastName != null &&
        phone != null &&
        address != null &&
        city != null &&
        countryCode != null;
  }

  bool get isAdmin => type == UserType.admin;
  bool get isUser => type == UserType.user;
  bool get hasWalletAccess => this.hasWallet;
  bool get hasCvAccess => this.hasCv;
  bool get isProfileCompleted => profileCompleted;

  String get roleDisplayName {
    if (type != null) {
      return _getUserTypeDisplayName(type!);
    }
    return 'Utente';
  }

  String _getUserTypeDisplayName(UserType type) {
    switch (type) {
      case UserType.admin:
        return 'Amministratore';
      case UserType.user:
        return 'Utente';
      case UserType.certifier:
        return 'Certificatore';
      case UserType.manager:
        return 'Manager';
      case UserType.operator:
        return 'Operatore';
      case UserType.viewer:
        return 'Visualizzatore';
      case UserType.legalRepresentative:
        return 'Rappresentante Legale';
      case UserType.technicalManager:
        return 'Responsabile Tecnico';
      case UserType.qualityManager:
        return 'Responsabile Qualità';
      case UserType.safetyManager:
        return 'Responsabile Sicurezza';
      case UserType.hrManager:
        return 'Responsabile HR';
    }
  }
}
