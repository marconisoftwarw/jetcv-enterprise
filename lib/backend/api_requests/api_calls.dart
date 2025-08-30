import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start Supabase Group Code

class SupabaseGroup {
  static String getBaseUrl({
    String? supabaseApiUrlCommon,
  }) {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    return '${supabaseApiUrlCommon}/functions/v1';
  }

  static Map<String, String> headers = {};
  static GetUserByIdCall getUserByIdCall = GetUserByIdCall();
  static GetCountriesCall getCountriesCall = GetCountriesCall();
  static UpdateUserProfileCall updateUserProfileCall = UpdateUserProfileCall();
  static GetLegalEntityCall getLegalEntityCall = GetLegalEntityCall();
  static UpdateLegalEntityCall updateLegalEntityCall = UpdateLegalEntityCall();
  static CreateLegalEntityCall createLegalEntityCall = CreateLegalEntityCall();
  static GetLegalEntitiesCall getLegalEntitiesCall = GetLegalEntitiesCall();
  static CreateAssociateUserWalletCall createAssociateUserWalletCall =
      CreateAssociateUserWalletCall();
  static CheckUserHasActiveCertifierCall checkUserHasActiveCertifierCall =
      CheckUserHasActiveCertifierCall();
  static GetUsersByIdsCall getUsersByIdsCall = GetUsersByIdsCall();
  static DeleteUserAndAssociatedDataCall deleteUserAndAssociatedDataCall =
      DeleteUserAndAssociatedDataCall();
  static CreateWalletCall createWalletCall = CreateWalletCall();
  static SessionRequestVeriffNewCall sessionRequestVeriffNewCall =
      SessionRequestVeriffNewCall();
  static CheckSessionVeriffCall checkSessionVeriffCall =
      CheckSessionVeriffCall();
  static CreateKycAttemptCall createKycAttemptCall = CreateKycAttemptCall();
  static UpdateKycVerificationCall updateKycVerificationCall =
      UpdateKycVerificationCall();
  static GetLastKycAttemptCall getLastKycAttemptCall = GetLastKycAttemptCall();
  static UpdateStatusLegalEntityCall updateStatusLegalEntityCall =
      UpdateStatusLegalEntityCall();
  static SyncimagefromjectcventerpriseCall syncimagefromjectcventerpriseCall =
      SyncimagefromjectcventerpriseCall();
  static CreateupdatelegalentityCall createupdatelegalentityCall =
      CreateupdatelegalentityCall();
}

