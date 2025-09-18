import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user.dart';

class UserSearchService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  /// Cerca utenti per nome, email o ID
  static Future<List<User>> searchUsers(String query) async {
    try {
      print('🔍 Searching users with query: $query');

      // Usa la RPC per cercare utenti
      final response = await http.post(
        Uri.parse('$_baseUrl/rest/v1/rpc/search_users'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'search_term': query,
          'limit_count': 10,
        }),
      );

      print('📊 User search response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((userData) => User.fromJson(userData)).toList();
      } else {
        print('❌ Error searching users: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// Cerca utenti per email specifica
  static Future<User?> getUserByEmail(String email) async {
    try {
      print('🔍 Getting user by email: $email');

      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/user?email=eq.$email&select=*'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
        },
      );

      print('📊 User by email response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return User.fromJson(data.first);
        }
        return null;
      } else {
        print('❌ Error getting user by email: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  /// Cerca utenti per ID specifico
  static Future<User?> getUserById(String userId) async {
    try {
      print('🔍 Getting user by ID: $userId');

      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/user?id_user=eq.$userId&select=*'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
        },
      );

      print('📊 User by ID response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return User.fromJson(data.first);
        }
        return null;
      } else {
        print('❌ Error getting user by ID: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  /// Ottiene tutti gli utenti (con paginazione)
  static Future<List<User>> getAllUsers({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      print('🔍 Getting all users with offset: $offset, limit: $limit');

      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/user?select=*&offset=$offset&limit=$limit&order=created_at.desc'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
        },
      );

      print('📊 All users response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((userData) => User.fromJson(userData)).toList();
      } else {
        print('❌ Error getting all users: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }
}
