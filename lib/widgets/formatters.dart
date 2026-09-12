import 'package:intl/intl.dart';

/// Formats a number as Lao Kip, e.g. 1250000 -> "1,250,000 ₭"
String formatLak(double amount) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return '${formatter.format(amount)} ₭';
}

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Today / ມື້ນີ້';
  if (d == yesterday) return 'Yesterday / ມື້ວານ';
  return DateFormat('dd MMM yyyy').format(date);
}
