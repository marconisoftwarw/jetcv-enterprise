import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CertificationCategoryService {
  static const String _baseUrl = '${AppConfig.supabaseUrl}/rest/v1';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': AppConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
  };

  /// Ottiene tutte le categorie di certificazione
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      print('🔍 Fetching certification categories...');

      final response = await http.get(
        Uri.parse('$_baseUrl/certification_category'),
        headers: _headers,
      );

      print('📊 Categories response status: ${response.statusCode}');
      print('📊 Categories response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Found ${data.length} categories');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Error fetching categories: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception fetching categories: $e');
      return [];
    }
  }

  /// Crea una categoria di certificazione
  static Future<Map<String, dynamic>?> createCategory({
    required String name,
    required String type,
    int? order,
    String? idLegalEntity,
  }) async {
    try {
      print('➕ Creating certification category: $name');

      final data = {
        'name': name,
        'type': type,
        'order': order,
        'id_legal_entity': idLegalEntity,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/certification_category'),
        headers: _headers,
        body: json.encode(data),
      );

      print('📊 Create category response status: ${response.statusCode}');
      print('📊 Create category response body: ${response.body}');

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        print('✅ Category created successfully');
        return result;
      } else {
        print('❌ Error creating category: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception creating category: $e');
      return null;
    }
  }

  /// Crea le categorie predefinite se non esistono
  static Future<void> createDefaultCategories() async {
    try {
      print('🔧 Creating default certification categories...');

      final existingCategories = await getCategories();
      if (existingCategories.isNotEmpty) {
        print('✅ Categories already exist, skipping creation');
        return;
      }

      final defaultCategories = [
        {'name': 'Corso Specifico', 'type': 'standard', 'order': 1},
        {'name': 'Workshop', 'type': 'standard', 'order': 2},
        {'name': 'Seminario', 'type': 'standard', 'order': 3},
        {'name': 'Formazione Online', 'type': 'standard', 'order': 4},
        {'name': 'Esame', 'type': 'standard', 'order': 5},
        {'name': 'Altro', 'type': 'standard', 'order': 6},
      ];

      for (final category in defaultCategories) {
        await createCategory(
          name: category['name'] as String,
          type: category['type'] as String,
          order: category['order'] as int,
        );
        print('✅ Created category: ${category['name']}');
      }

      print('🎉 All default categories created successfully');
    } catch (e) {
      print('❌ Exception creating default categories: $e');
    }
  }

  /// Ottiene l'ID di una categoria per nome
  static Future<String?> getCategoryIdByName(String categoryName) async {
    try {
      final categories = await getCategories();
      final category = categories.firstWhere(
        (cat) => cat['name'] == categoryName,
        orElse: () => <String, dynamic>{},
      );

      return category['id_certification_category'] as String?;
    } catch (e) {
      print('❌ Exception getting category ID for $categoryName: $e');
      return null;
    }
  }
}
