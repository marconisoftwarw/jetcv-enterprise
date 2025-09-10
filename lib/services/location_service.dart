import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class LocationService {
  static const String _baseUrl = '${AppConfig.supabaseUrl}/functions/v1/locations';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': AppConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
  };

  /// Crea una location per l'utente loggato
  static Future<String?> createLocationForUser(String userId) async {
    try {
      print('🔍 Creating location for user: $userId');
      
      // Dati di esempio per la location (puoi personalizzarli)
      final locationData = {
        'id_user': userId,
        'aquired_at': DateTime.now().toIso8601String(),
        'latitude': 41.9028, // Roma
        'longitude': 12.4964,
        'accuracy_m': 10.0,
        'is_moked': false,
        'altitude': 50.0,
        'altitude_accuracy_m': 5.0,
        'name': 'Default Location',
        'street': 'Via Roma 1',
        'locality': 'Roma',
        'sub_locality': 'Centro',
        'administrative_area': 'Lazio',
        'sub_administrative_area': 'Roma',
        'postal_code': '00100',
        'iso_country_code': 'IT',
        'country': 'Italy',
        'thoroughfare': 'Via Roma',
        'sub_thoroughfare': '1',
      };

      print('📋 Location data: $locationData');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: json.encode(locationData),
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        final locationId = result['data']['id_location'] as String?;
        print('✅ Location created successfully: $locationId');
        return locationId;
      } else {
        print('❌ Error creating location: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception creating location: $e');
      return null;
    }
  }

  /// Ottiene una location esistente per l'utente
  static Future<String?> getLocationForUser(String userId) async {
    try {
      print('🔍 Getting location for user: $userId');
      
      final uri = Uri.parse('$_baseUrl?id_user=$userId&limit=1&order=aquired_at&dir=desc');
      final response = await http.get(uri, headers: _headers);

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final data = result['data'] as List<dynamic>?;
        
        if (data != null && data.isNotEmpty) {
          final locationId = data[0]['id_location'] as String?;
          print('✅ Found existing location: $locationId');
          return locationId;
        }
      } else {
        print('❌ Error fetching location: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('❌ Exception fetching location: $e');
      return null;
    }
  }

  /// Ottiene o crea una location per l'utente
  static Future<String?> getOrCreateLocationForUser(String userId) async {
    try {
      // Prima prova a ottenere una location esistente
      final existingLocationId = await getLocationForUser(userId);
      if (existingLocationId != null) {
        return existingLocationId;
      }

      // Se non esiste, crea una nuova
      print('📝 No existing location found, creating new one...');
      return await createLocationForUser(userId);
    } catch (e) {
      print('❌ Error getting or creating location for user: $e');
      return null;
    }
  }
}
