import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

/// Classe per gestire le risposte tipizzate delle Edge Functions
class EdgeFunctionResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  EdgeFunctionResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  @override
  String toString() {
    return 'EdgeFunctionResponse(success: $success, error: $error, message: $message)';
  }
}

/// Servizio base per gestire le chiamate alle Edge Functions di Supabase
class EdgeFunctionService {
  static final _supabaseService = SupabaseService();
  static final _client = _supabaseService.client;

  /// Metodo per health check GET (senza body)
  static Future<Map<String, dynamic>> healthCheck(String functionName) async {
    try {
      debugPrint(
        '🏥 EdgeFunctionService: Health check for function $functionName',
      );
      debugPrint(
        '🏥 EdgeFunctionService: Supabase URL: ${SupabaseService.supabaseUrl}',
      );
      debugPrint(
        '🏥 EdgeFunctionService: Current user: ${_client.auth.currentUser?.id}',
      );
      debugPrint(
        '🏥 EdgeFunctionService: Session exists: ${_client.auth.currentSession != null}',
      );

      // Per health check, facciamo una chiamata HTTP diretta GET
      final session = _client.auth.currentSession;

      if (session == null) {
        throw Exception('No active session for health check');
      }

      final response = await _client.functions.invoke(
        functionName,
        body: null, // Body null per triggerare GET
      );

      debugPrint(
        '🏥 EdgeFunctionService: Health check response status: ${response.status}',
      );
      debugPrint(
        '🏥 EdgeFunctionService: Health check response data: ${response.data}',
      );

      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Risposta vuota dalla funzione $functionName');
      }
    } catch (e) {
      debugPrint(
        '❌ EdgeFunctionService: Health check failed for $functionName: $e',
      );
      throw Exception('Health check failed for $functionName: $e');
    }
  }

  /// Metodo generico per chiamare una Edge Function
  static Future<Map<String, dynamic>> invokeFunction(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('🚀 EdgeFunctionService: Calling function $functionName');
      debugPrint('🚀 EdgeFunctionService: Request body: $body');
      debugPrint(
        '🚀 EdgeFunctionService: Supabase URL: ${SupabaseService.supabaseUrl}',
      );
      debugPrint(
        '🚀 EdgeFunctionService: Current user: ${_client.auth.currentUser?.id}',
      );
      debugPrint(
        '🚀 EdgeFunctionService: Session exists: ${_client.auth.currentSession != null}',
      );

      debugPrint(
        '🚀 EdgeFunctionService: About to call _client.functions.invoke...',
      );
      final response = await _client.functions
          .invoke(functionName, body: body)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏰ Timeout calling function $functionName');
              throw Exception('Timeout calling function $functionName');
            },
          );
      debugPrint('🚀 EdgeFunctionService: Edge function call completed');

      debugPrint('🔄 EdgeFunctionService: Response status: ${response.status}');
      debugPrint('🔄 EdgeFunctionService: Response data: ${response.data}');
      debugPrint(
        '🔄 EdgeFunctionService: Response type: ${response.data.runtimeType}',
      );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('🔄 EdgeFunctionService: Parsed data: $data');
        return data;
      } else {
        debugPrint('❌ EdgeFunctionService: Empty response from $functionName');
        throw Exception('Risposta vuota dalla funzione $functionName');
      }
    } catch (e) {
      debugPrint(
        '❌ EdgeFunctionService: Error calling function $functionName: $e',
      );
      debugPrint('❌ EdgeFunctionService: Error type: ${e.runtimeType}');
      debugPrint('❌ EdgeFunctionService: Error details: ${e.toString()}');

      // Handle specific error types
      if (e.toString().contains('Failed to fetch')) {
        throw Exception(
          'Network error: Unable to connect to $functionName. Please check your internet connection.',
        );
      } else if (e.toString().contains('ClientException')) {
        throw Exception(
          'Connection error: Unable to reach $functionName. Please try again later.',
        );
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Timeout error: $functionName took too long to respond. Please try again.',
        );
      } else if (e.toString().contains('Function not found')) {
        throw Exception(
          'Function $functionName not found. Please check if the function is deployed.',
        );
      } else if (e.toString().contains('Unauthorized')) {
        throw Exception(
          'Unauthorized: Please check your authentication and permissions.',
        );
      }

      throw Exception('Errore chiamando la funzione $functionName: $e');
    }
  }

  /// Metodo generico per chiamare una Edge Function con gestione errori avanzata
  static Future<EdgeFunctionResponse<T>> invokeFunctionTyped<T>(
    String functionName,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.functions
          .invoke(functionName, body: body)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏰ Timeout calling function $functionName');
              throw Exception('Timeout calling function $functionName');
            },
          );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          return EdgeFunctionResponse<T>(
            success: true,
            data: fromJson(data['data']),
            message: data['message'],
          );
        } else {
          return EdgeFunctionResponse<T>(
            success: false,
            error: data['error'] ?? 'Errore sconosciuto',
            message: data['message'],
          );
        }
      } else {
        return EdgeFunctionResponse<T>(
          success: false,
          error: 'Risposta vuota dalla funzione $functionName',
        );
      }
    } catch (e) {
      return EdgeFunctionResponse<T>(
        success: false,
        error: 'Errore chiamando la funzione $functionName: $e',
      );
    }
  }

  /// Metodo per chiamare funzioni che ritornano solo status/messaggio
  static Future<EdgeFunctionResponse<void>> invokeFunctionSimple(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.functions
          .invoke(functionName, body: body)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏰ Timeout calling function $functionName');
              throw Exception('Timeout calling function $functionName');
            },
          );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        return EdgeFunctionResponse<void>(
          success: data['success'] == true,
          error: data['error'],
          message: data['message'],
        );
      } else {
        return EdgeFunctionResponse<void>(
          success: false,
          error: 'Risposta vuota dalla funzione $functionName',
        );
      }
    } catch (e) {
      return EdgeFunctionResponse<void>(
        success: false,
        error: 'Errore chiamando la funzione $functionName: $e',
      );
    }
  }

  /// Chiama l'edge function create-legal-entity
  static Future<Map<String, dynamic>?> createLegalEntity({
    required Map<String, dynamic> legalEntityData,
    String? accessToken,
  }) async {
    try {
      final response = await invokeFunction(
        'create-legal-entity',
        legalEntityData,
      );
      return response;
    } catch (e) {
      debugPrint('❌ Edge function call error: $e');
      rethrow;
    }
  }

  /// Chiama l'edge function create-user (se esiste)
  static Future<Map<String, dynamic>?> createUser({
    required Map<String, dynamic> userData,
    String? accessToken,
  }) async {
    try {
      final response = await invokeFunction('create-user', userData);
      return response;
    } catch (e) {
      debugPrint('❌ Create user edge function call error: $e');
      rethrow;
    }
  }

  /// Chiama l'edge function create-legal-entity-with-user
  static Future<Map<String, dynamic>?> createLegalEntityWithUser({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> legalEntityData,
    required String password,
  }) async {
    try {
      final requestBody = {
        'userData': {...userData, 'password': password},
        'legalEntityData': legalEntityData,
      };
      final response = await invokeFunction(
        'create-legal-entity-with-user',
        requestBody,
      );
      return response;
    } catch (e) {
      debugPrint(
        '❌ Create legal entity with user edge function call error: $e',
      );
      rethrow;
    }
  }

  /// Chiama l'edge function get-legal-entity-by-iduser per ottenere le legal entity create dall'utente
  static Future<Map<String, dynamic>?> getLegalEntitiesByUser({
    required String userId,
    String? accessToken,
  }) async {
    try {
      final requestBody = {'id_user': userId};
      final response = await invokeFunction(
        'get-legal-entity-by-iduser',
        requestBody,
      );
      return response;
    } catch (e) {
      debugPrint('❌ Get legal entities by user call error: $e');
      rethrow;
    }
  }

  /// Chiama l'edge function get-legal-entities-by-user per ottenere le legal entity associate all'utente tramite certifier
  static Future<Map<String, dynamic>?> getLegalEntitiesByUserViaCertifier({
    required String userId,
    String? accessToken,
  }) async {
    try {
      final requestBody = {'id_user': userId};
      final response = await invokeFunction(
        'get-legal-entities-by-user',
        requestBody,
      );
      return response;
    } catch (e) {
      debugPrint('❌ Get legal entities by user via certifier call error: $e');
      rethrow;
    }
  }

  /// Chiama l'edge function post-signup-link-certifier per collegare un utente a un certifier
  static Future<Map<String, dynamic>?> postSignupLinkCertifier({
    required String email,
    String? firstName,
    String? lastName,
    String? idUser,
  }) async {
    try {
      final requestBody = {
        'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (idUser != null) 'id_user': idUser,
      };
      final response = await invokeFunction(
        'post-signup-link-certifier',
        requestBody,
      );
      return response;
    } catch (e) {
      debugPrint('❌ Post signup link certifier call error: $e');
      rethrow;
    }
  }

  /// Chiama l'edge function get-legal-entities per ottenere tutte le legal entities
  static Future<Map<String, dynamic>?> getAllLegalEntities({
    String? status,
  }) async {
    try {
      final Map<String, dynamic> requestBody = status != null ? {'status': status} : <String, dynamic>{};
      final response = await invokeFunction(
        'get-legal-entities',
        requestBody,
      );
      return response;
    } catch (e) {
      debugPrint('❌ Get all legal entities call error: $e');
      rethrow;
    }
  }
}
