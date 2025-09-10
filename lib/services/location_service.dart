import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class LocationService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static Future<Map<String, String>> getLocationNames() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/locations?select=id_location,name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> locations = json.decode(response.body);
        final Map<String, String> locationMap = {};

        for (final location in locations) {
          final String id = location['id_location'] ?? '';
          final String name = location['name'] ?? '';
          if (id.isNotEmpty && name.isNotEmpty) {
            locationMap[id] = name;
          }
        }

        return locationMap;
      } else {
        print(
          '❌ Error fetching locations: ${response.statusCode} - ${response.body}',
        );
        return {};
      }
    } catch (e) {
      print('❌ Exception fetching locations: $e');
      return {};
    }
  }
}
