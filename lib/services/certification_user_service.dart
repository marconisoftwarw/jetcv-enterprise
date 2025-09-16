import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/otp_verification_service.dart'; // Per UserData

class CertificationUserService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
  };

  /// Recupera gli utenti che hanno già accettato certificazioni per una legal entity
  static Future<List<UserData>> getUsersWithAcceptedCertifications({
    required String legalEntityId,
    String? searchQuery,
    int limit = 50,
  }) async {
    try {
      print('🔍 Searching users with query: "$searchQuery"');

      // Se non c'è query di ricerca, restituisci lista vuota
      if (searchQuery == null || searchQuery.trim().isEmpty) {
        print('ℹ️ No search query provided, returning empty list');
        return [];
      }

      // Usa la Edge Function search-user per cercare gli utenti
      final searchResults = await _searchUsersWithEdgeFunction(
        searchQuery: searchQuery,
        limit: limit,
      );

      if (searchResults.isEmpty) {
        print('ℹ️ No users found with search query: "$searchQuery"');
        return [];
      }

      print('✅ Found ${searchResults.length} users from search');

      // Restituisci direttamente tutti gli utenti trovati dalla ricerca
      // (rimuovo il filtro per certificazioni accettate)
      return searchResults;
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// Usa la Edge Function search-user per cercare utenti
  static Future<List<UserData>> _searchUsersWithEdgeFunction({
    String? searchQuery,
    int limit = 50,
  }) async {
    try {
      // Prepara i parametri per la ricerca
      final queryParams = <String, dynamic>{
        'limit': limit,
        'orderBy': 'firstName',
        'orderDir': 'ASC',
      };

      // Aggiungi il termine di ricerca se presente
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryParams['q'] = searchQuery.trim();
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/search-user'),
        headers: _headers,
        body: json.encode(queryParams),
      );

      print('📡 Search-user response status: ${response.statusCode}');
      print('📄 Search-user response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rows = responseData['rows'] ?? [];
        final int total = responseData['total'] ?? 0;

        print(
          '✅ Search-user found $total total users, returning ${rows.length} rows',
        );

        final users = rows.map((userJson) {
          // Adatta i dati dal formato della Edge Function al formato UserData
          final adaptedData = _adaptUserDataFromEdgeFunction(userJson);
          print(
            '🔄 Adapting user: ${adaptedData['email']} -> ${adaptedData['fullName']}',
          );
          return UserData.fromJson(adaptedData);
        }).toList();

        print('🎯 Returning ${users.length} adapted users');
        return users;
      } else {
        print(
          '❌ Error from search-user: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error calling search-user Edge Function: $e');
      return [];
    }
  }

  /// Adatta i dati utente dal formato della Edge Function al formato UserData
  static Map<String, dynamic> _adaptUserDataFromEdgeFunction(
    Map<String, dynamic> edgeData,
  ) {
    // Gestisci i casi in cui firstName/lastName sono null
    final firstName = edgeData['firstName'];
    final lastName = edgeData['lastName'];
    final email = edgeData['email'] ?? '';

    // Se fullName è disponibile, usalo; altrimenti costruiscilo da firstName/lastName
    String displayName;
    if (edgeData['fullName'] != null &&
        edgeData['fullName'].toString().trim().isNotEmpty) {
      displayName = edgeData['fullName'].toString().trim();
    } else if (firstName != null && lastName != null) {
      displayName = '$firstName $lastName'.trim();
    } else if (firstName != null) {
      displayName = firstName.toString().trim();
    } else if (lastName != null) {
      displayName = lastName.toString().trim();
    } else {
      // Se non c'è nome, usa la parte prima dell'@ dell'email
      displayName = email.split('@').first;
    }

    return {
      'idUser': edgeData['idUser'],
      'firstName': firstName ?? displayName.split(' ').first,
      'lastName':
          lastName ??
          (displayName.split(' ').length > 1
              ? displayName.split(' ').skip(1).join(' ')
              : ''),
      'fullName': displayName,
      'email': email,
      'phone': edgeData['phone'],
      'dateOfBirth': edgeData['dateOfBirth'],
      'address': edgeData['address'],
      'city': edgeData['city'],
      'state': edgeData['state'],
      'postalCode': edgeData['postalCode'],
      'countryCode': edgeData['countryCode'],
      'profilePicture': edgeData['profilePicture'],
      'gender': edgeData['gender'],
      'createdAt': edgeData['createdAt'],
      'updatedAt': edgeData['updatedAt'],
    };
  }

  /// Filtra gli utenti che hanno accettato certificazioni per una legal entity specifica
  static Future<List<UserData>> _filterUsersByAcceptedCertifications({
    required List<UserData> users,
    required String legalEntityId,
  }) async {
    if (users.isEmpty) return [];

    try {
      // Ottieni le certificazioni accettate per questa legal entity
      final acceptedUserIds =
          await _getUsersWithAcceptedCertificationsForLegalEntity(
            legalEntityId,
          );

      if (acceptedUserIds.isEmpty) {
        print('ℹ️ No users have accepted certifications for this legal entity');
        return [];
      }

      // Filtra gli utenti che hanno accettato certificazioni
      final filteredUsers = users.where((user) {
        return acceptedUserIds.contains(user.idUser);
      }).toList();

      return filteredUsers;
    } catch (e) {
      print('❌ Error filtering users by accepted certifications: $e');
      return [];
    }
  }

  /// Ottiene gli ID degli utenti che hanno accettato certificazioni per una legal entity
  static Future<Set<String>> _getUsersWithAcceptedCertificationsForLegalEntity(
    String legalEntityId,
  ) async {
    try {
      // Prima ottieni tutte le certificazioni per questa legal entity
      final certificationsResponse = await http.get(
        Uri.parse(
          '$_baseUrl/functions/v1/certifications?id_legal_entity=$legalEntityId&limit=1000',
        ),
        headers: _headers,
      );

      if (certificationsResponse.statusCode != 200) {
        print(
          '❌ Error getting certifications: ${certificationsResponse.statusCode}',
        );
        return <String>{};
      }

      final certificationsData = json.decode(certificationsResponse.body);
      final List<dynamic> certifications = certificationsData['data'] ?? [];

      if (certifications.isEmpty) {
        print('ℹ️ No certifications found for legal entity: $legalEntityId');
        return <String>{};
      }

      // Raccogli tutti gli ID delle certificazioni
      final certificationIds = certifications
          .map((cert) => cert['id_certification'] as String)
          .toList();

      print(
        '🔍 Found ${certificationIds.length} certifications for legal entity',
      );

      // Ottieni gli utenti che hanno accettato queste certificazioni
      final acceptedUserIds = <String>{};

      // Processa in batch per evitare query troppo lunghe
      const batchSize = 10;
      for (int i = 0; i < certificationIds.length; i += batchSize) {
        final batch = certificationIds.skip(i).take(batchSize).toList();
        final batchUserIds = await _getAcceptedUserIdsForCertificationBatch(
          batch,
        );
        acceptedUserIds.addAll(batchUserIds);
      }

      print(
        '✅ Found ${acceptedUserIds.length} users with accepted certifications',
      );
      return acceptedUserIds;
    } catch (e) {
      print(
        '❌ Error getting users with accepted certifications for legal entity: $e',
      );
      return <String>{};
    }
  }

  /// Ottiene gli ID degli utenti che hanno accettato le certificazioni in un batch
  static Future<Set<String>> _getAcceptedUserIdsForCertificationBatch(
    List<String> certificationIds,
  ) async {
    try {
      if (certificationIds.isEmpty) return <String>{};

      // Query per ottenere gli utenti che hanno accettato queste certificazioni
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/rest/v1/certification_user?select=id_user&id_certification=in.(${certificationIds.join(',')})&status=eq.accepted',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> certUsers = json.decode(response.body);
        final userIds = certUsers.map((cu) => cu['id_user'] as String).toSet();

        return userIds;
      } else {
        print('❌ Error getting certification users: ${response.statusCode}');
        return <String>{};
      }
    } catch (e) {
      print('❌ Error getting accepted user IDs for certification batch: $e');
      return <String>{};
    }
  }

  /// Fallback method: usa query diretta se RPC non funziona
  static Future<List<UserData>> _getUsersViaDirectQuery(
    String legalEntityId,
    String? searchQuery,
    int limit,
  ) async {
    try {
      print('🔄 Using direct query fallback...');

      // Prima ottieni le certificazioni per questa legal entity
      final certificationsResponse = await http.get(
        Uri.parse(
          '$_baseUrl/functions/v1/certifications?id_legal_entity=$legalEntityId&limit=1000',
        ),
        headers: _headers,
      );

      if (certificationsResponse.statusCode != 200) {
        print(
          '❌ Error getting certifications: ${certificationsResponse.statusCode}',
        );
        return [];
      }

      final certificationsData = json.decode(certificationsResponse.body);
      final List<dynamic> certifications = certificationsData['data'] ?? [];

      if (certifications.isEmpty) {
        print('ℹ️ No certifications found for legal entity: $legalEntityId');
        return [];
      }

      // Raccogli tutti gli ID delle certificazioni
      final certificationIds = certifications
          .map((cert) => cert['id_certification'] as String)
          .toList();

      print('🔍 Found ${certificationIds.length} certifications');

      // Ora ottieni gli utenti che hanno accettato queste certificazioni
      List<UserData> allUsers = [];

      // Processa in batch per evitare query troppo lunghe
      const batchSize = 10;
      for (int i = 0; i < certificationIds.length; i += batchSize) {
        final batch = certificationIds.skip(i).take(batchSize).toList();
        final batchUsers = await _getUsersForCertificationBatch(batch);
        allUsers.addAll(batchUsers);
      }

      // Rimuovi duplicati basandosi sull'ID utente
      final uniqueUsers = <String, UserData>{};
      for (final user in allUsers) {
        uniqueUsers[user.idUser] = user;
      }

      List<UserData> result = uniqueUsers.values.toList();

      // Applica filtro di ricerca se presente
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final searchTerm = searchQuery.trim().toLowerCase();
        result = result.where((user) {
          final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'
              .toLowerCase();
          return user.firstName?.toLowerCase().contains(searchTerm) == true ||
              user.lastName?.toLowerCase().contains(searchTerm) == true ||
              user.email.toLowerCase().contains(searchTerm) ||
              fullName.contains(searchTerm);
        }).toList();
      }

      // Ordina per nome
      result.sort((a, b) {
        final nameA = '${a.firstName ?? ''} ${a.lastName ?? ''}'.trim();
        final nameB = '${b.firstName ?? ''} ${b.lastName ?? ''}'.trim();
        return nameA.compareTo(nameB);
      });

      // Limita i risultati
      if (result.length > limit) {
        result = result.take(limit).toList();
      }

      print(
        '✅ Found ${result.length} unique users with accepted certifications',
      );
      return result;
    } catch (e) {
      print('❌ Error in direct query fallback: $e');
      return [];
    }
  }

  /// Ottiene gli utenti per un batch di certificazioni
  static Future<List<UserData>> _getUsersForCertificationBatch(
    List<String> certificationIds,
  ) async {
    try {
      // Qui dovresti implementare la logica per ottenere gli utenti
      // che hanno accettato le certificazioni specificate
      // Per ora restituisco una lista vuota come placeholder

      // TODO: Implementa la query per ottenere certification_users
      // con status = 'accepted' per le certificazioni specificate
      // e poi ottieni i dati degli utenti

      print(
        '🔄 Getting users for ${certificationIds.length} certifications...',
      );

      // Query mockup - dovrai adattarla al tuo database
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/rest/v1/certification_user?select=id_user&id_certification=in.(${certificationIds.join(',')})&status=eq.accepted',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> certUsers = json.decode(response.body);
        final userIds = certUsers
            .map((cu) => cu['id_user'] as String)
            .toSet()
            .toList();

        if (userIds.isNotEmpty) {
          return await _getUsersByIds(userIds);
        }
      }

      return [];
    } catch (e) {
      print('❌ Error getting users for certification batch: $e');
      return [];
    }
  }

  /// Ottiene i dati degli utenti per una lista di ID
  static Future<List<UserData>> _getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/rest/v1/user?select=*&idUser=in.(${userIds.join(',')})',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        return users.map((userJson) {
          // Adatta i nomi dei campi se necessario
          final adaptedJson = {
            'idUser': userJson['idUser'],
            'firstName': userJson['firstName'],
            'lastName': userJson['lastName'],
            'email': userJson['email'],
            'phone': userJson['phone'],
            'dateOfBirth': userJson['dateOfBirth'],
            'address': userJson['address'],
            'city': userJson['city'],
            'state': userJson['state'],
            'postalCode': userJson['postalCode'],
            'countryCode': userJson['countryCode'],
            'profilePicture': userJson['profilePicture'],
            'gender': userJson['gender'],
            'createdAt': userJson['createdAt'],
            'updatedAt': userJson['updatedAt'],
          };
          return UserData.fromJson(adaptedJson);
        }).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error getting users by IDs: $e');
      return [];
    }
  }

  /// Verifica se un utente ha già accettato certificazioni per una legal entity
  static Future<bool> hasUserAcceptedCertifications({
    required String userId,
    required String legalEntityId,
  }) async {
    try {
      final users = await getUsersWithAcceptedCertifications(
        legalEntityId: legalEntityId,
        limit: 1000,
      );

      return users.any((user) => user.idUser == userId);
    } catch (e) {
      print('❌ Error checking if user has accepted certifications: $e');
      return false;
    }
  }
}
