import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CertificationInfoService {
  static const String _functionName = 'get-info-certification';

  /// Recupera le informazioni dettagliate di una certificazione
  /// Restituisce: tipologia, titolo, descrizione e lista utenti
  static Future<Map<String, dynamic>?> getCertificationInfo(
    String certificationId,
  ) async {
    try {
      final url = '${AppConfig.supabaseUrl}/functions/v1/$_functionName';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: jsonEncode({'id_certification': certificationId}),
      );

      print(
        '🔍 CertificationInfoService: Response status: ${response.statusCode}',
      );
      print('🔍 CertificationInfoService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return data;
        } else {
          print(
            '❌ CertificationInfoService: API returned error: ${data['error']}',
          );
          return null;
        }
      } else {
        print(
          '❌ CertificationInfoService: HTTP error ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('💥 CertificationInfoService: Exception: $e');
      return null;
    }
  }

  /// Recupera le informazioni per multiple certificazioni in batch
  static Future<Map<String, Map<String, dynamic>>>
  getMultipleCertificationsInfo(List<String> certificationIds) async {
    final Map<String, Map<String, dynamic>> results = {};

    // Processa in batch per evitare troppe richieste simultanee
    const batchSize = 5;
    for (int i = 0; i < certificationIds.length; i += batchSize) {
      final batch = certificationIds.skip(i).take(batchSize);

      final futures = batch.map((id) async {
        final info = await getCertificationInfo(id);
        return MapEntry(id, info);
      });

      final batchResults = await Future.wait(futures);

      for (final entry in batchResults) {
        if (entry.value != null) {
          results[entry.key] = entry.value!;
        }
      }
    }

    return results;
  }

  /// Testa la connessione alla edge function
  static Future<bool> testConnection() async {
    try {
      final url = '${AppConfig.supabaseUrl}/functions/v1/$_functionName';

      // Test con una richiesta GET semplice
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}'},
      );

      print(
        '🧪 CertificationInfoService: Connection test status: ${response.statusCode}',
      );
      // Accetta sia 200 (successo) che 400 (bad request, ma connessione OK)
      return response.statusCode == 200 || response.statusCode == 400;
    } catch (e) {
      print('💥 CertificationInfoService: Connection test failed: $e');
      return false;
    }
  }
}
