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
  String get supabaseUrl => 'https://skqsuxmdfqxbkhmselaz.supabase.co';
  
  @override
  String get supabaseAnonKey => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrcXN1eG1kZnF4YmtobXNlbGF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNjQxMDMsImV4cCI6MjA3MTY0MDEwM30.NkwMkK6wZVPv2G_U39Q-rOMT5yUKLvPePnfXHKMR6JU';
  
  @override
  String get supabaseServiceRoleKey => 'your-service-role-key';
  
  @override
  String get emailServiceUrl => 'https://api.sendgrid.com/v3/mail/send';
  
  @override
  String get emailServiceApiKey => 'your-sendgrid-api-key';
  
  @override
  String get appName => 'JetCV Enterprise (Test)';
  
  @override
  String get appVersion => '1.0.0-test';
  
  @override
  bool get isProduction => false;
}

class ProductionEnvironmentConfig implements EnvironmentConfig {
  @override
  String get supabaseUrl => 'https://skqsuxmdfqxbkhmselaz.supabase.co';
  
  @override
  String get supabaseAnonKey => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrcXN1eG1kZnF4YmtobXNlbGF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNjQxMDMsImV4cCI6MjA3MTY0MDEwM30.NkwMkK6wZVPv2G_U39Q-rOMT5yUKLvPePnfXHKMR6JU';
  
  @override
  String get supabaseServiceRoleKey => 'your-service-role-key';
  
  @override
  String get emailServiceUrl => 'https://api.sendgrid.com/v3/mail/send';
  
  @override
  String get emailServiceApiKey => 'your-sendgrid-api-key';
  
  @override
  String get appName => 'JetCV Enterprise';
  
  @override
  String get appVersion => '1.0.0';
  
  @override
  bool get isProduction => true;
}
