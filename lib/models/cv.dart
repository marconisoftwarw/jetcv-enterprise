import 'package:uuid/uuid.dart';

class CV {
  final String idCv;
  final String idUser;
  final String idWallet;
  final String? nftTokenId;
  final String? nftMintTransactionUrl;
  final String? nftMintTransactionHash;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? firstName;
  final String? firstNameHash;
  final String? lastName;
  final String? lastNameHash;
  final String? email;
  final String? emailHash;
  final String? phone;
  final String? phoneHash;
  final String? dateOfBirth;
  final String? dateOfBirthHash;
  final String? address;
  final String? addressHash;
  final String? city;
  final String? cityHash;
  final String? state;
  final String? stateHash;
  final String? postalCode;
  final String? postalCodeHash;
  final String? countryCode;
  final String? countryCodeHash;
  final String? profilePicture;
  final String? profilePictureHash;
  final String? gender;
  final String? genderHash;
  final String? ipfsCid;
  final String? ipfsUrl;
  final String? idCvHash;
  final String? firstNameSalt;
  final String? lastNameSalt;
  final String? emailSalt;
  final String? phoneSalt;
  final String? dateOfBirthSalt;
  final String? addressSalt;
  final String? citySalt;
  final String? stateSalt;
  final String? postalCodeSalt;
  final String? countryCodeSalt;
  final String? profilePictureSalt;
  final String? genderSalt;
  final String? publicId;
  final String serialNumber;

  CV({
    String? idCv,
    required this.idUser,
    required this.idWallet,
    this.nftTokenId,
    this.nftMintTransactionUrl,
    this.nftMintTransactionHash,
    DateTime? createdAt,
    this.updatedAt,
    this.firstName,
    this.firstNameHash,
    this.lastName,
    this.lastNameHash,
    this.email,
    this.emailHash,
    this.phone,
    this.phoneHash,
    this.dateOfBirth,
    this.dateOfBirthHash,
    this.address,
    this.addressHash,
    this.city,
    this.cityHash,
    this.state,
    this.stateHash,
    this.postalCode,
    this.postalCodeHash,
    this.countryCode,
    this.countryCodeHash,
    this.profilePicture,
    this.profilePictureHash,
    this.gender,
    this.genderHash,
    this.ipfsCid,
    this.ipfsUrl,
    this.idCvHash,
    this.firstNameSalt,
    this.lastNameSalt,
    this.emailSalt,
    this.phoneSalt,
    this.dateOfBirthSalt,
    this.addressSalt,
    this.citySalt,
    this.stateSalt,
    this.postalCodeSalt,
    this.countryCodeSalt,
    this.profilePictureSalt,
    this.genderSalt,
    this.publicId,
    String? serialNumber,
  }) : idCv = idCv ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       serialNumber =
           serialNumber ?? 'CV-${DateTime.now().millisecondsSinceEpoch}';

