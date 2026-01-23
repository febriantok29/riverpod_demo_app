import 'package:riverpod_demo_app/app/models/leave_request.dart';

/// State untuk mengelola daftar pengajuan cuti
class LeaveListState {
  final bool isLoading;
  final List<LeaveRequest> leaveRequests;
  final String? errorMessage;

  LeaveListState({
    this.isLoading = false,
    this.leaveRequests = const [],
    this.errorMessage,
  });

  LeaveListState copyWith({
    bool? isLoading,
    List<LeaveRequest>? leaveRequests,
    String? errorMessage,
  }) {
    return LeaveListState(
      isLoading: isLoading ?? this.isLoading,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      errorMessage: errorMessage,
    );
  }
}

/// State untuk form pengajuan cuti (create/edit)
class LeaveFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  LeaveFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  LeaveFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return LeaveFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}
