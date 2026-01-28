import 'package:riverpod_demo_app/app/models/approval_document.dart';

/// Enum untuk menentukan route tujuan setelah initialization
enum AppRoute {
  splash, // Masih di splash screen
  login, // Redirect ke login page
  approval, // Redirect ke approval page (admin dan member menggunakan ini)
  home, // Redirect ke home page
}

/// State untuk application initialization
class AppState {
  final bool isInitializing;
  final AppRoute currentRoute;
  final String? errorMessage;

  /// Dokumen yang sedang ditampilkan untuk approval (untuk member)
  final ApprovalDocument? currentApprovalDocument;

  const AppState({
    this.isInitializing = true,
    this.currentRoute = AppRoute.splash,
    this.errorMessage,
    this.currentApprovalDocument,
  });

  AppState copyWith({
    bool? isInitializing,
    AppRoute? currentRoute,
    String? errorMessage,
    ApprovalDocument? currentApprovalDocument,
  }) {
    return AppState(
      isInitializing: isInitializing ?? this.isInitializing,
      currentRoute: currentRoute ?? this.currentRoute,
      errorMessage: errorMessage ?? this.errorMessage,
      currentApprovalDocument:
          currentApprovalDocument ?? this.currentApprovalDocument,
    );
  }
}
