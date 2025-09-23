import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cv.dart';

class CVService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Test della connessione al database e della struttura della tabella cv
  Future<Map<String, dynamic>> testDatabaseConnection() async {
    try {
      print('CVService: Test connessione database...');

      // Test 1: Verifica se la tabella cv esiste
      final tableTest = await _supabase.from('cv').select('count').limit(1);

      print('CVService: Test tabella cv: $tableTest');

      // Test 2: Prova a contare i record
      final countResponse = await _supabase.from('cv').select('*');

      print('CVService: Conteggio record: ${countResponse.length}');

      // Test 3: Prova a ottenere la struttura della tabella
      final structureResponse = await _supabase.from('cv').select('*').limit(1);

      print('CVService: Struttura tabella: $structureResponse');

      return {
        'tableExists': tableTest != null,
        'recordCount': countResponse.length,
        'structure': structureResponse.isNotEmpty
            ? structureResponse.first
            : null,
        'success': true,
      };
    } catch (e) {
      print('CVService: Errore nel test del database: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Ottiene CV pubblici tramite Edge Function `search-cv`
  Future<List<CV>> getPublicCVs({
    String? q,
    String? city,
    String? state,
    int limit = 50,
    int offset = 0,
    String orderBy = 'createdAt',
    String orderDir = 'desc',
  }) async {
    try {
      print(
        'CVService: Iniziando caricamento CV via edge function search-cv...',
      );

      final payload = {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
        'order_by': orderBy,
        'order_dir': orderDir,
        'limit': limit,
        'offset': offset,
      };

      final response = await _supabase.functions.invoke(
        'searchcv',
        body: payload,
      );

      print('CVService: search-cv status: ${response.status}');
      final data = response.data;
      if (data == null || data['ok'] != true) {
        print('CVService: Risposta non valida dalla edge function: $data');
        return [];
      }

      final List<dynamic> rows = data['data'] as List<dynamic>? ?? [];
      print('CVService: Numero di CV trovati: ${rows.length}');

      return rows
          .map((json) => CV.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('CVService: Errore nel caricamento CV via edge function: $e');
      return [];
    }
  }

  /// Cerca CV tramite Edge Function `search-cv`
  Future<List<CV>> searchCVs(
    String query, {
    String? city,
    String? state,
    String orderBy = 'createdAt',
    String orderDir = 'desc',
  }) async {
    try {
      return getPublicCVs(
        q: query,
        city: city,
        state: state,
        orderBy: orderBy,
        orderDir: orderDir,
      );
    } catch (e) {
      print('Error searching CVs: $e');
      return [];
    }
  }

  /// Ottiene CV per ID
  Future<CV?> getCVById(String id) async {
    try {
      final response = await _supabase
          .from('cv')
          .select('*')
          .eq('idCv', id)
          .single();

      return CV.fromJson(response);
    } catch (e) {
      print('Error getting CV by ID: $e');
      return null;
    }
  }

  /// Ottiene CV per utente
  Future<CV?> getCVByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('cv')
          .select('*')
          .eq('idUser', userId)
          .single();

      return CV.fromJson(response);
    } catch (e) {
      print('Error getting CV by user ID: $e');
      return null;
    }
  }

  /// Filtra CV per località
  Future<List<CV>> filterCVsByLocation(String location) async {
    try {
      if (location.isEmpty) {
        return await getPublicCVs();
      }

      final lowercaseLocation = location.toLowerCase();
      final allCVs = await getPublicCVs();

      return allCVs.where((cv) {
        return cv.displayLocation.toLowerCase().contains(lowercaseLocation);
      }).toList();
    } catch (e) {
      print('Error filtering CVs by location: $e');
      return [];
    }
  }

  /// Filtra CV verificati
  Future<List<CV>> getVerifiedCVs() async {
    try {
      final allCVs = await getPublicCVs();
      return allCVs.where((cv) => cv.isVerified).toList();
    } catch (e) {
      print('Error getting verified CVs: $e');
      return [];
    }
  }

  /// Ottiene statistiche sui CV
  Future<Map<String, dynamic>> getCVStats() async {
    try {
      final allCVs = await getPublicCVs();

      return {
        'total': allCVs.length,
        'verified': allCVs.where((cv) => cv.isVerified).length,
        'withProfilePicture': allCVs.where((cv) => cv.hasProfilePicture).length,
        'withWallet': allCVs.where((cv) => cv.hasWallet).length,
      };
    } catch (e) {
      print('Error getting CV stats: $e');
      return {
        'total': 0,
        'verified': 0,
        'withProfilePicture': 0,
        'withWallet': 0,
      };
    }
  }
}
