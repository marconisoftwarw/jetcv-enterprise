import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jetcv_enterprise/config/app_config.dart';

class CertificationInformationService {
  static const String _baseUrl =
      '${AppConfig.supabaseUrl}/functions/v1/get-certification-information';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
    'apikey': AppConfig.supabaseAnonKey,
  };

  /// Ottiene tutte le informazioni di certificazione dalla Edge Function
  static Future<List<CertificationInformation>>
  getCertificationInformations() async {
    try {
      print('🔍 Fetching certification informations from Edge Function...');

      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final informations = data
            .map((json) => CertificationInformation.fromJson(json))
            .toList();

        print(
          '✅ Successfully fetched ${informations.length} certification informations',
        );
        return informations;
      } else {
        print(
          '❌ Error fetching certification informations: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Exception fetching certification informations: $e');
      return [];
    }
  }

  /// Ottiene solo le informazioni con scope "certification_user"
  static Future<List<CertificationInformation>>
  getCertificationUserInformations() async {
    try {
      final allInformations = await getCertificationInformations();
      final userInformations = allInformations
          .where((info) => info.scope == 'certification_user')
          .toList();

      print(
        '✅ Found ${userInformations.length} certification_user informations',
      );
      return userInformations;
    } catch (e) {
      print('❌ Error filtering certification_user informations: $e');
      return [];
    }
  }
}

class CertificationInformation {
  final String name;
  final int order;
  final String createdAt;
  final String? updatedAt;
  final String label;
  final String type;
  final String idCertificationInformation;
  final String? idLegalEntity;
  final String scope;

  CertificationInformation({
    required this.name,
    required this.order,
    required this.createdAt,
    this.updatedAt,
    required this.label,
    required this.type,
    required this.idCertificationInformation,
    this.idLegalEntity,
    required this.scope,
  });

  factory CertificationInformation.fromJson(Map<String, dynamic> json) {
    return CertificationInformation(
      name: json['name'] as String,
      order: json['order'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      label: json['label'] as String,
      type: json['type'] as String,
      idCertificationInformation:
          json['id_certification_information'] as String,
      idLegalEntity: json['id_legal_entity'] as String?,
      scope: json['scope'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'order': order,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'label': label,
      'type': type,
      'id_certification_information': idCertificationInformation,
      'id_legal_entity': idLegalEntity,
      'scope': scope,
    };
  }

  @override
  String toString() {
    return 'CertificationInformation(name: $name, label: $label, scope: $scope, order: $order)';
  }
}
