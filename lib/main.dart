import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/legal_entity_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/certifier_provider.dart';
import 'models/user.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/public/public_home_screen.dart';
import 'screens/certification/create_certification_screen.dart';
import 'screens/profile/user_profile_screen.dart';
import 'screens/settings/user_settings_screen.dart';
import 'screens/veriff/veriff_verification_screen.dart';
import 'screens/public/cv_list_screen.dart';
import 'screens/legal_entity/legal_entity_registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      final authProvider = context.read<AuthProvider>();
      authProvider.checkAuthenticationStatus();
    }
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();

    // Listen to auth state changes
    authProvider.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocaleProvider>(
      builder: (context, authProvider, localeProvider, child) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: AppConfig.enableDebugMode,
          navigatorKey: _navigatorKey,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
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
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/admin': (context) => const AdminDashboardScreen(),
            '/public': (context) => const PublicHomeScreen(),
            '/create-certification': (context) =>
                const CreateCertificationScreenRoute(
                  child: CreateCertificationScreen(),
                ),
            '/profile': (context) => const UserProfileScreen(),
            '/settings': (context) => const UserSettingsScreen(),
            '/veriff': (context) => const VeriffVerificationScreen(),
            '/cv-list': (context) => const CVListScreen(),
            '/legal-entity-registration': (context) =>
                const LegalEntityRegistrationScreen(),
          },
          onGenerateRoute: (settings) {
            // Gestisci le route dinamiche qui se necessario
            switch (settings.name) {
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/signup':
                return MaterialPageRoute(builder: (_) => const SignupScreen());
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
                  builder: (_) => const CreateCertificationScreenRoute(
                    child: CreateCertificationScreen(),
                  ),
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
              case '/legal-entity-registration':
                return MaterialPageRoute(
                  builder: (_) => const LegalEntityRegistrationScreen(),
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => const PublicHomeScreen(),
                );
            }
          },
        );
      },
    );
  }
}
