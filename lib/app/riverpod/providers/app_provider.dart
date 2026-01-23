import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/riverpod/providers/auth_provider.dart';
import 'package:riverpod_demo_app/app/states/app_state.dart';

/// Abstract class sebagai namespace untuk app-level providers
/// Menghandle application initialization dan routing logic
abstract class AppProviders {
  /// Provider untuk AppNotifier (state management untuk app initialization)
  static final notifier = StateNotifierProvider<AppNotifier, AppState>((ref) {
    return AppNotifier(ref);
  });
}

/// StateNotifier untuk mengelola application initialization
/// Memisahkan business logic dari UI layer
class AppNotifier extends StateNotifier<AppState> {
  final Ref ref;

  AppNotifier(this.ref) : super(const AppState());

  /// Initialize aplikasi - check auth status dan tentukan route
  Future<void> initialize() async {
    // Set initializing state
    state = state.copyWith(isInitializing: true);

    try {
      // Check authentication status
      await ref.read(AuthProviders.notifier.notifier).checkAuthStatus();

      // Delay untuk splash screen effect (optional)
      await Future.delayed(const Duration(seconds: 2));

      // Get auth state untuk determine next route
      final authState = ref.read(AuthProviders.notifier);

      // Determine route berdasarkan auth dan approval status
      AppRoute nextRoute;
      if (!authState.isAuthenticated) {
        // Belum login → Login page
        nextRoute = AppRoute.login;
      } else if (authState.isApprovalRequired && !authState.hasApproved) {
        // Admin belum approve → Approval page
        nextRoute = AppRoute.approval;
      } else {
        // Sudah login dan approved (atau bukan admin) → Home page
        nextRoute = AppRoute.home;
      }

      // Update state dengan route tujuan
      state = state.copyWith(isInitializing: false, currentRoute: nextRoute);
    } catch (e) {
      // Handle error jika ada
      state = state.copyWith(
        isInitializing: false,
        errorMessage: 'Initialization failed: ${e.toString()}',
      );
    }
  }

  /// Reset state (jika diperlukan)
  void reset() {
    state = const AppState();
  }
}
