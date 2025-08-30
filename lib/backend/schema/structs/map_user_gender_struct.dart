// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MapUserGenderStruct extends BaseStruct {
  MapUserGenderStruct({
    UserGender? option,
    String? label,
  })  : _option = option,
        _label = label;

  // "option" field.
  UserGender? _option;
  UserGender? get option => _option;
  set option(UserGender? val) => _option = val;

  bool hasOption() => _option != null;

  // "label" field.
  String? _label;
  String get label => _label ?? '';
  set label(String? val) => _label = val;

  bool hasLabel() => _label != null;

  static MapUserGenderStruct fromMap(Map<String, dynamic> data) =>
      MapUserGenderStruct(
        option: data['option'] is UserGender
            ? data['option']
            : deserializeEnum<UserGender>(data['option']),
        label: data['label'] as String?,
      );

  static MapUserGenderStruct? maybeFromMap(dynamic data) => data is Map
      ? MapUserGenderStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'option': _option?.serialize(),
        'label': _label,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'option': serializeParam(
          _option,
          ParamType.Enum,
        ),
        'label': serializeParam(
          _label,
          ParamType.String,
        ),
      }.withoutNulls;

  static MapUserGenderStruct fromSerializableMap(Map<String, dynamic> data) =>
      MapUserGenderStruct(
        option: deserializeParam<UserGender>(
          data['option'],
          ParamType.Enum,
          false,
        ),
        label: deserializeParam(
          data['label'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'MapUserGenderStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MapUserGenderStruct &&
        option == other.option &&
        label == other.label;
  }

  @override
  int get hashCode => const ListEquality().hash([option, label]);
}

MapUserGenderStruct createMapUserGenderStruct({
  UserGender? option,
  String? label,
}) =>
    MapUserGenderStruct(
      option: option,
      label: label,
    );
