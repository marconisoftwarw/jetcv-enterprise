import 'package:uuid/uuid.dart';

class Location {
  final String idLocation;
  final String idUser;
  final DateTime acquiredAt;
  final double latitude;
  final double longitude;
  final double? accuracyM;
  final bool? isMocked;
  final double? altitude;
  final double? altitudeAccuracyM;
  final String? name;
  final String? street;
  final String? locality;
  final String? subLocality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? postalCode;
  final String? isoCountryCode;
  final String? country;
  final String? thoroughfare;
  final String? subThoroughfare;
  final DateTime createdAt;

  Location({
    required this.idLocation,
    required this.idUser,
    required this.acquiredAt,
    required this.latitude,
    required this.longitude,
    this.accuracyM,
    this.isMocked,
    this.altitude,
    this.altitudeAccuracyM,
    this.name,
    this.street,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.isoCountryCode,
    this.country,
    this.thoroughfare,
    this.subThoroughfare,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      idLocation: json['id_location'],
      idUser: json['id_user'],
      acquiredAt: DateTime.parse(json['acquired_at']),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      accuracyM: json['accuracy_m']?.toDouble(),
      isMocked: json['is_mocked'],
      altitude: json['altitude']?.toDouble(),
      altitudeAccuracyM: json['altitude_accuracy_m']?.toDouble(),
      name: json['name'],
      street: json['street'],
      locality: json['locality'],
      subLocality: json['sub_locality'],
      administrativeArea: json['administrative_area'],
      subAdministrativeArea: json['sub_administrative_area'],
      postalCode: json['postal_code'],
      isoCountryCode: json['iso_country_code'],
      country: json['country'],
      thoroughfare: json['thoroughfare'],
      subThoroughfare: json['sub_thoroughfare'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_location': idLocation,
      'id_user': idUser,
      'acquired_at': acquiredAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_m': accuracyM,
      'is_mocked': isMocked,
      'altitude': altitude,
      'altitude_accuracy_m': altitudeAccuracyM,
      'name': name,
      'street': street,
      'locality': locality,
      'sub_locality': subLocality,
      'administrative_area': administrativeArea,
      'sub_administrative_area': subAdministrativeArea,
      'postal_code': postalCode,
      'iso_country_code': isoCountryCode,
      'country': country,
      'thoroughfare': thoroughfare,
      'sub_thoroughfare': subThoroughfare,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Location copyWith({
    String? idLocation,
    String? idUser,
    DateTime? acquiredAt,
    double? latitude,
    double? longitude,
    double? accuracyM,
    bool? isMocked,
    double? altitude,
    double? altitudeAccuracyM,
    String? name,
    String? street,
    String? locality,
    String? subLocality,
    String? administrativeArea,
    String? subAdministrativeArea,
    String? postalCode,
    String? isoCountryCode,
    String? country,
    String? thoroughfare,
    String? subThoroughfare,
    DateTime? createdAt,
  }) {
    return Location(
      idLocation: idLocation ?? this.idLocation,
      idUser: idUser ?? this.idUser,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyM: accuracyM ?? this.accuracyM,
      isMocked: isMocked ?? this.isMocked,
      altitude: altitude ?? this.altitude,
      altitudeAccuracyM: altitudeAccuracyM ?? this.altitudeAccuracyM,
      name: name ?? this.name,
      street: street ?? this.street,
      locality: locality ?? this.locality,
      subLocality: subLocality ?? this.subLocality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      subAdministrativeArea:
          subAdministrativeArea ?? this.subAdministrativeArea,
      postalCode: postalCode ?? this.postalCode,
      isoCountryCode: isoCountryCode ?? this.isoCountryCode,
      country: country ?? this.country,
      thoroughfare: thoroughfare ?? this.thoroughfare,
      subThoroughfare: subThoroughfare ?? this.subThoroughfare,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Factory method to create a new location
  factory Location.create({
    required String idUser,
    required double latitude,
    required double longitude,
    double? accuracyM,
    bool? isMocked,
    double? altitude,
    double? altitudeAccuracyM,
    String? name,
    String? street,
    String? locality,
    String? subLocality,
    String? administrativeArea,
    String? subAdministrativeArea,
    String? postalCode,
    String? isoCountryCode,
    String? country,
    String? thoroughfare,
    String? subThoroughfare,
  }) {
    return Location(
      idLocation: const Uuid().v4(),
      idUser: idUser,
      acquiredAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      accuracyM: accuracyM,
      isMocked: isMocked,
      altitude: altitude,
      altitudeAccuracyM: altitudeAccuracyM,
      name: name,
      street: street,
      locality: locality,
      subLocality: subLocality,
      administrativeArea: administrativeArea,
      subAdministrativeArea: subAdministrativeArea,
      postalCode: postalCode,
      isoCountryCode: isoCountryCode,
      country: country,
      thoroughfare: thoroughfare,
      subThoroughfare: subThoroughfare,
    );
  }

  // Helper methods
  String get displayAddress {
    final parts = <String>[];

    if (street != null) parts.add(street!);
    if (locality != null) parts.add(locality!);
    if (administrativeArea != null) parts.add(administrativeArea!);
    if (postalCode != null) parts.add(postalCode!);
    if (country != null) parts.add(country!);

    return parts.isEmpty ? 'Posizione sconosciuta' : parts.join(', ');
  }

  bool get hasAccurateLocation => accuracyM != null && accuracyM! < 100;
  bool get isRecent => DateTime.now().difference(acquiredAt).inMinutes < 5;
}
