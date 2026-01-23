import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/models/approval_document.dart';
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
      ApprovalDocument? nextDocument;

      if (!authState.isAuthenticated) {
        // Belum login → Login page
        nextRoute = AppRoute.login;
      } else {
        // Check pending documents (untuk admin dan member)
        final pendingDocs = ref
            .read(AuthProviders.notifier.notifier)
            .getPendingDocuments();

        if (pendingDocs.isEmpty) {
          // Sudah approve semua atau tidak perlu approval
          nextRoute = AppRoute.home;
        } else {
          // Ada dokumen yang belum di-approve, ambil yang pertama
          nextRoute = AppRoute.approval;
          nextDocument = ApprovalDocuments.getById(pendingDocs.first);
        }
      }

      // Update state dengan route tujuan
      state = state.copyWith(
        isInitializing: false,
        currentRoute: nextRoute,
        currentApprovalDocument: nextDocument,
      );
    } catch (e) {
      // Handle error jika ada
      state = state.copyWith(
        isInitializing: false,
        errorMessage: 'Initialization failed: ${e.toString()}',
      );
    }
  }

  /// Navigate ke dokumen approval berikutnya
  /// Dipanggil setelah user approve satu dokumen
  void navigateToNextApproval() {
    final pendingDocs = ref
        .read(AuthProviders.notifier.notifier)
        .getPendingDocuments();

    if (pendingDocs.isEmpty) {
      // Semua dokumen sudah di-approve → Home
      state = state.copyWith(
        currentRoute: AppRoute.home,
        currentApprovalDocument: null,
      );
    } else {
      // Masih ada dokumen yang belum di-approve
      final nextDoc = ApprovalDocuments.getById(pendingDocs.first);
      state = state.copyWith(
        currentRoute: AppRoute.approval,
        currentApprovalDocument: nextDoc,
      );
    }
  }

  /// Reset state (jika diperlukan)
  void reset() {
    state = const AppState();
  }
}
