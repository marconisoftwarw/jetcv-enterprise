import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/config/app_config.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'features/legal_entity/presentation/pages/legal_entity_list_page.dart';
import 'shared/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration
  AppConfig.initialize();
  
  // Initialize Supabase
  await SupabaseService.instance.initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      routerConfig: _createRouter(authState),
    );
  }
  
  GoRouter _createRouter(AsyncValue<UserModel?> authState) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isAuthenticated = authState.value != null;
        final isAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/signup';
        
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }
        
        if (isAuthenticated && isAuthRoute) {
          return '/';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/legal-entities',
          builder: (context, state) => const LegalEntityListPage(),
        ),
      ],
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('JetCV Enterprise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benvenuto, ${user?.displayName ?? 'Utente'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            if (isAdmin) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Dashboard Amministratore'),
                  subtitle: const Text('Gestisci enti legali e utenti'),
                  onTap: () => context.go('/admin'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Enti Legali'),
                subtitle: const Text('Visualizza e gestisci enti legali'),
                onTap: () => context.go('/legal-entities'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profilo'),
                subtitle: const Text('Gestisci il tuo profilo utente'),
                onTap: () {
                  // TODO: Implement profile page
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
