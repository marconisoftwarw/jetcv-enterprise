// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MapUserTypeStruct extends BaseStruct {
  MapUserTypeStruct({
    UserType? option,
    String? label,
  })  : _option = option,
        _label = label;

  // "option" field.
  UserType? _option;
  UserType? get option => _option;
  set option(UserType? val) => _option = val;

  bool hasOption() => _option != null;

  // "label" field.
  String? _label;
  String get label => _label ?? '';
  set label(String? val) => _label = val;

  bool hasLabel() => _label != null;

  static MapUserTypeStruct fromMap(Map<String, dynamic> data) =>
      MapUserTypeStruct(
        option: data['option'] is UserType
            ? data['option']
            : deserializeEnum<UserType>(data['option']),
        label: data['label'] as String?,
      );

  static MapUserTypeStruct? maybeFromMap(dynamic data) => data is Map
      ? MapUserTypeStruct.fromMap(data.cast<String, dynamic>())
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

  static MapUserTypeStruct fromSerializableMap(Map<String, dynamic> data) =>
      MapUserTypeStruct(
        option: deserializeParam<UserType>(
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
  String toString() => 'MapUserTypeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MapUserTypeStruct &&
        option == other.option &&
        label == other.label;
  }

  @override
  int get hashCode => const ListEquality().hash([option, label]);
}

MapUserTypeStruct createMapUserTypeStruct({
  UserType? option,
  String? label,
}) =>
    MapUserTypeStruct(
      option: option,
      label: label,
    );
