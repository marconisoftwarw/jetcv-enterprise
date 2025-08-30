import 'package:collection/collection.dart';

enum DevEnvName {
  prod,
  dev,
}

enum UserGender {
  male,
  female,
  non_binary,
  other,
  prefer_not_to_say,
}

enum UserType {
  user,
  certifier,
  legal_entity,
  admin,
}

enum ActionResult {
  success,
  error,
}

enum WalletCreatedBy {
  application,
  user,
}

enum KycStatus {
  pending,
  confirmed,
  refused,
}

enum LegalEntityStatus {
  pending,
  approved,
  rejected,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (DevEnvName):
      return DevEnvName.values.deserialize(value) as T?;
    case (UserGender):
      return UserGender.values.deserialize(value) as T?;
    case (UserType):
      return UserType.values.deserialize(value) as T?;
    case (ActionResult):
      return ActionResult.values.deserialize(value) as T?;
    case (WalletCreatedBy):
      return WalletCreatedBy.values.deserialize(value) as T?;
    case (KycStatus):
      return KycStatus.values.deserialize(value) as T?;
    case (LegalEntityStatus):
      return LegalEntityStatus.values.deserialize(value) as T?;
    default:
      return null;
  }
}
