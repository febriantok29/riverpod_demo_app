class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? username;
  final String? errorMessage;

  /// List ID dokumen yang sudah di-approve oleh user
  /// Untuk admin: hanya 1 dokumen approval
  /// Untuk member: 3 dokumen (pacta_integritas, perlindungan_data_pribadi, persetujuan_k3)
  final List<String> approvedDocumentIds;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.username,
    this.errorMessage,
    this.approvedDocumentIds = const [],
  });

  /// Helper: Check apakah user membutuhkan approval
  bool get requiresApproval => isAuthenticated && username != null;

  /// Helper: Check apakah user sudah approve semua dokumen yang diperlukan
  /// Admin: butuh 1 dokumen
  /// Member: butuh 3 dokumen
  bool hasCompletedAllApprovals(String username) {
    if (username.toLowerCase().contains('admin')) {
      // Admin butuh minimal 1 approval (approval_page lama)
      return approvedDocumentIds.isNotEmpty;
    } else if (username.toLowerCase().contains('member')) {
      // Member butuh 3 approval
      return approvedDocumentIds.length >= 3;
    }
    // User lain tidak butuh approval
    return true;
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? username,
    String? errorMessage,
    List<String>? approvedDocumentIds,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
      approvedDocumentIds: approvedDocumentIds ?? this.approvedDocumentIds,
    );
  }
}
