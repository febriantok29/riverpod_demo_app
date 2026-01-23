import 'package:riverpod_demo_app/app/utils/date_formatter.dart';

enum LeaveStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Menunggu';
      case LeaveStatus.approved:
        return 'Disetujui';
      case LeaveStatus.rejected:
        return 'Ditolak';
    }
  }
}

class LeaveRequest {
  final String id;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final String substitute; // Karyawan pengganti
  final String reason;
  final LeaveStatus status;
  final DateTime createdAt;

  LeaveRequest({
    required this.id,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.substitute,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  // Hitung jumlah hari cuti
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // Format tanggal untuk display
  String get dateRange {
    return DateFormatter.formatRange(startDate, endDate);
  }

  // Format tanggal untuk display (format pendek)
  String get dateRangeShort {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }

  // Format tanggal dibuat (relative)
  String get createdAtRelative {
    return DateFormatter.formatRelative(createdAt);
  }

  // Format tanggal dibuat (lengkap)
  String get createdAtFormatted {
    return DateFormatter.formatMediumWithTime(createdAt);
  }

  // Copy with untuk update
  LeaveRequest copyWith({
    String? id,
    String? employeeName,
    DateTime? startDate,
    DateTime? endDate,
    String? substitute,
    String? reason,
    LeaveStatus? status,
    DateTime? createdAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      substitute: substitute ?? this.substitute,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
