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

  /// Ottiene tutti i CV pubblici
  Future<List<CV>> getPublicCVs() async {
    try {
      print('CVService: Iniziando caricamento CV pubblici...');

      final response = await _supabase
          .from('cv')
          .select('*')
          .order('createdAt', ascending: false);

      print('CVService: Risposta da Supabase: $response');
      print('CVService: Tipo di risposta: ${response.runtimeType}');

      if (response == null) {
        print('CVService: Risposta null da Supabase');
        return [];
      }

      if (response is List) {
        print('CVService: Numero di CV trovati: ${response.length}');

        if (response.isEmpty) {
          print('CVService: Lista CV vuota');
          return [];
        }

        // Log del primo CV per debug
        if (response.isNotEmpty) {
          print('CVService: Primo CV: ${response.first}');
        }

        final cvs = response.map((json) {
          try {
            print('CVService: Parsing CV: $json');
            return CV.fromJson(json);
          } catch (e) {
            print('CVService: Errore nel parsing del CV: $e');
            print('CVService: JSON problematico: $json');
            rethrow;
          }
        }).toList();

        print('CVService: CV parsati con successo: ${cvs.length}');
        return cvs;
      } else {
        print(
          'CVService: Tipo di risposta inaspettato: ${response.runtimeType}',
        );
        return [];
      }
    } catch (e) {
      print('CVService: Errore nel caricamento CV pubblici: $e');
      print('CVService: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Cerca CV per nome, località o competenze
  Future<List<CV>> searchCVs(String query) async {
    try {
      if (query.isEmpty) {
        return await getPublicCVs();
      }

      final lowercaseQuery = query.toLowerCase();
      final allCVs = await getPublicCVs();

      return allCVs.where((cv) {
        return cv.displayName.toLowerCase().contains(lowercaseQuery) ||
            cv.displayLocation.toLowerCase().contains(lowercaseQuery) ||
            (cv.email?.toLowerCase() ?? '').contains(lowercaseQuery) ||
            (cv.city?.toLowerCase() ?? '').contains(lowercaseQuery) ||
            (cv.state?.toLowerCase() ?? '').contains(lowercaseQuery);
      }).toList();
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
