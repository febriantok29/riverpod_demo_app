import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/models/approval_document.dart';
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

  AuthNotifier(this.authService) : super(const AuthState());

  /// Check login status dan load approved documents
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final isLoggedIn = await authService.isLoggedIn();
    final username = await authService.getUsername();
    final approvedDocs = await authService.getApprovedDocuments();

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: isLoggedIn,
      username: username,
      approvedDocumentIds: approvedDocs,
    );
  }

  /// Login user
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final success = await authService.login(username, password);

    if (success) {
      // Load approved documents untuk user ini
      final approvedDocs = await authService.getApprovedDocuments();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        username: username,
        approvedDocumentIds: approvedDocs,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Username atau password tidak boleh kosong',
      );
    }

    return success;
  }

  /// Logout user
  Future<void> logout() async {
    await authService.logout();
    state = const AuthState(); // Reset ke state awal
  }

  /// Approve dokumen tertentu
  /// Dipanggil ketika user menyetujui salah satu dokumen approval
  Future<void> approveDocument(String documentId) async {
    await authService.saveApprovedDocument(documentId);

    // Update state dengan menambahkan document ID ke list
    final currentApprovals = List<String>.from(state.approvedDocumentIds);
    if (!currentApprovals.contains(documentId)) {
      currentApprovals.add(documentId);
      state = state.copyWith(approvedDocumentIds: currentApprovals);
    }
  }

  /// Get dokumen yang belum di-approve untuk user tertentu
  /// Return list document IDs yang perlu di-approve
  List<String> getPendingDocuments() {
    final username = state.username;
    if (username == null) return [];

    // Get required documents berdasarkan user type
    final requiredDocs = ApprovalDocuments.getDocumentsForUser(username);

    // Filter yang belum di-approve
    return requiredDocs
        .where((doc) => !state.approvedDocumentIds.contains(doc.id))
        .map((doc) => doc.id)
        .toList();
  }
}
