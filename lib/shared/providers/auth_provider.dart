import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseService _supabaseService;
  
  AuthNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _initializeAuth();
  }
  
  void _initializeAuth() {
    _supabaseService.authStateChanges.listen((authState) async {
      if (authState.event == AuthChangeEvent.signedIn) {
        await _loadCurrentUser();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
      }
    });
    
    // Check if user is already signed in
    if (_supabaseService.isAuthenticated) {
      _loadCurrentUser();
    } else {
      state = const AsyncValue.data(null);
    }
  }
  
  Future<void> _loadCurrentUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _supabaseService.getCurrentUserData();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'type': 'user',
        'hasWallet': false,
        'hasCv': false,
        'profileCompleted': false,
        'kycCompleted': false,
        'kycPassed': false,
      };
      
      await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        userData: userData,
      );
      
      // User will be automatically signed in after email confirmation
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      // User will be loaded automatically via auth state listener
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      // State will be updated automatically via auth state listener
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }
  
  bool get isAuthenticated => _supabaseService.isAuthenticated;
  UserModel? get currentUser => state.value;
  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
  Object? get error => state.error;
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).value;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value != null;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider).value;
  return user?.isAdmin ?? false;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
