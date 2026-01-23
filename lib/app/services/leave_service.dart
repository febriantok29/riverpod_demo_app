import 'package:riverpod_demo_app/app/models/leave_request.dart';

/// Service untuk mengelola data pengajuan cuti
/// Dalam real app, ini akan berkomunikasi dengan API
/// Untuk demo, kita gunakan in-memory storage
class LeaveService {
  // Simulasi database dengan List
  final List<LeaveRequest> _leaveRequests = [];
  int _idCounter = 1;

  /// Get semua pengajuan cuti
  Future<List<LeaveRequest>> getAllLeaveRequests() async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));

    // Return sorted by date (newest first)
    final sorted = List<LeaveRequest>.from(_leaveRequests);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Get pengajuan cuti by ID
  Future<LeaveRequest?> getLeaveRequestById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _leaveRequests.firstWhere((leave) => leave.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create pengajuan cuti baru
  Future<LeaveRequest> createLeaveRequest({
    required String employeeName,
    required DateTime startDate,
    required DateTime endDate,
    required String substitute,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final newLeave = LeaveRequest(
      id: 'LR${_idCounter.toString().padLeft(4, '0')}',
      employeeName: employeeName,
      startDate: startDate,
      endDate: endDate,
      substitute: substitute,
      reason: reason,
      status: LeaveStatus.pending,
      createdAt: DateTime.now(),
    );

    _idCounter++;
    _leaveRequests.add(newLeave);
    return newLeave;
  }

  /// Update pengajuan cuti
  Future<LeaveRequest> updateLeaveRequest({
    required String id,
    DateTime? startDate,
    DateTime? endDate,
    String? substitute,
    String? reason,
    LeaveStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _leaveRequests.indexWhere((leave) => leave.id == id);
    if (index == -1) {
      throw Exception('Leave request not found');
    }

    final updated = _leaveRequests[index].copyWith(
      startDate: startDate,
      endDate: endDate,
      substitute: substitute,
      reason: reason,
      status: status,
    );

    _leaveRequests[index] = updated;
    return updated;
  }

  /// Delete pengajuan cuti
  Future<void> deleteLeaveRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _leaveRequests.removeWhere((leave) => leave.id == id);
  }

  /// Get statistik (optional, untuk dashboard)
  Future<Map<String, int>> getStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final pending = _leaveRequests
        .where((l) => l.status == LeaveStatus.pending)
        .length;
    final approved = _leaveRequests
        .where((l) => l.status == LeaveStatus.approved)
        .length;
    final rejected = _leaveRequests
        .where((l) => l.status == LeaveStatus.rejected)
        .length;

    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'total': _leaveRequests.length,
    };
  }

  /// Seed data untuk demo (optional)
  void seedDemoData(String currentUsername) {
    if (_leaveRequests.isNotEmpty) return; // Jangan seed kalau sudah ada data

    final now = DateTime.now();

    _leaveRequests.addAll([
      LeaveRequest(
        id: 'LR0001',
        employeeName: currentUsername,
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 9)),
        substitute: 'Budi Santoso',
        reason: 'Liburan keluarga',
        status: LeaveStatus.pending,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      LeaveRequest(
        id: 'LR0002',
        employeeName: currentUsername,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.subtract(const Duration(days: 13)),
        substitute: 'Siti Nurhaliza',
        reason: 'Acara keluarga',
        status: LeaveStatus.approved,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      LeaveRequest(
        id: 'LR0003',
        employeeName: currentUsername,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.subtract(const Duration(days: 4)),
        substitute: 'Ahmad Dahlan',
        reason: 'Sakit',
        status: LeaveStatus.rejected,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    _idCounter = 4;
  }
}