  factory CV.fromJson(Map<String, dynamic> json) {
    return CV(
      idCv: json['idCv'],
      idUser: json['idUser'],
      idWallet: json['idWallet'],
      nftTokenId: json['nftTokenId'],
      nftMintTransactionUrl: json['nftMintTransactionUrl'],
      nftMintTransactionHash: json['nftMintTransactionHash'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      firstName: json['firstName'],
      firstNameHash: json['firstNameHash'],
      lastName: json['lastName'],
      lastNameHash: json['lastNameHash'],
      email: json['email'],
      emailHash: json['emailHash'],
      phone: json['phone'],
      phoneHash: json['phoneHash'],
      dateOfBirth: json['dateOfBirth'],
      dateOfBirthHash: json['dateOfBirthHash'],
      address: json['address'],
      addressHash: json['addressHash'],
      city: json['city'],
      cityHash: json['cityHash'],
      state: json['state'],
      stateHash: json['stateHash'],
      postalCode: json['postalCode'],
      postalCodeHash: json['postalCodeHash'],
      countryCode: json['countryCode'],
      countryCodeHash: json['countryCodeHash'],
      profilePicture: json['profilePicture'],
      profilePictureHash: json['profilePictureHash'],
      gender: json['gender'],
      genderHash: json['genderHash'],
      ipfsCid: json['ipfsCid'],
      ipfsUrl: json['ipfsUrl'],
      idCvHash: json['idCvHash'],
      firstNameSalt: json['firstNameSalt'],
      lastNameSalt: json['lastNameSalt'],
      emailSalt: json['emailSalt'],
      phoneSalt: json['phoneSalt'],
      dateOfBirthSalt: json['dateOfBirthSalt'],
      addressSalt: json['addressSalt'],
      citySalt: json['citySalt'],
      stateSalt: json['stateSalt'],
      postalCodeSalt: json['postalCodeSalt'],
      countryCodeSalt: json['countryCodeSalt'],
      profilePictureSalt: json['profilePictureSalt'],
      genderSalt: json['genderSalt'],
      publicId: json['publicId'],
      serialNumber: json['serialNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCv': idCv,
      'idUser': idUser,
      'idWallet': idWallet,
      'nftTokenId': nftTokenId,
      'nftMintTransactionUrl': nftMintTransactionUrl,
      'nftMintTransactionHash': nftMintTransactionHash,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'firstName': firstName,
      'firstNameHash': firstNameHash,
      'lastName': lastName,
      'lastNameHash': lastNameHash,
      'email': email,
      'emailHash': emailHash,
      'phone': phone,
      'phoneHash': phoneHash,
      'dateOfBirth': dateOfBirth,
      'dateOfBirthHash': dateOfBirthHash,
      'address': address,
      'addressHash': addressHash,
      'city': city,
      'cityHash': cityHash,
      'state': state,
      'stateHash': stateHash,
      'postalCode': postalCode,
      'postalCodeHash': postalCodeHash,
      'countryCode': countryCode,
      'countryCodeHash': countryCodeHash,
      'profilePicture': profilePicture,
      'profilePictureHash': profilePictureHash,
      'gender': gender,
      'genderHash': genderHash,
      'ipfsCid': ipfsCid,
      'ipfsUrl': ipfsUrl,
      'idCvHash': idCvHash,
      'firstNameSalt': firstNameSalt,
      'lastNameSalt': lastNameSalt,
      'emailSalt': emailSalt,
      'phoneSalt': phoneSalt,
      'dateOfBirthSalt': dateOfBirthSalt,
      'addressSalt': addressSalt,
      'citySalt': citySalt,
      'stateSalt': stateSalt,
      'postalCodeSalt': postalCodeSalt,
      'countryCodeSalt': countryCodeSalt,
      'profilePictureSalt': profilePictureSalt,
      'genderSalt': genderSalt,
      'publicId': publicId,
      'serialNumber': serialNumber,
    };
  }

  CV copyWith({
    String? idCv,
    String? idUser,
    String? idWallet,
    String? nftTokenId,
    String? nftMintTransactionUrl,
    String? nftMintTransactionHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstName,
    String? firstNameHash,
    String? lastName,
    String? lastNameHash,
    String? email,
    String? emailHash,
    String? phone,
    String? phoneHash,
    String? dateOfBirth,
    String? dateOfBirthHash,
    String? address,
    String? addressHash,
    String? city,
    String? cityHash,
    String? state,
    String? stateHash,
    String? postalCode,
    String? postalCodeHash,
    String? countryCode,
    String? countryCodeHash,
    String? profilePicture,
    String? profilePictureHash,
    String? gender,
    String? genderHash,
    String? ipfsCid,
    String? ipfsUrl,
    String? idCvHash,
    String? firstNameSalt,
    String? lastNameSalt,
    String? emailSalt,
    String? phoneSalt,
    String? dateOfBirthSalt,
    String? addressSalt,
    String? citySalt,
    String? stateSalt,
    String? postalCodeSalt,
    String? countryCodeSalt,
    String? profilePictureSalt,
    String? genderSalt,
    String? publicId,
    String? serialNumber,
  }) {
    return CV(
      idCv: idCv ?? this.idCv,
      idUser: idUser ?? this.idUser,
      idWallet: idWallet ?? this.idWallet,
      nftTokenId: nftTokenId ?? this.nftTokenId,
      nftMintTransactionUrl:
          nftMintTransactionUrl ?? this.nftMintTransactionUrl,
      nftMintTransactionHash:
          nftMintTransactionHash ?? this.nftMintTransactionHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      firstNameHash: firstNameHash ?? this.firstNameHash,
      lastName: lastName ?? this.lastName,
      lastNameHash: lastNameHash ?? this.lastNameHash,
      email: email ?? this.email,
      emailHash: emailHash ?? this.emailHash,
      phone: phone ?? this.phone,
      phoneHash: phoneHash ?? this.phoneHash,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfBirthHash: dateOfBirthHash ?? this.dateOfBirthHash,
      address: address ?? this.address,
      addressHash: addressHash ?? this.addressHash,
      city: city ?? this.city,
      cityHash: cityHash ?? this.cityHash,
      state: state ?? this.state,
      stateHash: stateHash ?? this.stateHash,
      postalCode: postalCode ?? this.postalCode,
      postalCodeHash: postalCodeHash ?? this.postalCodeHash,
      countryCode: countryCode ?? this.countryCode,
      countryCodeHash: countryCodeHash ?? this.countryCodeHash,
      profilePicture: profilePicture ?? this.profilePicture,
      profilePictureHash: profilePictureHash ?? this.profilePictureHash,
      gender: gender ?? this.gender,
      genderHash: genderHash ?? this.genderHash,
      ipfsCid: ipfsCid ?? this.ipfsCid,
      ipfsUrl: ipfsUrl ?? this.ipfsUrl,
      idCvHash: idCvHash ?? this.idCvHash,
      firstNameSalt: firstNameSalt ?? this.firstNameSalt,
      lastNameSalt: lastNameSalt ?? this.lastNameSalt,
      emailSalt: emailSalt ?? this.emailSalt,
      phoneSalt: phoneSalt ?? this.phoneSalt,
      dateOfBirthSalt: dateOfBirthSalt ?? this.dateOfBirthSalt,
      addressSalt: addressSalt ?? this.addressSalt,
      citySalt: citySalt ?? this.citySalt,
      stateSalt: stateSalt ?? this.stateSalt,
      postalCodeSalt: postalCodeSalt ?? this.postalCodeSalt,
      countryCodeSalt: countryCodeSalt ?? this.countryCodeSalt,
      profilePictureSalt: profilePictureSalt ?? this.profilePictureSalt,
      genderSalt: genderSalt ?? this.genderSalt,
      publicId: publicId ?? this.publicId,
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }

  // Getters per la compatibilità con l'UI
  String get displayName {
    final firstName = this.firstName ?? '';
    final lastName = this.lastName ?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }
    return 'Nome non specificato';
  }

  String get initials {
    final firstName = this.firstName ?? '';
    final lastName = this.lastName ?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    }
    return '?';
  }

  String get displayLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (countryCode != null && countryCode!.isNotEmpty) parts.add(countryCode!);

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    return 'Località non specificata';
  }

  String get displayContact {
    if (email != null && email!.isNotEmpty) {
      return email!;
    } else if (phone != null && phone!.isNotEmpty) {
      return phone!;
    }
    return 'Contatto non disponibile';
  }

  bool get hasProfilePicture =>
      profilePicture != null && profilePicture!.isNotEmpty;
  bool get isVerified => nftTokenId != null && nftTokenId!.isNotEmpty;
  bool get hasWallet => idWallet.isNotEmpty;
}
