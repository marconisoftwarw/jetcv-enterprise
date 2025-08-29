import 'package:flutter/foundation.dart';

class AppConfig {
  static late final EnvironmentConfig _config;
  
  static void initialize() {
    if (kDebugMode) {
      // In debug mode, use test environment
      _config = TestEnvironmentConfig();
    } else {
      // In release mode, use production environment
      _config = ProductionEnvironmentConfig();
    }
  }
  
  static EnvironmentConfig get config => _config;
  
  static bool get isProduction => _config.isProduction;
  static String get supabaseUrl => _config.supabaseUrl;
  static String get supabaseAnonKey => _config.supabaseAnonKey;
  static String get supabaseServiceRoleKey => _config.supabaseServiceRoleKey;
  static String get emailServiceUrl => _config.emailServiceUrl;
  static String get emailServiceApiKey => _config.emailServiceApiKey;
  static String get appName => _config.appName;
  static String get appVersion => _config.appVersion;
}

abstract class EnvironmentConfig {
  String get supabaseUrl;
  String get supabaseAnonKey;
  String get supabaseServiceRoleKey;
  String get emailServiceUrl;
  String get emailServiceApiKey;
  String get appName;
  String get appVersion;
  bool get isProduction;
}

class TestEnvironmentConfig implements EnvironmentConfig {
  @override
  String get supabaseUrl => 'YOUR_TEST_SUPABASE_URL';
  
  @override
  String get supabaseAnonKey => 'YOUR_TEST_SUPABASE_ANON_KEY';
  
  @override
  String get supabaseServiceRoleKey => 'YOUR_TEST_SUPABASE_SERVICE_ROLE_KEY';
  
  @override
  String get emailServiceUrl => 'YOUR_TEST_EMAIL_SERVICE_URL';
  
  @override
  String get emailServiceApiKey => 'YOUR_TEST_EMAIL_SERVICE_API_KEY';
  
  @override
  String get appName => 'JetCV Enterprise (Test)';
  
  @override
  String get appVersion => '1.0.0-test';
  
  @override
  bool get isProduction => false;
}

class ProductionEnvironmentConfig implements EnvironmentConfig {
  @override
  String get supabaseUrl => 'YOUR_PROD_SUPABASE_URL';
  
  @override
  String get supabaseAnonKey => 'YOUR_PROD_SUPABASE_ANON_KEY';
  
  @override
  String get supabaseServiceRoleKey => 'YOUR_PROD_SUPABASE_SERVICE_ROLE_KEY';
  
  @override
  String get emailServiceUrl => 'YOUR_PROD_EMAIL_SERVICE_URL';
  
  @override
  String get emailServiceApiKey => 'YOUR_PROD_EMAIL_SERVICE_API_KEY';
  
  @override
  String get appName => 'JetCV Enterprise';
  
  @override
  String get appVersion => '1.0.0';
  
  @override
  bool get isProduction => true;
}
