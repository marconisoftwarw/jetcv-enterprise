// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CountryStruct extends BaseStruct {
  CountryStruct({
    String? code,
    String? name,
    String? emoji,
  })  : _code = code,
        _name = name,
        _emoji = emoji;

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  set code(String? val) => _code = val;

  bool hasCode() => _code != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "emoji" field.
  String? _emoji;
  String get emoji => _emoji ?? '';
  set emoji(String? val) => _emoji = val;

  bool hasEmoji() => _emoji != null;

  static CountryStruct fromMap(Map<String, dynamic> data) => CountryStruct(
        code: data['code'] as String?,
        name: data['name'] as String?,
        emoji: data['emoji'] as String?,
      );

  static CountryStruct? maybeFromMap(dynamic data) =>
      data is Map ? CountryStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'code': _code,
        'name': _name,
        'emoji': _emoji,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'code': serializeParam(
          _code,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'emoji': serializeParam(
          _emoji,
          ParamType.String,
        ),
      }.withoutNulls;

  static CountryStruct fromSerializableMap(Map<String, dynamic> data) =>
      CountryStruct(
        code: deserializeParam(
          data['code'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        emoji: deserializeParam(
          data['emoji'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CountryStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CountryStruct &&
        code == other.code &&
        name == other.name &&
        emoji == other.emoji;
  }

  @override
  int get hashCode => const ListEquality().hash([code, name, emoji]);
}

CountryStruct createCountryStruct({
  String? code,
  String? name,
  String? emoji,
}) =>
    CountryStruct(
      code: code,
      name: name,
      emoji: emoji,
    );
