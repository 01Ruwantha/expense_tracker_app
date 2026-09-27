import 'package:intl/intl.dart';

/// Utility for formatting dates and currency values.
class Formatters {
  Formatters._();

  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonthYear = DateFormat('MMM d, yyyy');
  static final DateFormat _dayMonth = DateFormat('MMM d');
  static final DateFormat _timeOnly = DateFormat('h:mm a');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// Format as "October 2024"
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// Format as "Oct 24, 2024"
  static String longDate(DateTime date) => _dayMonthYear.format(date);

  /// Format as "Oct 24"
  static String shortDate(DateTime date) => _dayMonth.format(date);

  /// Format as "2:15 PM"
  static String timeOnly(DateTime date) => _timeOnly.format(date);

  /// Format as "2024-10-24"
  static String isoDate(DateTime date) => _isoDate.format(date);

  /// Smart date: "Today, 2:15 PM", "Yesterday, 8:40 PM", or "Oct 22"
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Today, ${timeOnly(date)}';
    } else if (target == yesterday) {
      return 'Yesterday, ${timeOnly(date)}';
    } else if (date.year == now.year) {
      return shortDate(date);
    } else {
      return longDate(date);
    }
  }

  /// Format amount as currency: "$1,234.56"
  static String currency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format compact: "$1.2K", "$2.8M"
  static String compactCurrency(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount, symbol: symbol);
  }

  /// Percentage: "71%"
  static String percent(double value) => '${value.toStringAsFixed(0)}%';
}
