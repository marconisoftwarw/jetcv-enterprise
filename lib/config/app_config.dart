class AppConfig {
  static const String appName = 'JetCV Enterprise';
  static const String appVersion = '1.0.0';

  // App configuration
  static const String appUrl = String.fromEnvironment(
    'APP_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Environment configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Supabase configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://skqsuxmdfqxbkhmselaz.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrcXN1eG1kZnF4YmtobXNlbGF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwNjQxMDMsImV4cCI6MjA3MTY0MDEwM30.NkwMkK6wZVPv2G_U39Q-rOMT5yUKLvPePnfXHKMR6JU',
  );

  // API endpoints
  static const String baseApiUrl = String.fromEnvironment(
    'BASE_API_URL',
    defaultValue: 'https://skqsuxmdfqxbkhmselaz.supabase.co',
  );

  // SMTP configuration for AWS SES
  static const String smtpHost = String.fromEnvironment(
    'SMTP_HOST',
    defaultValue: 'email-smtp.us-east-1.amazonaws.com',
  );

  static const int smtpPort = int.fromEnvironment(
    'SMTP_PORT',
    defaultValue: 587, // TLS port
  );

  static const String smtpUsername = String.fromEnvironment(
    'SMTP_USERNAME',
    defaultValue: 'AKIAW7RD7Q2X765RMDPT',
  );

  static const String smtpPassword = String.fromEnvironment(
    'SMTP_PASSWORD',
    defaultValue: 'BLKakh10pvzFJmkSWNxzY3U57oxCtrpHAt/KNo+JknXr',
  );

  static const String smtpFromEmail = String.fromEnvironment(
    'SMTP_FROM_EMAIL',
    defaultValue: 'noreply@jetcv.com',
  );

  // Feature flags
  static const bool enableGoogleSignIn = true;
  static const bool enableEmailSignIn = true;
  static const bool enableDebugMode = false;

  // App settings
  static const int sessionTimeoutMinutes = 60;
  static const int maxImageSizeMB = 10;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Validation rules
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  static const int maxPhoneLength = 20;
  static const int maxAddressLength = 500;

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Colors
  static const int primaryColorValue = 0xFF2563EB;
  static const int secondaryColorValue = 0xFF64748B;
  static const int successColorValue = 0xFF10B981;
  static const int errorColorValue = 0xFFEF4444;
  static const int warningColorValue = 0xFFF59E0B;
  static const int infoColorValue = 0xFF3B82F6;
}
