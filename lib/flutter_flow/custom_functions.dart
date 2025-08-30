import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

UserStruct? castJsonToDataTypeUser(dynamic json) {
  final data =
      json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json);

  DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Ritorna UserStruct includendo il nuovo campo hasWallet (bool, not null)
  return UserStruct(
    idUser: data['idUser'] as String?,
    firstName: data['firstName'] as String?,
    lastName: data['lastName'] as String?,
    email: data['email'] as String?,
    phone: data['phone'] as String?,
    dateOfBirth: parseDate(data['dateOfBirth']),
    address: data['address'] as String?,
    city: data['city'] as String?,
    state: data['state'] as String?,
    postalCode: data['postalCode'] as String?,
    countryCode: data['countryCode'] as String?,
    profilePicture: data['profilePicture'] as String?,
    gender: data['gender'] != null
        ? deserializeEnum<UserGender>(data['gender'].toString())!
        : null,
    createdAt: parseDate(data['createdAt']),
    updatedAt: parseDate(data['updatedAt']),
    fullName: data['fullName'] as String?,
    type: data['type'] != null
        ? deserializeEnum<UserType>(data['type'].toString())!
        : null,
    hasWallet: (data['hasWallet'] is bool)
        ? data['hasWallet'] as bool
        : (data['hasWallet'] != null
            ? (data['hasWallet'].toString().toLowerCase() == 'true')
            : false), // default false se null o mancante
    idWallet: data['idWallet'] as String?,
    hasCv: (data['hasCv'] is bool)
        ? data['hasCv'] as bool
        : (data['hasCv'] != null
            ? (data['hasCv'].toString().toLowerCase() == 'true')
            : false), // default false se null o mancante
    idCv: data['idCv'] as String?,
    profileCompleted: (data['profileCompleted'] is bool)
        ? data['profileCompleted'] as bool
        : (data['profileCompleted'] != null
            ? (data['profileCompleted'].toString().toLowerCase() == 'true')
            : false), // default false se null o mancante
    kycCompleted: (data['kycCompleted'] is bool)
        ? data['kycCompleted'] as bool
        : (data['kycCompleted'] != null
            ? (data['kycCompleted'].toString().toLowerCase() == 'true')
            : false), // default false se null o mancante
    kycPassed: (data['kycPassed'] is bool)
        ? data['kycPassed'] as bool
        : (data['kycPassed'] != null
            ? (data['kycPassed'].toString().toLowerCase() == 'true')
            : false), // default false se null o mancante
  );
}

List<UserStruct> castJsonToDataTypeUserList(List<dynamic>? jsonInput) {
  // ✅ null → return empty list
  if (jsonInput == null) return <UserStruct>[];

  // ✅ convert each element explicitly
  final List<UserStruct> result = jsonInput
      .map((e) => castJsonToDataTypeUser(e))
      .whereType<UserStruct>() // keep only valid ones
      .toList();

  return result;
}

LegalEntityStruct? castJsonToDataTypeLegalEntity(dynamic json) {
  // Defensive: handle null early.
  if (json == null) {
    // Return an empty struct instead of throwing.
    return LegalEntityStruct();
  }

  // If input is a JSON string, try to decode it into a Map.
  Map<String, dynamic> data;
  if (json is String) {
    if (json.trim().isEmpty) {
      return LegalEntityStruct();
    }
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else {
        // Not a map after decoding.
        return LegalEntityStruct();
      }
    } catch (_) {
      // Invalid JSON string.
      return LegalEntityStruct();
    }
  } else if (json is Map<String, dynamic>) {
    data = json;
  } else {
    // Try to convert generic Map types (e.g. LinkedHashMap) into Map<String, dynamic>.
    try {
      data = Map<String, dynamic>.from(json as Map);
    } catch (_) {
      return LegalEntityStruct();
    }
  }

  // Parse any input into a DateTime if possible.
  // This returns a DateTime? (or null if can't parse).
  DateTime? parseToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      try {
        // Try ISO8601 first (handles offsets).
        return DateTime.parse(value);
      } catch (_) {
        // Try some common locale formats as fallback.
        try {
          return DateFormat.yMd().add_Hms().parse(value);
        } catch (_) {
          // Last resort: try parsing only date part (no time).
          try {
            return DateFormat.yMd().parse(value);
          } catch (_) {
            return null;
          }
        }
      }
    }
    return null;
  }

  // Build the struct with the new fields (status, statusUpdatedAt, statusUpdatedByIdUser).
  final obj = LegalEntityStruct(
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
    logoPictureUrl: data['logoPictureUrl'] as String?,
    companyPictureUrl: data['companyPictureUrl'] as String?,
    createdAt: parseToDateTime(data['createdAt']),
    updatedAt: parseToDateTime(data['updatedAt']),
    // NEW fields
    status: data['status'] != null
        ? deserializeEnum<LegalEntityStatus>(data['status'].toString())!
        : null,
    statusUpdatedAt: parseToDateTime(data['statusUpdatedAt']),
    statusUpdatedByIdUser: data['statusUpdatedByIdUser'] as String?,
    requestingIdUser: data['requestingIdUser'] as String?,
  );

  return obj;
}

String getFirstNameFromFullName(String? fullName) {
  // retrieve the first word of the input
  if (fullName == null || fullName.isEmpty) {
    return '';
  }
  return fullName.split(' ').first;
}

String getLastNameFromFullName(String? fullName) {
  // retrieve the  words of the input except the first
  if (fullName == null || fullName.isEmpty) {
    return '';
  }
  List<String> words = fullName.split(' ');
  return words.length > 1 ? words.sublist(1).join(' ') : '';
}

UserGender getEnumUserGender(String optionString) {
  return deserializeEnum<UserGender>(optionString)!;
}

UserType getEnumUserType(String optionString) {
  return deserializeEnum<UserType>(optionString)!;
}

List<String> getLabelCountryListWithEmoji(List<CountryStruct>? countries) {
  if (countries == null) return [];

  // return the concatenation "emoji name"
  List<String> countryList = [];
  for (var country in countries) {
    countryList.add('${country.emoji} ${country.name}');
  }
  return countryList;
}

List<LegalEntityStruct> castJsonToDataTypeLegalEntityList(
    List<dynamic>? jsonInput) {
  // ✅ null → return empty list
  if (jsonInput == null) return <LegalEntityStruct>[];

  // ✅ convert each element explicitly
  final List<LegalEntityStruct> result = jsonInput
      .map((e) => castJsonToDataTypeLegalEntity(e))
      .whereType<LegalEntityStruct>() // keep only valid ones
      .toList();

  return result;
}

dynamic castFileToJSON(FFUploadedFile file) {
  print(file);
  return {
    'name': file.name,
    // bytes in base64 così rimane compatibile JSON
    'bytes': file.bytes != null ? base64Encode(file.bytes!) : null,
    'height': file.height,
    'width': file.width,
    'blurHash': file.blurHash,
  };
}
