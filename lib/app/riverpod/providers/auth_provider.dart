import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/services/auth_service.dart';
import 'package:riverpod_demo_app/app/states/auth_state.dart';

/// Abstract class sebagai namespace untuk auth-related providers
/// Menggunakan pattern ini untuk organisasi code yang lebih baik
abstract class AuthProviders {
  /// Provider untuk AuthService (singleton)
  static final service = Provider<AuthService>((ref) {
    return AuthService();
  });

  /// Provider untuk AuthNotifier (state management)
  static final notifier = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    final authService = ref.watch(service);
    return AuthNotifier(authService);
  });
}

// StateNotifier untuk mengelola auth state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;

  AuthNotifier(this.authService) : super(AuthState());

  // Check login status
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final isLoggedIn = await authService.isLoggedIn();
    final username = await authService.getUsername();

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: isLoggedIn,
      username: username,
    );
  }

  // Login
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final success = await authService.login(username, password);

    if (success) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        username: username,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Username atau password tidak boleh kosong',
      );
    }

    return success;
  }

  // Logout
  Future<void> logout() async {
    await authService.logout();
    state = AuthState(); // Reset ke state awal
  }
}
