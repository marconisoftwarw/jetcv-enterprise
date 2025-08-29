class AppConstants {
  // App Info
  static const String appName = 'JetCV Enterprise';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String adminRoute = '/admin';
  static const String legalEntityRoute = '/legal-entity';
  
  // Supabase Tables
  static const String usersTable = 'user';
  static const String legalEntitiesTable = 'legal_entity';
  static const String certificationsTable = 'certification';
  static const String certifiersTable = 'certifier';
  static const String cvTable = 'cv';
  static const String walletsTable = 'wallet';
  static const String countriesTable = 'country';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int maxPhoneLength = 20;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  
  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Legal Entity Status
  static const String legalEntityStatusPending = 'pending';
  static const String legalEntityStatusApproved = 'approved';
  static const String legalEntityStatusRejected = 'rejected';
  
  // User Types
  static const String userTypeAdmin = 'admin';
  static const String userTypeUser = 'user';
  static const String userTypeCertifier = 'certifier';
  
  // Certification Status
  static const String certificationStatusDraft = 'draft';
  static const String certificationStatusPending = 'pending';
  static const String certificationStatusApproved = 'approved';
  static const String certificationStatusRejected = 'rejected';
}
