import 'package:intl/intl.dart';

/// Contract for the date strings the UI needs.
abstract interface class DateFormatterService {
  String time(DateTime date);
  String fullDateTime(DateTime date);
  String shortDate(DateTime date);
  String groupHeader(DateTime date);
  String relative(DateTime date);
}

/// Formats dates the way the Tatum Bank designs present them.
class AppDateFormatter implements DateFormatterService {
  const AppDateFormatter();

  @override
  String time(DateTime date) => DateFormat('hh:mm a').format(date);

  @override
  String fullDateTime(DateTime date) => DateFormat('dd MMM yyyy \u2022 hh:mm a').format(date);

  @override
  String shortDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  @override
  String groupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) {
      return 'TODAY, ${DateFormat('d MMM yyyy').format(date).toUpperCase()}';
    }
    if (day == today.subtract(const Duration(days: 1))) return 'YESTERDAY';
    return DateFormat('d MMM yyyy').format(date).toUpperCase();
  }

  @override
  String relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    return DateFormat('dd MMM, hh:mm a').format(date);
  }
}
