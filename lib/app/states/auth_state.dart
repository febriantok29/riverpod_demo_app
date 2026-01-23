class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? username;
  final String? errorMessage;
  final bool isApprovalRequired; // True jika user adalah admin
  final bool hasApproved; // True jika admin sudah approve

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.username,
    this.errorMessage,
    this.isApprovalRequired = false,
    this.hasApproved = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? username,
    String? errorMessage,
    bool? isApprovalRequired,
    bool? hasApproved,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
      isApprovalRequired: isApprovalRequired ?? this.isApprovalRequired,
      hasApproved: hasApproved ?? this.hasApproved,
    );
  }
}
