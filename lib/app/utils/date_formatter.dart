import 'package:intl/intl.dart';

/// Utility class untuk formatting tanggal dengan format yang user-friendly
/// Menggunakan package intl dengan locale bahasa Indonesia
class DateFormatter {
  // Indonesian locale
  static const String _locale = 'id_ID';

  /// Format: 31 Desember 2006
  static String formatLong(DateTime date) {
    return DateFormat('d MMMM yyyy', _locale).format(date);
  }

  /// Format: 31 Des 2006
  static String formatMedium(DateTime date) {
    return DateFormat('d MMM yyyy', _locale).format(date);
  }

  /// Format: 31 Des 2006 14:52
  static String formatMediumWithTime(DateTime date) {
    return DateFormat('d MMM yyyy HH:mm', _locale).format(date);
  }

  /// Format: 31/12/2006
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', _locale).format(date);
  }

  /// Format: 31/12/2006 14:52
  static String formatShortWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', _locale).format(date);
  }

  /// Format: Senin, 31 Desember 2006
  static String formatFull(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', _locale).format(date);
  }

  /// Format: Sen, 31 Des 2006
  static String formatFullShort(DateTime date) {
    return DateFormat('EEE, d MMM yyyy', _locale).format(date);
  }

  /// Format date range: 1 - 5 Januari 2006
  static String formatRange(DateTime startDate, DateTime endDate) {
    // Jika tahun dan bulan sama
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${startDate.day} - ${DateFormat('d MMMM yyyy', _locale).format(endDate)}';
    }
    // Jika tahun sama tapi bulan berbeda
    else if (startDate.year == endDate.year) {
      return '${DateFormat('d MMM', _locale).format(startDate)} - ${DateFormat('d MMM yyyy', _locale).format(endDate)}';
    }
    // Jika tahun berbeda
    else {
      return '${formatMedium(startDate)} - ${formatMedium(endDate)}';
    }
  }

  /// Format relative time: "2 hari lalu", "3 jam lalu", dll
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Format untuk waktu saja: 14:52
  static String formatTimeOnly(DateTime date) {
    return DateFormat('HH:mm', _locale).format(date);
  }

  /// Format untuk waktu dengan detik: 14:52:30
  static String formatTimeWithSeconds(DateTime date) {
    return DateFormat('HH:mm:ss', _locale).format(date);
  }

  /// Get nama bulan dari index (1-12)
  static String getMonthName(int month, {bool short = false}) {
    if (month < 1 || month > 12) return '';
    final date = DateTime(2000, month);
    return DateFormat(short ? 'MMM' : 'MMMM', _locale).format(date);
  }

  /// Get nama hari dari DateTime
  static String getDayName(DateTime date, {bool short = false}) {
    return DateFormat(short ? 'EEE' : 'EEEE', _locale).format(date);
  }
}
