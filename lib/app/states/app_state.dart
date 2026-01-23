/// Enum untuk menentukan route tujuan setelah initialization
enum AppRoute {
  splash, // Masih di splash screen
  login, // Redirect ke login page
  approval, // Redirect ke approval page (admin only)
  home, // Redirect ke home page
}

/// State untuk application initialization
class AppState {
  final bool isInitializing;
  final AppRoute currentRoute;
  final String? errorMessage;

  const AppState({
    this.isInitializing = true,
    this.currentRoute = AppRoute.splash,
    this.errorMessage,
  });

  AppState copyWith({
    bool? isInitializing,
    AppRoute? currentRoute,
    String? errorMessage,
  }) {
    return AppState(
      isInitializing: isInitializing ?? this.isInitializing,
      currentRoute: currentRoute ?? this.currentRoute,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
