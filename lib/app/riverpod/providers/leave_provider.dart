import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/services/leave_service.dart';
import 'package:riverpod_demo_app/app/states/leave_state.dart';

/// Provider untuk LeaveService (singleton)
final leaveServiceProvider = Provider<LeaveService>((ref) {
  return LeaveService();
});

/// StateNotifier untuk mengelola daftar pengajuan cuti
class LeaveListNotifier extends StateNotifier<LeaveListState> {
  final LeaveService leaveService;

  LeaveListNotifier(this.leaveService) : super(LeaveListState());

  /// Load semua pengajuan cuti
  Future<void> loadLeaveRequests() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final requests = await leaveService.getAllLeaveRequests();
      state = state.copyWith(isLoading: false, leaveRequests: requests);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data: ${e.toString()}',
      );
    }
  }

  /// Delete pengajuan cuti
  Future<bool> deleteLeaveRequest(String id) async {
    try {
      await leaveService.deleteLeaveRequest(id);

      // Update state dengan remove item yang dihapus
      final updatedList = state.leaveRequests.where((l) => l.id != id).toList();
      state = state.copyWith(leaveRequests: updatedList);

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menghapus: ${e.toString()}');
      return false;
    }
  }

  /// Seed demo data
  void seedDemoData(String username) {
    leaveService.seedDemoData(username);
    loadLeaveRequests();
  }
}

/// Provider untuk LeaveListNotifier
final leaveListProvider =
    StateNotifierProvider<LeaveListNotifier, LeaveListState>((ref) {
      final leaveService = ref.watch(leaveServiceProvider);
      return LeaveListNotifier(leaveService);
    });

/// StateNotifier untuk form pengajuan cuti
class LeaveFormNotifier extends StateNotifier<LeaveFormState> {
  final LeaveService leaveService;
  final Ref ref; // Untuk memanggil provider lain

  LeaveFormNotifier(this.leaveService, this.ref) : super(LeaveFormState());

  /// Submit form untuk create pengajuan cuti baru
  Future<bool> createLeaveRequest({
    required String employeeName,
    required DateTime startDate,
    required DateTime endDate,
    required String substitute,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Validasi tanggal
      if (endDate.isBefore(startDate)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Tanggal akhir tidak boleh lebih awal dari tanggal mulai',
        );
        return false;
      }

      await leaveService.createLeaveRequest(
        employeeName: employeeName,
        startDate: startDate,
        endDate: endDate,
        substitute: substitute,
        reason: reason,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);

      // Refresh list setelah create
      ref.read(leaveListProvider.notifier).loadLeaveRequests();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal membuat pengajuan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Submit form untuk update pengajuan cuti
  Future<bool> updateLeaveRequest({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
    required String substitute,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Validasi tanggal
      if (endDate.isBefore(startDate)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Tanggal akhir tidak boleh lebih awal dari tanggal mulai',
        );
        return false;
      }

      await leaveService.updateLeaveRequest(
        id: id,
        startDate: startDate,
        endDate: endDate,
        substitute: substitute,
        reason: reason,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);

      // Refresh list setelah update
      ref.read(leaveListProvider.notifier).loadLeaveRequests();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengupdate pengajuan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Reset form state
  void resetFormState() {
    state = LeaveFormState();
  }
}

/// Provider untuk LeaveFormNotifier
final leaveFormProvider =
    StateNotifierProvider<LeaveFormNotifier, LeaveFormState>((ref) {
      final leaveService = ref.watch(leaveServiceProvider);
      return LeaveFormNotifier(leaveService, ref);
    });
