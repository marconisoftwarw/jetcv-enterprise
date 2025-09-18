import '../models/certifier.dart';
import '../models/user.dart';
import '../services/email_service.dart';
import '../services/legal_entity_service.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Classe estesa per certificatori con dati utente
class CertifierWithUser {
  final Certifier certifier;
  final AppUser? user;
  final String? legalEntityName;

  CertifierWithUser({required this.certifier, this.user, this.legalEntityName});

  // Getters per accesso rapido ai dati utente
  String get fullName {
    if (user == null) return 'Nome non disponibile';

    // Mostra sempre firstName e lastName separatamente se disponibili
    String firstName = user!.firstName?.isNotEmpty == true
        ? user!.firstName!
        : '';
    String lastName =
        user!.lastName?.isNotEmpty == true && user!.lastName != 'N/A'
        ? user!.lastName!
        : '';

    // Combina firstName e lastName
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }

    // Se firstName e lastName sono entrambi null o vuoti, usa l'email
    if (user!.email?.isNotEmpty == true) {
      return user!.email!;
    }

    // Fallback finale
    return 'User ID: ${user!.idUser}';
  }

  String get email => user?.email ?? 'Email non disponibile';
  DateTime? get dateOfBirth => user?.dateOfBirth;
  String get dateOfBirthFormatted {
    if (dateOfBirth == null) return 'Data di nascita non disponibile';
    return '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year}';
  }

  String get initials => user?.initials ?? 'N/A';
  bool get hasUserData => user != null;
}

