import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/supabase_service.dart';

class LocationService {
  /// Crea una nuova location tramite Edge Function
  static Future<Map<String, dynamic>?> createLocation({
    required String name,
    String? street,
    String? locality,
    String? administrativeArea,
    String? postalCode,
    String? country,
    String? isoCountryCode,
    double? latitude,
    double? longitude,
    double? accuracyM,
    bool? isMocked,
    double? altitude,
    double? altitudeAccuracyM,
  }) async {
    try {
      print('🌍 Creating location: $name');

      // Ottieni il token di accesso
      final supabaseService = SupabaseService();
      final session = supabaseService.client.auth.currentSession;
      if (session == null) {
        print('❌ No active session');
        return null;
      }

      final url = '${AppConfig.supabaseUrl}/functions/v1/create-location';

      // Prepara i dati per la location
      final locationData = {
        'aquired_at': DateTime.now().toIso8601String(),
        'name': name,
        if (street != null) 'street': street,
        if (locality != null) 'locality': locality,
        if (administrativeArea != null)
          'administrative_area': administrativeArea,
        if (postalCode != null) 'postal_code': postalCode,
        if (country != null) 'country': country,
        if (isoCountryCode != null) 'iso_country_code': isoCountryCode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (accuracyM != null) 'accuracy_m': accuracyM,
        if (isMocked != null) 'is_moked': isMocked,
        if (altitude != null) 'altitude': altitude,
        if (altitudeAccuracyM != null) 'altitude_accuracy_m': altitudeAccuracyM,
      };

      print('📤 Sending location data: $locationData');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
          'apikey': AppConfig.supabaseAnonKey,
        },
        body: json.encode(locationData),
      );

      print('📥 Location creation response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print(
          '✅ Location created successfully: ${responseData['data']['id_location']}',
        );
        return responseData['data'];
      } else {
        print(
          '❌ Failed to create location: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('💥 Error creating location: $e');
      return null;
    }
  }

  /// Crea una location semplice solo con il nome
  static Future<String?> createSimpleLocation(String locationName) async {
    try {
      final result = await createLocation(name: locationName);
      if (result != null) {
        return result['id_location'] as String?;
      }
      return null;
    } catch (e) {
      print('💥 Error creating simple location: $e');
      return null;
    }
  }
}
