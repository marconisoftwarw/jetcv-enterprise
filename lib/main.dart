import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/legal_entity_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/certifier_provider.dart';
import 'providers/pricing_provider.dart';
import 'providers/theme_provider.dart';
import 'models/user.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/auth_callback_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'screens/auth/password_reset_form_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/public/public_home_screen.dart';
import 'screens/certification/create_certification_screen.dart';
import 'screens/certification/certification_detail_screen.dart';
import 'screens/certifiers/certifiers_screen.dart';
import 'screens/profile/user_profile_screen.dart';
import 'screens/settings/user_settings_screen.dart';
import 'screens/veriff/veriff_verification_screen.dart';
import 'screens/public/cv_list_screen.dart';
import 'screens/public/legal_entity_pricing_screen.dart';
import 'screens/public/legal_entity_public_registration_screen.dart';
import 'screens/public/legal_entity_invitation_details_screen.dart';
import 'screens/legal_entity/legal_entity_registration_screen.dart';
import 'widgets/global_floating_language_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const JetCVEnterpriseApp());
}

class JetCVEnterpriseApp extends StatelessWidget {
  const JetCVEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LegalEntityProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CertifierProvider()),
        ChangeNotifierProvider(create: (_) => PricingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> with WidgetsBindingObserver {
  late Future<void> _initializationFuture;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializationFuture = _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh authentication when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed - checking authentication status...');
      final authProvider = context.read<AuthProvider>();
      authProvider.checkAuthenticationStatus().then((isAuthenticated) {
        if (isAuthenticated) {
          print('✅ Authentication status restored on app resume');
        } else {
          print('ℹ️ No authentication found on app resume');
        }
      });
    }
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Initializing app...');
      final authProvider = context.read<AuthProvider>();
      final localeProvider = context.read<LocaleProvider>();

      print('🌍 Initializing LocaleProvider...');
      await localeProvider.loadSavedLocale();
      print(
        '✅ LocaleProvider initialized with locale: ${localeProvider.locale}',
      );

      print('🔐 Initializing AuthProvider...');
      await authProvider.initialize();
      print('✅ AuthProvider initialized');

      // Check authentication status after initialization
      print('🔍 Checking authentication status...');
      final isAuthenticated = await authProvider.checkAuthenticationStatus();
      print('🔍 Authentication status: $isAuthenticated');

      if (isAuthenticated) {
        print('✅ User is authenticated and state restored');
      } else {
        print('ℹ️ No authenticated user found');
      }

      // Initialize other providers
      print('🏢 Initializing LegalEntityProvider...');
      final legalEntityProvider = context.read<LegalEntityProvider>();
      await legalEntityProvider.initialize();
      print('✅ LegalEntityProvider initialized');

      // Listen to auth state changes
      authProvider.addListener(() {
        if (mounted) {
          // Use addPostFrameCallback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      });

      print('🚀 App initialization completed');
    } catch (e) {
      print('❌ App initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, LocaleProvider, ThemeProvider>(
      builder: (context, authProvider, localeProvider, themeProvider, child) {
        // Update theme provider with system brightness (moved to avoid build conflicts)
        final brightness = MediaQuery.of(context).platformBrightness;
        if (themeProvider.themeMode == ThemeMode.system) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            themeProvider.updateSystemTheme(brightness);
          });
        }

        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: AppConfig.enableDebugMode,
          navigatorKey: _navigatorKey,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('it', 'IT'),
            Locale('en', 'US'),
            Locale('de', 'DE'),
            Locale('fr', 'FR'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizationsDelegate(),
          ],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          builder: (context, child) {
            return Stack(
              children: [
                child ?? const SizedBox(),
                const GlobalFloatingLanguageButton(),
              ],
            );
          },
          home: FutureBuilder(
            future: _initializationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (snapshot.hasError) {
                return const SplashScreen();
              }

              // Se l'utente è autenticato e ha un utente valido, mostra la schermata appropriata
              if (authProvider.isAuthenticated &&
                  authProvider.currentUser != null) {
                // Check if user is admin
                if (authProvider.currentUser?.type == UserType.admin) {
                  return const AdminDashboardScreen();
                }
                return const HomeScreen();
              }

              // Se l'utente non è autenticato, mostra la home pubblica
              return const PublicHomeScreen();
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/password-reset': (context) => const PasswordResetScreen(),
            '/password-reset-form': (context) =>
                const PasswordResetFormScreen(),
            '/signup': (context) => const SignupScreen(),
            '/auth/callback': (context) => const AuthCallbackScreen(),
            '/home': (context) => const HomeScreen(),
            '/admin': (context) => const AdminDashboardScreen(),
            '/public': (context) => const PublicHomeScreen(),
            '/create-certification': (context) =>
                const CreateCertificationScreen(),
            '/profile': (context) => const UserProfileScreen(),
            '/settings': (context) => const UserSettingsScreen(),
            '/veriff': (context) => const VeriffVerificationScreen(),
            '/cv-list': (context) => const CVListScreen(),
            '/legal-entity/pricing': (context) =>
                const LegalEntityPricingScreen(),
            '/legal-entity/register': (context) =>
                const LegalEntityPublicRegistrationScreen(),
            '/legal-entity-registration': (context) =>
                const LegalEntityRegistrationScreen(),
          },
          onGenerateRoute: (settings) {
            // Handle direct URL access and ensure authentication state is restored
            print('🔄 Handling route: ${settings.name}');

            // Check if this is a protected route
            final protectedRoutes = [
              '/home',
              '/admin',
              '/create-certification',
              '/certification-detail',
              '/certifiers',
              '/profile',
              '/settings',
              '/veriff',
              '/cv-list',
              '/legal-entity',
            ];

            final isProtectedRoute = protectedRoutes.any(
              (route) => settings.name?.startsWith(route) == true,
            );

            if (isProtectedRoute) {
              // For protected routes, we need to ensure authentication is checked
              print('🔒 Protected route detected: ${settings.name}');
            }

            // Return the appropriate route
            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/signup':
                return MaterialPageRoute(builder: (_) => const SignupScreen());
              case '/password-reset':
                return MaterialPageRoute(
                  builder: (_) => const PasswordResetScreen(),
                );
              case '/auth/callback':
                return MaterialPageRoute(
                  builder: (_) => const AuthCallbackScreen(),
                );
              case '/home':
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              case '/admin':
                return MaterialPageRoute(
                  builder: (_) => const AdminDashboardScreen(),
                );
              case '/public':
                return MaterialPageRoute(
                  builder: (_) => const PublicHomeScreen(),
                );
              case '/create-certification':
                return MaterialPageRoute(
                  builder: (_) => const CreateCertificationScreen(),
                );
              case '/certification-detail':
                final args = settings.arguments as Map<String, dynamic>?;
                final certificationId = args?['certificationId'] as String?;
                final certificationData =
                    args?['certificationData'] as Map<String, dynamic>?;

                if (certificationId == null) {
                  // Invalid route, redirect to home
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                }

                return MaterialPageRoute(
                  builder: (_) => CertificationDetailScreen(
                    certificationId: certificationId,
                    certificationData: certificationData,
                  ),
                );
              case '/certifiers':
                return MaterialPageRoute(
                  builder: (_) => const CertifiersScreen(),
                );
              case '/profile':
                return MaterialPageRoute(
                  builder: (_) => const UserProfileScreen(),
                );
              case '/settings':
                return MaterialPageRoute(
                  builder: (_) => const UserSettingsScreen(),
                );
              case '/veriff':
                return MaterialPageRoute(
                  builder: (_) => const VeriffVerificationScreen(),
                );
              case '/cv-list':
                return MaterialPageRoute(builder: (_) => const CVListScreen());
              case '/legal-entity/pricing':
                return MaterialPageRoute(
                  builder: (_) => const LegalEntityPricingScreen(),
                );
              case '/legal-entity/register':
                return MaterialPageRoute(
                  builder: (_) => const LegalEntityPublicRegistrationScreen(),
                );
              case '/legal-entity/invitation-details':
                final args = settings.arguments as Map<String, String>?;
                return MaterialPageRoute(
                  builder: (_) => LegalEntityInvitationDetailsScreen(
                    queryParameters: args ?? {},
                  ),
                );
              case '/legal-entity-registration':
                return MaterialPageRoute(
                  builder: (_) => const LegalEntityRegistrationScreen(),
                );
              default:
                // For unknown routes, redirect to appropriate home based on auth status
                return MaterialPageRoute(
                  builder: (context) {
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.isAuthenticated &&
                        authProvider.currentUser != null) {
                      return const HomeScreen();
                    }
                    return const PublicHomeScreen();
                  },
                );
            }
          },
        );
      },
    );
  }
}
