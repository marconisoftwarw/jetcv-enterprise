import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Modello per rappresentare l'esito di un utente per una certificazione
class CertificationUserOutcome {
  final String idUser;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? reason; // Motivazione opzionale per rifiuto/accettazione
  final DateTime? respondedAt; // Data di risposta
  final DateTime addedAt; // Data di aggiunta alla certificazione

  CertificationUserOutcome({
    required this.idUser,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profilePicture,
    required this.status,
    this.reason,
    this.respondedAt,
    required this.addedAt,
  });

  factory CertificationUserOutcome.fromJson(Map<String, dynamic> json) {
    return CertificationUserOutcome(
      idUser: json['id_user'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      status: json['status'] ?? 'pending',
      reason: json['reason'],
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'])
          : null,
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get displayName {
    final name = fullName;
    return name.isEmpty ? email : name;
  }
}

class CertificationUsersOutcomeService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
  };

  /// Ottiene tutti gli utenti di una certificazione con i loro esiti
  static Future<List<CertificationUserOutcome>> getCertificationUsersOutcomes({
    required String certificationId,
  }) async {
    try {
      print('🔍 Getting users outcomes for certification: $certificationId');

      // Prima verifica se ci sono certification_user per questa certificazione
      print('🔍 Step 1: Checking certification_user entries...');
      final testResponse = await http.get(
        Uri.parse(
          '$_baseUrl/rest/v1/certification_user?select=*&id_certification=eq.$certificationId',
        ),
        headers: _headers,
      );
      print(
        '📊 Test response: ${testResponse.statusCode} - ${testResponse.body}',
      );

      // Prova anche con GET sulla tabella certificazione per verificare struttura
      print('🔍 Step 2: Checking certification table...');
      final certResponse = await http.get(
        Uri.parse(
          '$_baseUrl/rest/v1/certification?select=*&id_certification=eq.$certificationId',
        ),
        headers: _headers,
      );
      print(
        '📊 Cert response: ${certResponse.statusCode} - ${certResponse.body}',
      );

      // Prova a vedere se esistono utenti nella tabella (senza filtro per questa certificazione)
      print('🔍 Step 3: Checking all certification_user entries...');
      final allUsersResponse = await http.get(
        Uri.parse('$_baseUrl/rest/v1/certification_user?select=*&limit=5'),
        headers: _headers,
      );
      print(
        '📊 All users response: ${allUsersResponse.statusCode} - ${allUsersResponse.body}',
      );

      // Query per ottenere gli utenti della certificazione con i loro dati e stati
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/rest/v1/certification_user?select=*,user(firstName,lastName,email,phone,profilePicture)&id_certification=eq.$certificationId&order=created_at.desc',
        ),
        headers: _headers,
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final outcomes = data.map((item) {
          final userData = item['user'] ?? {};

          // Se userData è null o vuoto, proviamo a recuperare l'email da id_user
          String userEmail = userData['email'] ?? 'user-${item['id_user']}';

          print('🔍 Processing user: ${item['id_user']}, userData: $userData');

          return CertificationUserOutcome.fromJson({
            'id_user': item['id_user'],
            'firstName': userData['firstName'] ?? 'N/A',
            'lastName': userData['lastName'] ?? 'N/A',
            'email': userEmail,
            'phone': userData['phone'],
            'profilePicture': userData['profilePicture'],
            'status': item['status'],
            'reason': item['reason'],
            'responded_at': item['responded_at'],
            'added_at': item['created_at'],
          });
        }).toList();

        print('✅ Found ${outcomes.length} users for certification');
        return outcomes;
      } else {
        print(
          '❌ Error getting certification users: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Exception getting certification users outcomes: $e');
      return [];
    }
  }

  /// Ottiene le statistiche degli esiti per una certificazione
  static Future<Map<String, int>> getCertificationOutcomeStats({
    required String certificationId,
  }) async {
    try {
      print('📊 Getting outcome stats for certification: $certificationId');

      final outcomes = await getCertificationUsersOutcomes(
        certificationId: certificationId,
      );

      final stats = <String, int>{
        'total': outcomes.length,
        'pending': 0,
        'accepted': 0,
        'rejected': 0,
      };

      for (final outcome in outcomes) {
        switch (outcome.status) {
          case 'pending':
            stats['pending'] = (stats['pending'] ?? 0) + 1;
            break;
          case 'accepted':
            stats['accepted'] = (stats['accepted'] ?? 0) + 1;
            break;
          case 'rejected':
            stats['rejected'] = (stats['rejected'] ?? 0) + 1;
            break;
        }
      }

      print('📊 Stats: $stats');
      return stats;
    } catch (e) {
      print('❌ Exception getting outcome stats: $e');
      return {};
    }
  }

  /// Filtra gli utenti per stato
  static List<CertificationUserOutcome> filterByStatus(
    List<CertificationUserOutcome> outcomes,
    String status,
  ) {
    return outcomes.where((outcome) => outcome.status == status).toList();
  }

  /// Ottiene solo gli utenti con motivazione
  static List<CertificationUserOutcome> getOutcomesWithReason(
    List<CertificationUserOutcome> outcomes,
  ) {
    return outcomes
        .where(
          (outcome) =>
              outcome.reason != null && outcome.reason!.trim().isNotEmpty,
        )
        .toList();
  }
}
