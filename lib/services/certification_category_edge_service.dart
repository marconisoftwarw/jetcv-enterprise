import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jetcv_enterprise/config/app_config.dart';

class CertificationCategoryEdgeService {
  static const String _baseUrl =
      '${AppConfig.supabaseUrl}/functions/v1/get-category-certification';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
    'apikey': AppConfig.supabaseAnonKey,
  };

  /// Ottiene tutte le categorie di certificazione dalla Edge Function
  static Future<List<CertificationCategoryEdge>> getCategories() async {
    try {
      print('🔍 Fetching certification categories from Edge Function...');

      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final categories = data
            .map((json) => CertificationCategoryEdge.fromJson(json))
            .toList();

        print('✅ Successfully fetched ${categories.length} categories');
        return categories;
      } else {
        print(
          '❌ Error fetching categories: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Exception fetching categories: $e');
      return [];
    }
  }

  /// Ottiene l'ID di una categoria per nome
  static Future<String?> getCategoryIdByName(String name) async {
    try {
      final categories = await getCategories();
      final category = categories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
        orElse: () => categories.first, // Fallback alla prima categoria
      );
      return category.idCertificationCategory;
    } catch (e) {
      print('❌ Error getting category ID for name "$name": $e');
      return null;
    }
  }
}

class CertificationCategoryEdge {
  final String name;
  final String createdAt;
  final String? updatedAt;
  final String type;
  final int order;
  final String? idLegalEntity;
  final String idCertificationCategory;

  CertificationCategoryEdge({
    required this.name,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    required this.order,
    this.idLegalEntity,
    required this.idCertificationCategory,
  });

  factory CertificationCategoryEdge.fromJson(Map<String, dynamic> json) {
    return CertificationCategoryEdge(
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      type: json['type'] as String,
      order: json['order'] as int,
      idLegalEntity: json['id_legal_entity'] as String?,
      idCertificationCategory: json['id_certification_category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'type': type,
      'order': order,
      'id_legal_entity': idLegalEntity,
      'id_certification_category': idCertificationCategory,
    };
  }

  @override
  String toString() {
    return 'CertificationCategoryEdge(name: $name, id: $idCertificationCategory, order: $order)';
  }
}