class GetUserByIdCall {
  Future<ApiCallResponse> call({
    String? idUser = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'getUserById',
      apiUrl: '${baseUrl}/getUserById',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'idUser': idUser,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic user(dynamic response) => getJsonField(
        response,
        r'''$''',
      );
}

class GetCountriesCall {
  Future<ApiCallResponse> call({
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'getCountries',
      apiUrl: '${baseUrl}/getCountries',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateUserProfileCall {
  Future<ApiCallResponse> call({
    String? idUser = '',
    String? firstName = '',
    String? lastName = '',
    String? email = '',
    String? phone = '',
    String? dateOfBirth = '',
    String? address = '',
    String? city = '',
    String? state = '',
    String? postalCode = '',
    String? countryCode = '',
    String? profilePicture = '',
    String? gender = '',
    String? type = '',
    bool? kycCompleted,
    bool? kycPassed,
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idUser": "${escapeStringForJson(idUser)}",
  "firstName": "${escapeStringForJson(firstName)}",
  "lastName": "${escapeStringForJson(lastName)}",
  "email": "${escapeStringForJson(email)}",
  "phone": "${escapeStringForJson(phone)}",
  "dateOfBirth": "${escapeStringForJson(dateOfBirth)}",
  "address": "${escapeStringForJson(address)}",
  "city": "${escapeStringForJson(city)}",
  "state": "${escapeStringForJson(state)}",
  "postalCode": "${escapeStringForJson(postalCode)}",
  "countryCode": "${escapeStringForJson(countryCode)}",
  "profilePicture": "${escapeStringForJson(profilePicture)}",
  "gender": "${escapeStringForJson(gender)}",
  "type": "${escapeStringForJson(type)}",
  "kycCompleted": ${kycCompleted},
  "kycPassed": ${kycPassed}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'updateUserProfile',
      apiUrl: '${baseUrl}/updateUserProfile',
      callType: ApiCallType.PATCH,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetLegalEntityCall {
  Future<ApiCallResponse> call({
    String? idLegalEntity = '',
    String? requestingIdUser = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'getLegalEntity',
      apiUrl: '${baseUrl}/get-one-legal-entity',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'idLegalEntity': idLegalEntity,
        'requestingIdUser': requestingIdUser,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic legalEntity(dynamic response) => getJsonField(
        response,
        r'''$''',
      );
}

class UpdateLegalEntityCall {
  Future<ApiCallResponse> call({
    String? idLegalEntity = '',
    String? legalName = '',
    String? identifierCode = '',
    String? operationalAddress = '',
    String? headquartersAddress = '',
    String? legalRepresentative = '',
    String? email = '',
    String? phone = '',
    String? pec = '',
    String? website = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idLegalEntity": "${escapeStringForJson(idLegalEntity)}",
  "legalName":"${escapeStringForJson(legalName)}" ,
  "identifierCode": "${escapeStringForJson(identifierCode)}",
  "operationalAddress": "${escapeStringForJson(operationalAddress)}",
  "headquartersAddress":"${escapeStringForJson(headquartersAddress)}" ,
  "legalRepresentative":"${escapeStringForJson(legalRepresentative)}" ,
  "email": "${escapeStringForJson(email)}",
  "phone": "${escapeStringForJson(phone)}",
  "pec": "${escapeStringForJson(pec)}",
  "website":"${escapeStringForJson(website)}"
}
''';
    return ApiManager.instance.makeApiCall(
      callName: 'updateLegalEntity',
      apiUrl: '${baseUrl}/update-lega-entity',
      callType: ApiCallType.PUT,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateLegalEntityCall {
  Future<ApiCallResponse> call({
    String? legalName = '',
    String? identifierCode = '',
    String? operationalAddress = '',
    String? headquartersAddress = '',
    String? legalRepresentative = '',
    String? email = '',
    String? phone = '',
    String? pec = '',
    String? website = '',
    String? requestingIdUser = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "legalName": "${escapeStringForJson(legalName)}",
  "identifierCode": "${escapeStringForJson(identifierCode)}",
  "operationalAddress": "${escapeStringForJson(operationalAddress)}",
  "headquartersAddress": "${escapeStringForJson(headquartersAddress)}",
  "legalRepresentative": "${escapeStringForJson(legalRepresentative)}",
  "email": "${escapeStringForJson(email)}",
  "phone": "${escapeStringForJson(phone)}",
  "pec": "${escapeStringForJson(pec)}",
  "website": "${escapeStringForJson(website)}",
  "requestingIdUser": "${escapeStringForJson(requestingIdUser)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createLegalEntity',
      apiUrl: '${baseUrl}/create-legal-entity',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetLegalEntitiesCall {
  Future<ApiCallResponse> call({
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'getLegalEntities',
      apiUrl: '${baseUrl}/get-all-legal-entity',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? entities(dynamic response) => getJsonField(
        response,
        r'''$.entities''',
        true,
      ) as List?;
}

class CreateAssociateUserWalletCall {
  Future<ApiCallResponse> call({
    String? idUser = '',
    String? walletPublicAddress = '',
    String? createdBy = '',
    String? secretKey = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idUser": "${escapeStringForJson(idUser)}",
  "walletPublicAddress": "${escapeStringForJson(walletPublicAddress)}",
  "createdBy": "${escapeStringForJson(createdBy)}",
  "secretKey": "${escapeStringForJson(secretKey)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createAssociateUserWallet',
      apiUrl: '${baseUrl}/associateUserWallet',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CheckUserHasActiveCertifierCall {
  Future<ApiCallResponse> call({
    String? idUser = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idUser": "${escapeStringForJson(idUser)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'checkUserHasActiveCertifier',
      apiUrl: '${baseUrl}/checkUserHasActiveCertifier',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? existsActive(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.existsActive''',
      ));
}

class GetUsersByIdsCall {
  Future<ApiCallResponse> call({
    List<String>? idUsersList,
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );
    final idUsers = _serializeList(idUsersList);

    final ffApiRequestBody = '''
{
  "idUsers": ${idUsers}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getUsersByIds',
      apiUrl: '${baseUrl}/getUsersByIds',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? users(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

class DeleteUserAndAssociatedDataCall {
  Future<ApiCallResponse> call({
    String? idUser = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idUser": "${escapeStringForJson(idUser)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'deleteUserAndAssociatedData',
      apiUrl: '${baseUrl}/deleteUserAndAssociatedData',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
}

class CreateWalletCall {
  Future<ApiCallResponse> call({
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    return ApiManager.instance.makeApiCall(
      callName: 'createWallet',
      apiUrl: '${baseUrl}/create-wallet-api',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? walletAddress(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.walletId''',
      ));
  String? secretKey(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.output''',
      ));
}

class SessionRequestVeriffNewCall {
  Future<ApiCallResponse> call({
    String? firstName = '',
    String? lastName = '',
    String? email = '',
    String? phoneNumber = '',
    String? dateOfBirth = '',
    String? callback,
    String? supabaseApiUrlCommon,
  }) async {
    callback ??= FFDevEnvironmentValues().callbackUrlVeriffWeb;
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "callback": "${escapeStringForJson(callback)}",
  "firstName": "${escapeStringForJson(firstName)}",
  "lastName": "${escapeStringForJson(lastName)}",
  "additionalFields": {
    "email": "${escapeStringForJson(email)}",
    "phoneNumber": "${escapeStringForJson(phoneNumber)}",
    "dateOfBirth": "${escapeStringForJson(dateOfBirth)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sessionRequestVeriffNew',
      apiUrl: '${baseUrl}/verify-call-api',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.success''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  String? responseStatus(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.response.status''',
      ));
  String? responseVerificationSessionToken(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.response.verification.sessionToken''',
      ));
  String? note(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.note''',
      ));
  String? sessionId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.sessionId''',
      ));
  dynamic receivedParams(dynamic response) => getJsonField(
        response,
        r'''$.receivedParams''',
      );
  String? responseVerificationUrl(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.response.verification.url''',
      ));
}

class CheckSessionVeriffCall {
  Future<ApiCallResponse> call({
    String? sessionId = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "id": "${escapeStringForJson(sessionId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'checkSessionVeriff',
      apiUrl: '${baseUrl}/check-veriff-session',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic verification(dynamic response) => getJsonField(
        response,
        r'''$.data.data.raw.verification''',
      );
  int? status(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.status''',
      ));
}

class CreateKycAttemptCall {
  Future<ApiCallResponse> call({
    String? idUser = '',
    String? requestBody = '',
    String? success = '',
    String? message = '',
    String? receivedParams = '',
    String? responseVerificationId = '',
    String? responseVerificationUrl = '',
    String? responseVerificationSessionToken = '',
    String? sessionId = '',
    String? responseStatus = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idUser": "${escapeStringForJson(idUser)}",
  "requestBody": "${escapeStringForJson(requestBody)}",
  "success": "${escapeStringForJson(success)}",
  "message": "${escapeStringForJson(message)}",
  "receivedParams": "${escapeStringForJson(receivedParams)}",
  "responseStatus": "${escapeStringForJson(responseStatus)}",
  "responseVerificationId": "${escapeStringForJson(responseVerificationId)}",
  "responseVerificationUrl": "${escapeStringForJson(responseVerificationUrl)}",
  "responseVerificationSessionToken": "${escapeStringForJson(responseVerificationSessionToken)}",
  "sessionId": "${escapeStringForJson(sessionId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createKycAttempt',
      apiUrl: '${baseUrl}/createKycAttempt',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? idKycAttempt(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.idKycAttempt''',
      ));
}

class UpdateKycVerificationCall {
  Future<ApiCallResponse> call({
    int? idKycAttempt,
    bool? verificated,
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idKycAttempt": ${idKycAttempt},
  "verificated": ${verificated}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'updateKycVerification',
      apiUrl: '${baseUrl}/updateKycVerification',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetLastKycAttemptCall {
  Future<ApiCallResponse> call({
    String? idUser = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idUser": "${escapeStringForJson(idUser)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getLastKycAttempt',
      apiUrl: '${baseUrl}/last-kyc-attempt',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? idKycAttempt(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.idKycAttempt''',
      ));
  String? sessionId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.sessionId''',
      ));
}

class UpdateStatusLegalEntityCall {
  Future<ApiCallResponse> call({
    String? idLegalEntity = '',
    String? status = '',
    String? statusUpdatedByIdUser = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final ffApiRequestBody = '''
{
  "idLegalEntity": "${escapeStringForJson(idLegalEntity)}",
  "status": "${escapeStringForJson(status)}",
  "statusUpdatedByIdUser": "${escapeStringForJson(statusUpdatedByIdUser)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'updateStatusLegalEntity',
      apiUrl: '${baseUrl}/approve-disapprove-legal-entity',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SyncimagefromjectcventerpriseCall {
  Future<ApiCallResponse> call({
    dynamic fileJson,
    String? userId = '',
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final file = _serializeJson(fileJson);

    return ApiManager.instance.makeApiCall(
      callName: 'syncimagefromjectcventerprise',
      apiUrl: '${baseUrl}/sync-image-from-jectcventerprise',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'file': file,
        'user_id': userId,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateupdatelegalentityCall {
  Future<ApiCallResponse> call({
    String? idLegalEntity = '',
    String? legalName = '',
    String? identifierCode = '',
    String? headquartersAddress = '',
    String? operationalAddress = '',
    String? legalRepresentative = '',
    String? email = '',
    String? phone = '',
    String? pec = '',
    String? website = '',
    String? requestingIdUser = '',
    dynamic companyPictureUrlJson,
    dynamic logoPictureUrlJson,
    String? supabaseApiUrlCommon,
  }) async {
    supabaseApiUrlCommon ??= FFDevEnvironmentValues().supabaseApiUrlCommon;
    final baseUrl = SupabaseGroup.getBaseUrl(
      supabaseApiUrlCommon: supabaseApiUrlCommon,
    );

    final companyPictureUrl = _serializeJson(companyPictureUrlJson);
    final logoPictureUrl = _serializeJson(logoPictureUrlJson);
    final ffApiRequestBody = '''
{
  "idLegalEntity": "${escapeStringForJson(idLegalEntity)}",
  "legalName": "${escapeStringForJson(legalName)}",
  "identifierCode": "${escapeStringForJson(identifierCode)}",
  "operationalAddress": "${escapeStringForJson(operationalAddress)}",
  "headquartersAddress": "${escapeStringForJson(headquartersAddress)}",
  "legalRepresentative": "${escapeStringForJson(legalRepresentative)}",
  "email": "${escapeStringForJson(email)}",
  "phone": "${escapeStringForJson(phone)}",
  "pec": "${escapeStringForJson(pec)}",
  "website": "${escapeStringForJson(website)}",
  "requestingIdUser": "${escapeStringForJson(requestingIdUser)}",
  "companyPictureUrl": ${companyPictureUrl},
  "logoPictureUrl": ${logoPictureUrl}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createupdatelegalentity',
      apiUrl: '${baseUrl}/create-update-legal-entity',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End Supabase Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
