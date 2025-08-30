// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserStruct extends BaseStruct {
  UserStruct({
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
    UserGender? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    UserType? type,
    bool? hasWallet,
    String? idWallet,
    bool? hasCv,
    String? idCv,
    String? idUserHash,
    bool? profileCompleted,
    bool? kycCompleted,
    bool? kycPassed,
  })  : _idUser = idUser,
        _firstName = firstName,
        _lastName = lastName,
        _email = email,
        _phone = phone,
        _dateOfBirth = dateOfBirth,
        _address = address,
        _city = city,
        _state = state,
        _postalCode = postalCode,
        _countryCode = countryCode,
        _profilePicture = profilePicture,
        _gender = gender,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _fullName = fullName,
        _type = type,
        _hasWallet = hasWallet,
        _idWallet = idWallet,
        _hasCv = hasCv,
        _idCv = idCv,
        _idUserHash = idUserHash,
        _profileCompleted = profileCompleted,
        _kycCompleted = kycCompleted,
        _kycPassed = kycPassed;

  // "idUser" field.
  String? _idUser;
  String get idUser => _idUser ?? '';
  set idUser(String? val) => _idUser = val;

  bool hasIdUser() => _idUser != null;

  // "firstName" field.
  String? _firstName;
  String get firstName => _firstName ?? '';
  set firstName(String? val) => _firstName = val;

  bool hasFirstName() => _firstName != null;

  // "lastName" field.
  String? _lastName;
  String get lastName => _lastName ?? '';
  set lastName(String? val) => _lastName = val;

  bool hasLastName() => _lastName != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  set phone(String? val) => _phone = val;

  bool hasPhone() => _phone != null;

  // "dateOfBirth" field.
  DateTime? _dateOfBirth;
  DateTime? get dateOfBirth => _dateOfBirth;
  set dateOfBirth(DateTime? val) => _dateOfBirth = val;

  bool hasDateOfBirth() => _dateOfBirth != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  set address(String? val) => _address = val;

  bool hasAddress() => _address != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  set city(String? val) => _city = val;

  bool hasCity() => _city != null;

  // "state" field.
  String? _state;
  String get state => _state ?? '';
  set state(String? val) => _state = val;

  bool hasState() => _state != null;

  // "postalCode" field.
  String? _postalCode;
  String get postalCode => _postalCode ?? '';
  set postalCode(String? val) => _postalCode = val;

  bool hasPostalCode() => _postalCode != null;

  // "countryCode" field.
  String? _countryCode;
  String get countryCode => _countryCode ?? '';
  set countryCode(String? val) => _countryCode = val;

  bool hasCountryCode() => _countryCode != null;

  // "profilePicture" field.
  String? _profilePicture;
  String get profilePicture => _profilePicture ?? '';
  set profilePicture(String? val) => _profilePicture = val;

  bool hasProfilePicture() => _profilePicture != null;

  // "gender" field.
  UserGender? _gender;
  UserGender? get gender => _gender;
  set gender(UserGender? val) => _gender = val;

  bool hasGender() => _gender != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  set updatedAt(DateTime? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "type" field.
  UserType? _type;
  UserType? get type => _type;
  set type(UserType? val) => _type = val;

  bool hasType() => _type != null;

  // "hasWallet" field.
  bool? _hasWallet;
  bool get hasWallet => _hasWallet ?? false;
  set hasWallet(bool? val) => _hasWallet = val;

  bool hasHasWallet() => _hasWallet != null;

  // "idWallet" field.
  String? _idWallet;
  String get idWallet => _idWallet ?? '';
  set idWallet(String? val) => _idWallet = val;

  bool hasIdWallet() => _idWallet != null;

  // "hasCv" field.
  bool? _hasCv;
  bool get hasCv => _hasCv ?? false;
  set hasCv(bool? val) => _hasCv = val;

  bool hasHasCv() => _hasCv != null;

  // "idCv" field.
  String? _idCv;
  String get idCv => _idCv ?? '';
  set idCv(String? val) => _idCv = val;

  bool hasIdCv() => _idCv != null;

  // "idUserHash" field.
  String? _idUserHash;
  String get idUserHash => _idUserHash ?? '';
  set idUserHash(String? val) => _idUserHash = val;

  bool hasIdUserHash() => _idUserHash != null;

  // "profileCompleted" field.
  bool? _profileCompleted;
  bool get profileCompleted => _profileCompleted ?? false;
  set profileCompleted(bool? val) => _profileCompleted = val;

  bool hasProfileCompleted() => _profileCompleted != null;

  // "kycCompleted" field.
  bool? _kycCompleted;
  bool get kycCompleted => _kycCompleted ?? false;
  set kycCompleted(bool? val) => _kycCompleted = val;

  bool hasKycCompleted() => _kycCompleted != null;

  // "kycPassed" field.
  bool? _kycPassed;
  bool get kycPassed => _kycPassed ?? false;
  set kycPassed(bool? val) => _kycPassed = val;

  bool hasKycPassed() => _kycPassed != null;

  static UserStruct fromMap(Map<String, dynamic> data) => UserStruct(
        idUser: data['idUser'] as String?,
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        dateOfBirth: data['dateOfBirth'] as DateTime?,
        address: data['address'] as String?,
        city: data['city'] as String?,
        state: data['state'] as String?,
        postalCode: data['postalCode'] as String?,
        countryCode: data['countryCode'] as String?,
        profilePicture: data['profilePicture'] as String?,
        gender: data['gender'] is UserGender
            ? data['gender']
            : deserializeEnum<UserGender>(data['gender']),
        createdAt: data['createdAt'] as DateTime?,
        updatedAt: data['updatedAt'] as DateTime?,
        fullName: data['fullName'] as String?,
        type: data['type'] is UserType
            ? data['type']
            : deserializeEnum<UserType>(data['type']),
        hasWallet: data['hasWallet'] as bool?,
        idWallet: data['idWallet'] as String?,
        hasCv: data['hasCv'] as bool?,
        idCv: data['idCv'] as String?,
        idUserHash: data['idUserHash'] as String?,
        profileCompleted: data['profileCompleted'] as bool?,
        kycCompleted: data['kycCompleted'] as bool?,
        kycPassed: data['kycPassed'] as bool?,
      );

  static UserStruct? maybeFromMap(dynamic data) =>
      data is Map ? UserStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'idUser': _idUser,
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'phone': _phone,
        'dateOfBirth': _dateOfBirth,
        'address': _address,
        'city': _city,
        'state': _state,
        'postalCode': _postalCode,
        'countryCode': _countryCode,
        'profilePicture': _profilePicture,
        'gender': _gender?.serialize(),
        'createdAt': _createdAt,
        'updatedAt': _updatedAt,
        'fullName': _fullName,
        'type': _type?.serialize(),
        'hasWallet': _hasWallet,
        'idWallet': _idWallet,
        'hasCv': _hasCv,
        'idCv': _idCv,
        'idUserHash': _idUserHash,
        'profileCompleted': _profileCompleted,
        'kycCompleted': _kycCompleted,
        'kycPassed': _kycPassed,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'idUser': serializeParam(
          _idUser,
          ParamType.String,
        ),
        'firstName': serializeParam(
          _firstName,
          ParamType.String,
        ),
        'lastName': serializeParam(
          _lastName,
          ParamType.String,
        ),
        'email': serializeParam(
          _email,
          ParamType.String,
        ),
        'phone': serializeParam(
          _phone,
          ParamType.String,
        ),
        'dateOfBirth': serializeParam(
          _dateOfBirth,
          ParamType.DateTime,
        ),
        'address': serializeParam(
          _address,
          ParamType.String,
        ),
        'city': serializeParam(
          _city,
          ParamType.String,
        ),
        'state': serializeParam(
          _state,
          ParamType.String,
        ),
        'postalCode': serializeParam(
          _postalCode,
          ParamType.String,
        ),
        'countryCode': serializeParam(
          _countryCode,
          ParamType.String,
        ),
        'profilePicture': serializeParam(
          _profilePicture,
          ParamType.String,
        ),
        'gender': serializeParam(
          _gender,
          ParamType.Enum,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
        'updatedAt': serializeParam(
          _updatedAt,
          ParamType.DateTime,
        ),
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'type': serializeParam(
          _type,
          ParamType.Enum,
        ),
        'hasWallet': serializeParam(
          _hasWallet,
          ParamType.bool,
        ),
        'idWallet': serializeParam(
          _idWallet,
          ParamType.String,
        ),
        'hasCv': serializeParam(
          _hasCv,
          ParamType.bool,
        ),
        'idCv': serializeParam(
          _idCv,
          ParamType.String,
        ),
        'idUserHash': serializeParam(
          _idUserHash,
          ParamType.String,
        ),
        'profileCompleted': serializeParam(
          _profileCompleted,
          ParamType.bool,
        ),
        'kycCompleted': serializeParam(
          _kycCompleted,
          ParamType.bool,
        ),
        'kycPassed': serializeParam(
          _kycPassed,
          ParamType.bool,
        ),
      }.withoutNulls;

  static UserStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserStruct(
        idUser: deserializeParam(
          data['idUser'],
          ParamType.String,
          false,
        ),
        firstName: deserializeParam(
          data['firstName'],
          ParamType.String,
          false,
        ),
        lastName: deserializeParam(
          data['lastName'],
          ParamType.String,
          false,
        ),
        email: deserializeParam(
          data['email'],
          ParamType.String,
          false,
        ),
        phone: deserializeParam(
          data['phone'],
          ParamType.String,
          false,
        ),
        dateOfBirth: deserializeParam(
          data['dateOfBirth'],
          ParamType.DateTime,
          false,
        ),
        address: deserializeParam(
          data['address'],
          ParamType.String,
          false,
        ),
        city: deserializeParam(
          data['city'],
          ParamType.String,
          false,
        ),
        state: deserializeParam(
          data['state'],
          ParamType.String,
          false,
        ),
        postalCode: deserializeParam(
          data['postalCode'],
          ParamType.String,
          false,
        ),
        countryCode: deserializeParam(
          data['countryCode'],
          ParamType.String,
          false,
        ),
        profilePicture: deserializeParam(
          data['profilePicture'],
          ParamType.String,
          false,
        ),
        gender: deserializeParam<UserGender>(
          data['gender'],
          ParamType.Enum,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.DateTime,
          false,
        ),
        updatedAt: deserializeParam(
          data['updatedAt'],
          ParamType.DateTime,
          false,
        ),
        fullName: deserializeParam(
          data['fullName'],
          ParamType.String,
          false,
        ),
        type: deserializeParam<UserType>(
          data['type'],
          ParamType.Enum,
          false,
        ),
        hasWallet: deserializeParam(
          data['hasWallet'],
          ParamType.bool,
          false,
        ),
        idWallet: deserializeParam(
          data['idWallet'],
          ParamType.String,
          false,
        ),
        hasCv: deserializeParam(
          data['hasCv'],
          ParamType.bool,
          false,
        ),
        idCv: deserializeParam(
          data['idCv'],
          ParamType.String,
          false,
        ),
        idUserHash: deserializeParam(
          data['idUserHash'],
          ParamType.String,
          false,
        ),
        profileCompleted: deserializeParam(
          data['profileCompleted'],
          ParamType.bool,
          false,
        ),
        kycCompleted: deserializeParam(
          data['kycCompleted'],
          ParamType.bool,
          false,
        ),
        kycPassed: deserializeParam(
          data['kycPassed'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'UserStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserStruct &&
        idUser == other.idUser &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        email == other.email &&
        phone == other.phone &&
        dateOfBirth == other.dateOfBirth &&
        address == other.address &&
        city == other.city &&
        state == other.state &&
        postalCode == other.postalCode &&
        countryCode == other.countryCode &&
        profilePicture == other.profilePicture &&
        gender == other.gender &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        fullName == other.fullName &&
        type == other.type &&
        hasWallet == other.hasWallet &&
        idWallet == other.idWallet &&
        hasCv == other.hasCv &&
        idCv == other.idCv &&
        idUserHash == other.idUserHash &&
        profileCompleted == other.profileCompleted &&
        kycCompleted == other.kycCompleted &&
        kycPassed == other.kycPassed;
  }

  @override
  int get hashCode => const ListEquality().hash([
        idUser,
        firstName,
        lastName,
        email,
        phone,
        dateOfBirth,
        address,
        city,
        state,
        postalCode,
        countryCode,
        profilePicture,
        gender,
        createdAt,
        updatedAt,
        fullName,
        type,
        hasWallet,
        idWallet,
        hasCv,
        idCv,
        idUserHash,
        profileCompleted,
        kycCompleted,
        kycPassed
      ]);
}

UserStruct createUserStruct({
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
  UserGender? gender,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? fullName,
  UserType? type,
  bool? hasWallet,
  String? idWallet,
  bool? hasCv,
  String? idCv,
  String? idUserHash,
  bool? profileCompleted,
  bool? kycCompleted,
  bool? kycPassed,
}) =>
    UserStruct(
      idUser: idUser,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      address: address,
      city: city,
      state: state,
      postalCode: postalCode,
      countryCode: countryCode,
      profilePicture: profilePicture,
      gender: gender,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fullName: fullName,
      type: type,
      hasWallet: hasWallet,
      idWallet: idWallet,
      hasCv: hasCv,
      idCv: idCv,
      idUserHash: idUserHash,
      profileCompleted: profileCompleted,
      kycCompleted: kycCompleted,
      kycPassed: kycPassed,
    );
