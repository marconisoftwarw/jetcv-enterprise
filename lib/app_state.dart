import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _loggedUserId =
          await secureStorage.getString('ff_loggedUserId') ?? _loggedUserId;
    });
    await _safeInitAsync(() async {
      _mapUserGender = (await secureStorage.getStringList('ff_mapUserGender'))
              ?.map((x) {
                try {
                  return MapUserGenderStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _mapUserGender;
    });
    await _safeInitAsync(() async {
      _emptyListCountries =
          (await secureStorage.getStringList('ff_emptyListCountries'))
                  ?.map((x) {
                    try {
                      return CountryStruct.fromSerializableMap(jsonDecode(x));
                    } catch (e) {
                      print("Can't decode persisted data type. Error: $e.");
                      return null;
                    }
                  })
                  .withoutNulls
                  .toList() ??
              _emptyListCountries;
    });
    await _safeInitAsync(() async {
      _defaultCountryCode =
          await secureStorage.getString('ff_defaultCountryCode') ??
              _defaultCountryCode;
    });
    await _safeInitAsync(() async {
      _emptyListLegalEntity = (await secureStorage
                  .getStringList('ff_emptyListLegalEntity'))
              ?.map((x) {
                try {
                  return LegalEntityStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _emptyListLegalEntity;
    });
    await _safeInitAsync(() async {
      _mapUserType = (await secureStorage.getStringList('ff_mapUserType'))
              ?.map((x) {
                try {
                  return MapUserTypeStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _mapUserType;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  String _loggedUserId = '';
  String get loggedUserId => _loggedUserId;
  set loggedUserId(String value) {
    _loggedUserId = value;
    secureStorage.setString('ff_loggedUserId', value);
  }

  void deleteLoggedUserId() {
    secureStorage.delete(key: 'ff_loggedUserId');
  }

  List<MapUserGenderStruct> _mapUserGender = [
    MapUserGenderStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"male\",\"label\":\"Maschio\"}')),
    MapUserGenderStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"female\",\"label\":\"Femmina\"}')),
    MapUserGenderStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"non_binary\",\"label\":\"Non binario\"}')),
    MapUserGenderStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"other\",\"label\":\"Altro\"}')),
    MapUserGenderStruct.fromSerializableMap(jsonDecode(
        '{\"option\":\"prefer_not_to_say\",\"label\":\"Preferisco non specificare\"}'))
  ];
  List<MapUserGenderStruct> get mapUserGender => _mapUserGender;
  set mapUserGender(List<MapUserGenderStruct> value) {
    _mapUserGender = value;
    secureStorage.setStringList(
        'ff_mapUserGender', value.map((x) => x.serialize()).toList());
  }

  void deleteMapUserGender() {
    secureStorage.delete(key: 'ff_mapUserGender');
  }

  void addToMapUserGender(MapUserGenderStruct value) {
    mapUserGender.add(value);
    secureStorage.setStringList(
        'ff_mapUserGender', _mapUserGender.map((x) => x.serialize()).toList());
  }

  void removeFromMapUserGender(MapUserGenderStruct value) {
    mapUserGender.remove(value);
    secureStorage.setStringList(
        'ff_mapUserGender', _mapUserGender.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromMapUserGender(int index) {
    mapUserGender.removeAt(index);
    secureStorage.setStringList(
        'ff_mapUserGender', _mapUserGender.map((x) => x.serialize()).toList());
  }

  void updateMapUserGenderAtIndex(
    int index,
    MapUserGenderStruct Function(MapUserGenderStruct) updateFn,
  ) {
    mapUserGender[index] = updateFn(_mapUserGender[index]);
    secureStorage.setStringList(
        'ff_mapUserGender', _mapUserGender.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInMapUserGender(int index, MapUserGenderStruct value) {
    mapUserGender.insert(index, value);
    secureStorage.setStringList(
        'ff_mapUserGender', _mapUserGender.map((x) => x.serialize()).toList());
  }

  List<CountryStruct> _emptyListCountries = [];
  List<CountryStruct> get emptyListCountries => _emptyListCountries;
  set emptyListCountries(List<CountryStruct> value) {
    _emptyListCountries = value;
    secureStorage.setStringList(
        'ff_emptyListCountries', value.map((x) => x.serialize()).toList());
  }

  void deleteEmptyListCountries() {
    secureStorage.delete(key: 'ff_emptyListCountries');
  }

  void addToEmptyListCountries(CountryStruct value) {
    emptyListCountries.add(value);
    secureStorage.setStringList('ff_emptyListCountries',
        _emptyListCountries.map((x) => x.serialize()).toList());
  }

  void removeFromEmptyListCountries(CountryStruct value) {
    emptyListCountries.remove(value);
    secureStorage.setStringList('ff_emptyListCountries',
        _emptyListCountries.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromEmptyListCountries(int index) {
    emptyListCountries.removeAt(index);
    secureStorage.setStringList('ff_emptyListCountries',
        _emptyListCountries.map((x) => x.serialize()).toList());
  }

  void updateEmptyListCountriesAtIndex(
    int index,
    CountryStruct Function(CountryStruct) updateFn,
  ) {
    emptyListCountries[index] = updateFn(_emptyListCountries[index]);
    secureStorage.setStringList('ff_emptyListCountries',
        _emptyListCountries.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInEmptyListCountries(int index, CountryStruct value) {
    emptyListCountries.insert(index, value);
    secureStorage.setStringList('ff_emptyListCountries',
        _emptyListCountries.map((x) => x.serialize()).toList());
  }

  String _defaultCountryCode = 'it';
  String get defaultCountryCode => _defaultCountryCode;
  set defaultCountryCode(String value) {
    _defaultCountryCode = value;
    secureStorage.setString('ff_defaultCountryCode', value);
  }

  void deleteDefaultCountryCode() {
    secureStorage.delete(key: 'ff_defaultCountryCode');
  }

  List<LegalEntityStruct> _emptyListLegalEntity = [];
  List<LegalEntityStruct> get emptyListLegalEntity => _emptyListLegalEntity;
  set emptyListLegalEntity(List<LegalEntityStruct> value) {
    _emptyListLegalEntity = value;
    secureStorage.setStringList(
        'ff_emptyListLegalEntity', value.map((x) => x.serialize()).toList());
  }

  void deleteEmptyListLegalEntity() {
    secureStorage.delete(key: 'ff_emptyListLegalEntity');
  }

  void addToEmptyListLegalEntity(LegalEntityStruct value) {
    emptyListLegalEntity.add(value);
    secureStorage.setStringList('ff_emptyListLegalEntity',
        _emptyListLegalEntity.map((x) => x.serialize()).toList());
  }

  void removeFromEmptyListLegalEntity(LegalEntityStruct value) {
    emptyListLegalEntity.remove(value);
    secureStorage.setStringList('ff_emptyListLegalEntity',
        _emptyListLegalEntity.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromEmptyListLegalEntity(int index) {
    emptyListLegalEntity.removeAt(index);
    secureStorage.setStringList('ff_emptyListLegalEntity',
        _emptyListLegalEntity.map((x) => x.serialize()).toList());
  }

  void updateEmptyListLegalEntityAtIndex(
    int index,
    LegalEntityStruct Function(LegalEntityStruct) updateFn,
  ) {
    emptyListLegalEntity[index] = updateFn(_emptyListLegalEntity[index]);
    secureStorage.setStringList('ff_emptyListLegalEntity',
        _emptyListLegalEntity.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInEmptyListLegalEntity(int index, LegalEntityStruct value) {
    emptyListLegalEntity.insert(index, value);
    secureStorage.setStringList('ff_emptyListLegalEntity',
        _emptyListLegalEntity.map((x) => x.serialize()).toList());
  }

  List<MapUserTypeStruct> _mapUserType = [
    MapUserTypeStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"user\",\"label\":\"Utente\"}')),
    MapUserTypeStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"certifier\",\"label\":\"Certificatore\"}')),
    MapUserTypeStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"legal_entity\",\"label\":\"Legal Entity\"}')),
    MapUserTypeStruct.fromSerializableMap(
        jsonDecode('{\"option\":\"admin\",\"label\":\"Amministratore\"}'))
  ];
  List<MapUserTypeStruct> get mapUserType => _mapUserType;
  set mapUserType(List<MapUserTypeStruct> value) {
    _mapUserType = value;
    secureStorage.setStringList(
        'ff_mapUserType', value.map((x) => x.serialize()).toList());
  }

  void deleteMapUserType() {
    secureStorage.delete(key: 'ff_mapUserType');
  }

  void addToMapUserType(MapUserTypeStruct value) {
    mapUserType.add(value);
    secureStorage.setStringList(
        'ff_mapUserType', _mapUserType.map((x) => x.serialize()).toList());
  }

  void removeFromMapUserType(MapUserTypeStruct value) {
    mapUserType.remove(value);
    secureStorage.setStringList(
        'ff_mapUserType', _mapUserType.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromMapUserType(int index) {
    mapUserType.removeAt(index);
    secureStorage.setStringList(
        'ff_mapUserType', _mapUserType.map((x) => x.serialize()).toList());
  }

  void updateMapUserTypeAtIndex(
    int index,
    MapUserTypeStruct Function(MapUserTypeStruct) updateFn,
  ) {
    mapUserType[index] = updateFn(_mapUserType[index]);
    secureStorage.setStringList(
        'ff_mapUserType', _mapUserType.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInMapUserType(int index, MapUserTypeStruct value) {
    mapUserType.insert(index, value);
    secureStorage.setStringList(
        'ff_mapUserType', _mapUserType.map((x) => x.serialize()).toList());
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
