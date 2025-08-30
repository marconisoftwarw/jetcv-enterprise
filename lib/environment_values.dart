import 'dart:convert';
import 'package:flutter/services.dart';

class FFDevEnvironmentValues {
  static const String currentEnvironment = 'Development';
  static const String environmentValuesPath =
      'assets/environment_values/environment.json';

  static final FFDevEnvironmentValues _instance =
      FFDevEnvironmentValues._internal();

  factory FFDevEnvironmentValues() {
    return _instance;
  }

  FFDevEnvironmentValues._internal();

  Future<void> initialize() async {
    try {
      final String response =
          await rootBundle.loadString(environmentValuesPath);
      final data = await json.decode(response);
      _supabaseApiUrlCommon = data['supabaseApiUrlCommon'];
      _supabaseAnonKeyCommon = data['supabaseAnonKeyCommon'];
      _googleAuthIosClientIdEnterprise =
          data['googleAuthIosClientIdEnterprise'];
      _googleAuthWebClientIdEnterprise =
          data['googleAuthWebClientIdEnterprise'];
      _name = data['name'];
      _supabaseApiUrlEnterpriseAuth = data['supabaseApiUrlEnterpriseAuth'];
      _supabaseAnonKeyEnterpriseAuth = data['supabaseAnonKeyEnterpriseAuth'];
      _testUserId = data['testUserId'];
      _callbackUrlVeriffWeb = data['callbackUrlVeriffWeb'];
    } catch (e) {
      print('Error loading environment values: $e');
    }
  }

  String _supabaseApiUrlCommon = '';
  String get supabaseApiUrlCommon => _supabaseApiUrlCommon;

  String _supabaseAnonKeyCommon = '';
  String get supabaseAnonKeyCommon => _supabaseAnonKeyCommon;

  String _googleAuthIosClientIdEnterprise = '';
  String get googleAuthIosClientIdEnterprise =>
      _googleAuthIosClientIdEnterprise;

  String _googleAuthWebClientIdEnterprise = '';
  String get googleAuthWebClientIdEnterprise =>
      _googleAuthWebClientIdEnterprise;

  String _name = '';
  String get name => _name;

  String _supabaseApiUrlEnterpriseAuth = '';
  String get supabaseApiUrlEnterpriseAuth => _supabaseApiUrlEnterpriseAuth;

  String _supabaseAnonKeyEnterpriseAuth = '';
  String get supabaseAnonKeyEnterpriseAuth => _supabaseAnonKeyEnterpriseAuth;

  String _testUserId = '';
  String get testUserId => _testUserId;

  String _callbackUrlVeriffWeb = '';
  String get callbackUrlVeriffWeb => _callbackUrlVeriffWeb;
}
