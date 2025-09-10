import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CertificationCategoryService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static Future<Map<String, String>> getCategoryNames() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/functions/v1/get-category-certification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> categories = json.decode(response.body);
        final Map<String, String> categoryMap = {};

        for (final category in categories) {
          final String id = category['id_certification_category'] ?? '';
          final String name = category['name'] ?? '';
          if (id.isNotEmpty && name.isNotEmpty) {
            categoryMap[id] = name;
          }
        }

        return categoryMap;
      } else {
        print(
          '❌ Error fetching categories: ${response.statusCode} - ${response.body}',
        );
        return {};
      }
    } catch (e) {
      print('❌ Exception fetching categories: $e');
      return {};
    }
  }
}
