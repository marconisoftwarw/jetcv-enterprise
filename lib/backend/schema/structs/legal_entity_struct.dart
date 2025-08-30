// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LegalEntityStruct extends BaseStruct {
  LegalEntityStruct({
    String? idLegalEntity,
    String? idLegalEntityHash,
    String? legalName,
    String? identifierCode,
    String? operationalAddress,
    String? headquartersAddress,
    String? legalRepresentative,
    String? email,
    String? phone,
    String? pec,
    String? website,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? statusUpdatedAt,
    String? statusUpdatedByIdUser,
    String? requestingIdUser,
    LegalEntityStatus? status,

    /// logoPictureUrl
    String? logoPictureUrl,

    /// companyPictureUrl
    String? companyPictureUrl,
  })  : _idLegalEntity = idLegalEntity,
        _idLegalEntityHash = idLegalEntityHash,
        _legalName = legalName,
        _identifierCode = identifierCode,
        _operationalAddress = operationalAddress,
        _headquartersAddress = headquartersAddress,
        _legalRepresentative = legalRepresentative,
        _email = email,
        _phone = phone,
        _pec = pec,
        _website = website,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _statusUpdatedAt = statusUpdatedAt,
        _statusUpdatedByIdUser = statusUpdatedByIdUser,
        _requestingIdUser = requestingIdUser,
        _status = status,
        _logoPictureUrl = logoPictureUrl,
        _companyPictureUrl = companyPictureUrl;

  // "idLegalEntity" field.
  String? _idLegalEntity;
  String get idLegalEntity => _idLegalEntity ?? '';
  set idLegalEntity(String? val) => _idLegalEntity = val;

  bool hasIdLegalEntity() => _idLegalEntity != null;

  // "idLegalEntityHash" field.
  String? _idLegalEntityHash;
  String get idLegalEntityHash => _idLegalEntityHash ?? '';
  set idLegalEntityHash(String? val) => _idLegalEntityHash = val;

  bool hasIdLegalEntityHash() => _idLegalEntityHash != null;

  // "legalName" field.
  String? _legalName;
  String get legalName => _legalName ?? '';
  set legalName(String? val) => _legalName = val;

  bool hasLegalName() => _legalName != null;

  // "identifierCode" field.
  String? _identifierCode;
  String get identifierCode => _identifierCode ?? '';
  set identifierCode(String? val) => _identifierCode = val;

  bool hasIdentifierCode() => _identifierCode != null;

  // "operationalAddress" field.
  String? _operationalAddress;
  String get operationalAddress => _operationalAddress ?? '';
  set operationalAddress(String? val) => _operationalAddress = val;

  bool hasOperationalAddress() => _operationalAddress != null;

  // "headquartersAddress" field.
  String? _headquartersAddress;
  String get headquartersAddress => _headquartersAddress ?? '';
  set headquartersAddress(String? val) => _headquartersAddress = val;

  bool hasHeadquartersAddress() => _headquartersAddress != null;

  // "legalRepresentative" field.
  String? _legalRepresentative;
  String get legalRepresentative => _legalRepresentative ?? '';
  set legalRepresentative(String? val) => _legalRepresentative = val;

  bool hasLegalRepresentative() => _legalRepresentative != null;

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

  // "pec" field.
  String? _pec;
  String get pec => _pec ?? '';
  set pec(String? val) => _pec = val;

  bool hasPec() => _pec != null;

  // "website" field.
  String? _website;
  String get website => _website ?? '';
  set website(String? val) => _website = val;

  bool hasWebsite() => _website != null;

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

  // "statusUpdatedAt" field.
  DateTime? _statusUpdatedAt;
  DateTime? get statusUpdatedAt => _statusUpdatedAt;
  set statusUpdatedAt(DateTime? val) => _statusUpdatedAt = val;

  bool hasStatusUpdatedAt() => _statusUpdatedAt != null;

  // "statusUpdatedByIdUser" field.
  String? _statusUpdatedByIdUser;
  String get statusUpdatedByIdUser => _statusUpdatedByIdUser ?? '';
  set statusUpdatedByIdUser(String? val) => _statusUpdatedByIdUser = val;

  bool hasStatusUpdatedByIdUser() => _statusUpdatedByIdUser != null;

  // "requestingIdUser" field.
  String? _requestingIdUser;
  String get requestingIdUser => _requestingIdUser ?? '';
  set requestingIdUser(String? val) => _requestingIdUser = val;

  bool hasRequestingIdUser() => _requestingIdUser != null;

  // "status" field.
  LegalEntityStatus? _status;
  LegalEntityStatus? get status => _status;
  set status(LegalEntityStatus? val) => _status = val;

  bool hasStatus() => _status != null;

  // "logoPictureUrl" field.
  String? _logoPictureUrl;
  String get logoPictureUrl => _logoPictureUrl ?? '';
  set logoPictureUrl(String? val) => _logoPictureUrl = val;

  bool hasLogoPictureUrl() => _logoPictureUrl != null;

  // "companyPictureUrl" field.
  String? _companyPictureUrl;
  String get companyPictureUrl => _companyPictureUrl ?? '';
  set companyPictureUrl(String? val) => _companyPictureUrl = val;

  bool hasCompanyPictureUrl() => _companyPictureUrl != null;

  static LegalEntityStruct fromMap(Map<String, dynamic> data) =>
      LegalEntityStruct(
        idLegalEntity: data['idLegalEntity'] as String?,
        idLegalEntityHash: data['idLegalEntityHash'] as String?,
        legalName: data['legalName'] as String?,
        identifierCode: data['identifierCode'] as String?,
        operationalAddress: data['operationalAddress'] as String?,
        headquartersAddress: data['headquartersAddress'] as String?,
        legalRepresentative: data['legalRepresentative'] as String?,
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        pec: data['pec'] as String?,
        website: data['website'] as String?,
        createdAt: data['createdAt'] as DateTime?,
        updatedAt: data['updatedAt'] as DateTime?,
        statusUpdatedAt: data['statusUpdatedAt'] as DateTime?,
        statusUpdatedByIdUser: data['statusUpdatedByIdUser'] as String?,
        requestingIdUser: data['requestingIdUser'] as String?,
        status: data['status'] is LegalEntityStatus
            ? data['status']
            : deserializeEnum<LegalEntityStatus>(data['status']),
        logoPictureUrl: data['logoPictureUrl'] as String?,
        companyPictureUrl: data['companyPictureUrl'] as String?,
      );

  static LegalEntityStruct? maybeFromMap(dynamic data) => data is Map
      ? LegalEntityStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'idLegalEntity': _idLegalEntity,
        'idLegalEntityHash': _idLegalEntityHash,
        'legalName': _legalName,
        'identifierCode': _identifierCode,
        'operationalAddress': _operationalAddress,
        'headquartersAddress': _headquartersAddress,
        'legalRepresentative': _legalRepresentative,
        'email': _email,
        'phone': _phone,
        'pec': _pec,
        'website': _website,
        'createdAt': _createdAt,
        'updatedAt': _updatedAt,
        'statusUpdatedAt': _statusUpdatedAt,
        'statusUpdatedByIdUser': _statusUpdatedByIdUser,
        'requestingIdUser': _requestingIdUser,
        'status': _status?.serialize(),
        'logoPictureUrl': _logoPictureUrl,
        'companyPictureUrl': _companyPictureUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'idLegalEntity': serializeParam(
          _idLegalEntity,
          ParamType.String,
        ),
        'idLegalEntityHash': serializeParam(
          _idLegalEntityHash,
          ParamType.String,
        ),
        'legalName': serializeParam(
          _legalName,
          ParamType.String,
        ),
        'identifierCode': serializeParam(
          _identifierCode,
          ParamType.String,
        ),
        'operationalAddress': serializeParam(
          _operationalAddress,
          ParamType.String,
        ),
        'headquartersAddress': serializeParam(
          _headquartersAddress,
          ParamType.String,
        ),
        'legalRepresentative': serializeParam(
          _legalRepresentative,
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
        'pec': serializeParam(
          _pec,
          ParamType.String,
        ),
        'website': serializeParam(
          _website,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
        'updatedAt': serializeParam(
          _updatedAt,
          ParamType.DateTime,
        ),
        'statusUpdatedAt': serializeParam(
          _statusUpdatedAt,
          ParamType.DateTime,
        ),
        'statusUpdatedByIdUser': serializeParam(
          _statusUpdatedByIdUser,
          ParamType.String,
        ),
        'requestingIdUser': serializeParam(
          _requestingIdUser,
          ParamType.String,
        ),
        'status': serializeParam(
          _status,
          ParamType.Enum,
        ),
        'logoPictureUrl': serializeParam(
          _logoPictureUrl,
          ParamType.String,
        ),
        'companyPictureUrl': serializeParam(
          _companyPictureUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static LegalEntityStruct fromSerializableMap(Map<String, dynamic> data) =>
      LegalEntityStruct(
        idLegalEntity: deserializeParam(
          data['idLegalEntity'],
          ParamType.String,
          false,
        ),
        idLegalEntityHash: deserializeParam(
          data['idLegalEntityHash'],
          ParamType.String,
          false,
        ),
        legalName: deserializeParam(
          data['legalName'],
          ParamType.String,
          false,
        ),
        identifierCode: deserializeParam(
          data['identifierCode'],
          ParamType.String,
          false,
        ),
        operationalAddress: deserializeParam(
          data['operationalAddress'],
          ParamType.String,
          false,
        ),
        headquartersAddress: deserializeParam(
          data['headquartersAddress'],
          ParamType.String,
          false,
        ),
        legalRepresentative: deserializeParam(
          data['legalRepresentative'],
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
        pec: deserializeParam(
          data['pec'],
          ParamType.String,
          false,
        ),
        website: deserializeParam(
          data['website'],
          ParamType.String,
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
        statusUpdatedAt: deserializeParam(
          data['statusUpdatedAt'],
          ParamType.DateTime,
          false,
        ),
        statusUpdatedByIdUser: deserializeParam(
          data['statusUpdatedByIdUser'],
          ParamType.String,
          false,
        ),
        requestingIdUser: deserializeParam(
          data['requestingIdUser'],
          ParamType.String,
          false,
        ),
        status: deserializeParam<LegalEntityStatus>(
          data['status'],
          ParamType.Enum,
          false,
        ),
        logoPictureUrl: deserializeParam(
          data['logoPictureUrl'],
          ParamType.String,
          false,
        ),
        companyPictureUrl: deserializeParam(
          data['companyPictureUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'LegalEntityStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LegalEntityStruct &&
        idLegalEntity == other.idLegalEntity &&
        idLegalEntityHash == other.idLegalEntityHash &&
        legalName == other.legalName &&
        identifierCode == other.identifierCode &&
        operationalAddress == other.operationalAddress &&
        headquartersAddress == other.headquartersAddress &&
        legalRepresentative == other.legalRepresentative &&
        email == other.email &&
        phone == other.phone &&
        pec == other.pec &&
        website == other.website &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        statusUpdatedAt == other.statusUpdatedAt &&
        statusUpdatedByIdUser == other.statusUpdatedByIdUser &&
        requestingIdUser == other.requestingIdUser &&
        status == other.status &&
        logoPictureUrl == other.logoPictureUrl &&
        companyPictureUrl == other.companyPictureUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([
        idLegalEntity,
        idLegalEntityHash,
        legalName,
        identifierCode,
        operationalAddress,
        headquartersAddress,
        legalRepresentative,
        email,
        phone,
        pec,
        website,
        createdAt,
        updatedAt,
        statusUpdatedAt,
        statusUpdatedByIdUser,
        requestingIdUser,
        status,
        logoPictureUrl,
        companyPictureUrl
      ]);
}

LegalEntityStruct createLegalEntityStruct({
  String? idLegalEntity,
  String? idLegalEntityHash,
  String? legalName,
  String? identifierCode,
  String? operationalAddress,
  String? headquartersAddress,
  String? legalRepresentative,
  String? email,
  String? phone,
  String? pec,
  String? website,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? statusUpdatedAt,
  String? statusUpdatedByIdUser,
  String? requestingIdUser,
  LegalEntityStatus? status,
  String? logoPictureUrl,
  String? companyPictureUrl,
}) =>
    LegalEntityStruct(
      idLegalEntity: idLegalEntity,
      idLegalEntityHash: idLegalEntityHash,
      legalName: legalName,
      identifierCode: identifierCode,
      operationalAddress: operationalAddress,
      headquartersAddress: headquartersAddress,
      legalRepresentative: legalRepresentative,
      email: email,
      phone: phone,
      pec: pec,
      website: website,
      createdAt: createdAt,
      updatedAt: updatedAt,
      statusUpdatedAt: statusUpdatedAt,
      statusUpdatedByIdUser: statusUpdatedByIdUser,
      requestingIdUser: requestingIdUser,
      status: status,
      logoPictureUrl: logoPictureUrl,
      companyPictureUrl: companyPictureUrl,
    );