class CertifierService {
  final EmailService _emailService = EmailService();
  final LegalEntityService _legalEntityService = LegalEntityService();

  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
  };

  // Carica tutti i certificatori tramite Edge Function
  Future<List<Certifier>> getAllCertifiers() async {
    try {
      print('🔍 Getting all certifiers via Edge Function');

      // Usa Edge Function per recuperare tutti i certificatori
      final response = await http.get(
        Uri.parse('$_baseUrl/functions/v1/get-user-legal-entity'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Origin': 'http://localhost:8080',
        },
      );

      print(
        '📊 All certifiers response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final certifiersData = data['certifiers'] as List<dynamic>? ?? [];

        // Converti i dati della Edge Function nel formato Certifier
        final certifiers = certifiersData.map((item) {
          // Estrai i dati utente se presenti
          final userData = item['user'];
          print(
            '🔍 User data for certifier ${item['id_certifier']}: $userData',
          );

          return Certifier(
            idCertifier: item['id_certifier'],
            role: item['role'],
            active: item['active'] ?? true,
            idUser: item['id_user'],
            idLegalEntity: item['id_legal_entity'],
            // Aggiungi altri campi se necessario
          );
        }).toList();

        print(
          '✅ Found ${certifiers.length} total certifiers via Edge Function',
        );
        return certifiers;
      } else {
        print(
          '❌ Error getting all certifiers: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error getting all certifiers: $e');
      return [];
    }
  }

  // Carica certificatori per legal entity tramite Edge Function
  Future<List<Certifier>> getCertifiersByLegalEntity(
    String legalEntityId,
  ) async {
    try {
      print('🔍 Getting certifiers for legal entity: $legalEntityId');

      // Usa Edge Function per recuperare i certificatori
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/functions/v1/get-user-legal-entity?id_legal_entity=$legalEntityId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Origin': 'http://localhost:8080',
        },
      );

      print(
        '📊 Certifiers response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final certifiersData = data['certifiers'] as List<dynamic>? ?? [];

        // Converti i dati della Edge Function nel formato Certifier
        final certifiers = certifiersData.map((item) {
          return Certifier(
            idCertifier: item['id_certifier'],
            role: item['role'],
            active: item['active'] ?? true,
            idUser: item['id_user'],
            idLegalEntity: item['id_legal_entity'],
            // Aggiungi altri campi se necessario
          );
        }).toList();

        print('✅ Found ${certifiers.length} certifiers via Edge Function');
        return certifiers;
      } else {
        print(
          '❌ Error getting certifiers: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error getting certifiers by legal entity: $e');
      return [];
    }
  }

  // Carica certificatore per ID
  Future<Certifier?> getCertifierById(String idCertifier) async {
    try {
      // TODO: Implementare chiamata al database
      return null;
    } catch (e) {
      print('Error getting certifier by ID: $e');
      return null;
    }
  }

  // Carica certificatore per utente
  Future<Certifier?> getCertifierByUser(String idUser) async {
    try {
      // TODO: Implementare chiamata al database
      return null;
    } catch (e) {
      print('Error getting certifier by user: $e');
      return null;
    }
  }

  // Crea un nuovo certificatore
  Future<bool> createCertifier(Certifier certifier) async {
    try {
      print('🔍 Creating certifier: ${certifier.idCertifier}');

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/certifier-crud'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Origin': 'http://localhost:8080',
        },
        body: json.encode({'operation': 'create', 'data': certifier.toJson()}),
      );

      print(
        '📊 Create certifier response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Certifier created successfully via Edge Function');
        return data['ok'] == true;
      } else {
        print(
          '❌ Error creating certifier: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error creating certifier: $e');
      return false;
    }
  }

  // Crea un certificatore con dati utente associato
  Future<Map<String, dynamic>?> createCertifierWithUser({
    required Map<String, dynamic> userData,
    required Certifier certifier,
  }) async {
    try {
      print('🔍 Creating certifier with user data');

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/certifier-crud'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Origin': 'http://localhost:8080',
        },
        body: json.encode({
          'operation': 'create_with_user',
          'userData': userData,
          'certifierData': certifier.toJson(),
        }),
      );

      print(
        '📊 Create certifier with user response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          print('✅ Certifier with user created successfully via Edge Function');
          return data['data']; // Returns both user and certifier data
        }
      }

      print(
        '❌ Error creating certifier with user: ${response.statusCode} - ${response.body}',
      );
      return null;
    } catch (e) {
      print('❌ Error creating certifier with user: $e');
      return null;
    }
  }

  // Aggiorna un certificatore esistente
  Future<bool> updateCertifier(Certifier certifier) async {
    try {
      // TODO: Implementare chiamata al database
      print('Updating certifier: ${certifier.idCertifier}');
      return true;
    } catch (e) {
      print('Error updating certifier: $e');
      return false;
    }
  }

  // Elimina un certificatore
  Future<bool> deleteCertifier(String idCertifier) async {
    try {
      // TODO: Implementare chiamata al database
      print('Deleting certifier: $idCertifier');
      return true;
    } catch (e) {
      print('Error deleting certifier: $e');
      return false;
    }
  }

  // Invita un nuovo certificatore
  Future<bool> inviteCertifier({
    required String email,
    required String legalEntityId,
    String? role,
    String? message,
  }) async {
    try {
      // Genera token di invito
      final invitationToken = _generateInvitationToken();

      // Crea certificatore con token di invito
      final certifier = Certifier(
        idLegalEntity: legalEntityId,
        role: role,
        invitationToken: invitationToken,
      );

      // Salva nel database
      final success = await createCertifier(certifier);
      if (!success) return false;

      // Invia email di invito
      final emailSent = await _emailService.sendCertifierInvitation(
        email: email,
        invitationToken: invitationToken,
        legalEntityId: legalEntityId,
        role: role,
        message: message,
      );

      return emailSent;
    } catch (e) {
      print('Error inviting certifier: $e');
      return false;
    }
  }

  // Accetta invito certificatore
  Future<bool> acceptCertifierInvitation({
    required String invitationToken,
    required String idUser,
  }) async {
    try {
      // Trova certificatore per token
      final certifier = await getCertifierByInvitationToken(invitationToken);
      if (certifier == null) return false;

      // Aggiorna certificatore con utente
      final updatedCertifier = certifier.copyWith(
        idUser: idUser,
        invitationToken: null, // Rimuovi token dopo accettazione
      );

      return await updateCertifier(updatedCertifier);
    } catch (e) {
      print('Error accepting certifier invitation: $e');
      return false;
    }
  }

  // Rifiuta invito certificatore
  Future<bool> rejectCertifierInvitation(String invitationToken) async {
    try {
      // Trova certificatore per token
      final certifier = await getCertifierByInvitationToken(invitationToken);
      if (certifier == null) return false;

      // Elimina certificatore
      return await deleteCertifier(certifier.idCertifier);
    } catch (e) {
      print('Error rejecting certifier invitation: $e');
      return false;
    }
  }

  // Carica certificatore per token di invito
  Future<Certifier?> getCertifierByInvitationToken(
    String invitationToken,
  ) async {
    try {
      // TODO: Implementare chiamata al database
      return null;
    } catch (e) {
      print('Error getting certifier by invitation token: $e');
      return null;
    }
  }

  // Verifica se un utente è certificatore
  Future<bool> isUserCertifier(String idUser) async {
    try {
      final certifier = await getCertifierByUser(idUser);
      return certifier != null && certifier.active;
    } catch (e) {
      print('Error checking if user is certifier: $e');
      return false;
    }
  }

  // Verifica se un utente è certificatore per una legal entity
  Future<bool> isUserCertifierForLegalEntity(
    String idUser,
    String legalEntityId,
  ) async {
    try {
      final certifier = await getCertifierByUser(idUser);
      return certifier != null &&
          certifier.active &&
          certifier.idLegalEntity == legalEntityId;
    } catch (e) {
      print('Error checking if user is certifier for legal entity: $e');
      return false;
    }
  }

  // Aggiorna stato KYC del certificatore
  Future<bool> updateCertifierKycStatus({
    required String idCertifier,
    required bool kycPassed,
    String? idKycAttempt,
  }) async {
    try {
      final certifier = await getCertifierById(idCertifier);
      if (certifier == null) return false;

      final updatedCertifier = certifier.copyWith(
        kycPassed: kycPassed,
        idKycAttempt: idKycAttempt,
      );

      return await updateCertifier(updatedCertifier);
    } catch (e) {
      print('Error updating certifier KYC status: $e');
      return false;
    }
  }

  // Genera token di invito
  String _generateInvitationToken() {
    // Genera un token di 43 caratteri come richiesto dal database
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-';
    final random = DateTime.now().millisecondsSinceEpoch;

    String result = '';
    for (int i = 0; i < 43; i++) {
      result += chars[random % chars.length];
    }

    return result;
  }

  // Carica statistiche certificatori
  Future<Map<String, int>> getCertifierStats(String legalEntityId) async {
    try {
      final certifiers = await getCertifiersByLegalEntity(legalEntityId);

      return {
        'total': certifiers.length,
        'active': certifiers.where((c) => c.active).length,
        'inactive': certifiers.where((c) => !c.active).length,
        'withKyc': certifiers.where((c) => c.hasKyc && c.isKycPassed).length,
        'withoutKyc': certifiers.where((c) => !c.hasKyc).length,
        'pendingInvitation': certifiers
            .where((c) => c.hasInvitationToken)
            .length,
      };
    } catch (e) {
      print('Error getting certifier stats: $e');
      return {};
    }
  }

  // Ottiene certificatori con dati utente per legal entity
  Future<List<CertifierWithUser>> getCertifiersWithUserByLegalEntity(
    String legalEntityId,
  ) async {
    try {
      print(
        '🔍 Getting certifiers with user data for legal entity: $legalEntityId',
      );

      String url;
      if (legalEntityId == 'all') {
        // Per admin, chiama senza parametri per ottenere tutti i certificatori
        url = '$_baseUrl/functions/v1/get-user-legal-entity';
      } else {
        // Per legal entity specifica
        url =
            '$_baseUrl/functions/v1/get-user-legal-entity?id_legal_entity=$legalEntityId';
      }

      // Usa Edge Function per recuperare i certificatori con dati utente
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Origin': 'http://localhost:8080',
        },
      );

      print(
        '📊 Certifiers with user data response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 Full Edge Function response: $data');
        final certifiersData = data['certifiers'] as List<dynamic>? ?? [];
        print('🔍 Certifiers data extracted: $certifiersData');

        // Converti i dati della Edge Function nel formato CertifierWithUser
        final certifiersWithUser = certifiersData.map((item) {
          print('🔍 Processing certifier item: $item');
          final userData = item['user'];
          print('🔍 User data from item: $userData');
          AppUser? user;

          if (userData != null) {
            try {
              // Debug dei dati utente prima del parsing
              print('🔍 User data keys: ${userData.keys.toList()}');
              print('🔍 User data idUser: ${userData['idUser']}');
              print('🔍 User data fullName: ${userData['fullName']}');
              print('🔍 User data firstName: ${userData['firstName']}');
              print('🔍 User data lastName: ${userData['lastName']}');
              print('🔍 User data email: ${userData['email']}');
              print('🔍 User data dateOfBirth: ${userData['dateOfBirth']}');

              user = AppUser.fromJson(userData);
              print('✅ Parsed user data successfully:');
              print('   - idUser: ${user.idUser}');
              print('   - fullName: ${user.fullName}');
              print('   - firstName: ${user.firstName}');
              print('   - lastName: ${user.lastName}');
              print('   - email: ${user.email}');
              print('   - dateOfBirth: ${user.dateOfBirth}');
            } catch (e) {
              print('❌ Error parsing user data: $e');
              print('❌ Raw user data was: $userData');

              // Fallback: crea un oggetto AppUser minimo
              try {
                user = AppUser(
                  idUser: userData['idUser'] ?? 'unknown',
                  idUserHash: userData['idUserHash'] ?? 'unknown',
                  fullName: userData['fullName'],
                  firstName: userData['firstName'],
                  lastName: userData['lastName'],
                  email: userData['email'],
                  dateOfBirth: userData['dateOfBirth'] != null
                      ? DateTime.tryParse(userData['dateOfBirth'])
                      : null,
                  createdAt: userData['createdAt'] != null
                      ? DateTime.tryParse(userData['createdAt']) ??
                            DateTime.now()
                      : DateTime.now(),
                );
                print(
                  '✅ Created fallback user: ${user.fullName} (${user.email})',
                );
              } catch (fallbackError) {
                print('❌ Fallback also failed: $fallbackError');
                user = null;
              }
            }
          } else {
            print(
              '⚠️ No user data found for certifier ${item['id_certifier']}',
            );
          }

          return CertifierWithUser(
            certifier: Certifier(
              idCertifier: item['id_certifier'],
              role: item['role'],
              active: item['active'] ?? true,
              idUser: item['id_user'],
              idLegalEntity: item['id_legal_entity'],
            ),
            user: user,
            legalEntityName: null, // Sarà popolato dopo
          );
        }).toList();

        print('✅ Found ${certifiersWithUser.length} certifiers with user data');

        // Recupera i nomi delle legal entities
        await _populateLegalEntityNames(certifiersWithUser);

        return certifiersWithUser;
      } else {
        print(
          '❌ Error getting certifiers with user data: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error getting certifiers with user data: $e');
      return [];
    }
  }

  // Ottiene i certificatori e utenti della legal entity tramite Edge Function
  Future<Map<String, dynamic>?> getLegalEntityUsers(
    String idLegalEntity,
  ) async {
    try {
      print('🔍 Getting legal entity users for ID: $idLegalEntity');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/functions/v1/get-user-legal-entity?id_legal_entity=$idLegalEntity',
        ),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Origin': 'http://localhost:8080',
        },
      );

      print(
        '📊 Legal entity users response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Legal entity users retrieved successfully');
        print('📊 Found ${data['certifiers']?.length ?? 0} certifiers');
        print(
          '📊 Found ${data['certification_users']?.length ?? 0} certification users',
        );
        print('📊 Found ${data['users_distinct']?.length ?? 0} distinct users');
        return data;
      } else {
        print(
          '❌ Error getting legal entity users: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error getting legal entity users: $e');
      return null;
    }
  }

  // Popola i nomi delle legal entities per i certificatori
  Future<void> _populateLegalEntityNames(
    List<CertifierWithUser> certifiersWithUser,
  ) async {
    try {
      // Raccoglie tutti gli ID delle legal entities uniche
      final legalEntityIds = certifiersWithUser
          .map((c) => c.certifier.idLegalEntity)
          .toSet()
          .toList();

      if (legalEntityIds.isEmpty) {
        print('⚠️ No legal entity IDs found');
        return;
      }

      print(
        '🔍 Populating legal entity names for ${legalEntityIds.length} entities',
      );

      // Per ora, crea una mappa temporanea con gli ID
      // In futuro si potrebbe implementare una chiamata alla Edge Function
      final legalEntityNamesMap = <String, String>{};

      for (final id in legalEntityIds) {
        legalEntityNamesMap[id] = 'Legal Entity ${id.substring(0, 8)}...';
      }

      // Aggiorna i certificatori con i nomi delle legal entities
      for (final certifierWithUser in certifiersWithUser) {
        final legalEntityId = certifierWithUser.certifier.idLegalEntity;
        final legalEntityName = legalEntityNamesMap[legalEntityId];

        if (legalEntityName != null) {
          // Crea un nuovo oggetto con il nome della legal entity
          final updatedCertifier = CertifierWithUser(
            certifier: certifierWithUser.certifier,
            user: certifierWithUser.user,
            legalEntityName: legalEntityName,
          );

          // Sostituisce l'oggetto nella lista
          final index = certifiersWithUser.indexOf(certifierWithUser);
          if (index != -1) {
            certifiersWithUser[index] = updatedCertifier;
          }
        }
      }

      print('✅ Legal entity names populated');
    } catch (e) {
      print('❌ Error populating legal entity names: $e');
    }
  }
}
