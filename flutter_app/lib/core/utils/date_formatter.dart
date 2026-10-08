class AppDateFormatter {
  AppDateFormatter._();

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Safely parses a string date/timestamp into a [DateTime] object.
  static DateTime? parse(dynamic rawInput) {
    if (rawInput == null) return null;
    if (rawInput is DateTime) return rawInput;

    final String str = rawInput.toString().trim();
    if (str.isEmpty || str == 'N/A' || str == 'null') return null;

    // Try standard DateTime.tryParse (ISO 8601 e.g. "2026-09-23T17:40:44.557")
    DateTime? parsed = DateTime.tryParse(str);
    if (parsed != null) return parsed;

    // Try replacing space with 'T' (e.g. "2026-09-24 11:39:49" -> "2026-09-24T11:39:49")
    if (str.contains(' ') && !str.contains('T')) {
      parsed = DateTime.tryParse(str.replaceAll(' ', 'T'));
      if (parsed != null) return parsed;
    }

    // Try slash formats (e.g., "2026/09/24 11:39:49" or "24/09/2026")
    try {
      if (str.contains('/')) {
        final parts = str.split(' ');
        final dateParts = parts[0].split('/');
        if (dateParts.length == 3) {
          int y, m, d;
          if (dateParts[0].length == 4) {
            y = int.parse(dateParts[0]);
            m = int.parse(dateParts[1]);
            d = int.parse(dateParts[2]);
          } else {
            d = int.parse(dateParts[0]);
            m = int.parse(dateParts[1]);
            y = int.parse(dateParts[2]);
          }
          if (parts.length > 1) {
            final timeParts = parts[1].split(':');
            final hh = int.parse(timeParts[0]);
            final mm = int.parse(timeParts[1]);
            final ss = timeParts.length > 2 ? int.parse(timeParts[2].split('.')[0]) : 0;
            return DateTime(y, m, d, hh, mm, ss);
          }
          return DateTime(y, m, d);
        }
      }
    } catch (_) {}

    return null;
  }

  /// Formats date and time into a clean user-friendly format.
  /// Example: "23 Sep 2026, 05:40 PM"
  static String formatDateTime(dynamic rawInput) {
    if (rawInput == null) return 'N/A';

    final String value = rawInput.toString().trim();

    if (value.isEmpty || value == 'N/A' || value == 'null') {
      return 'N/A';
    }

    try {
      final DateTime dt = DateTime.parse(value).toLocal();

      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final String day = dt.day.toString().padLeft(2, '0');
      final String month = months[dt.month - 1];
      final String year = dt.year.toString();

      final int hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final String hour = hour12.toString().padLeft(2, '0');
      final String minute = dt.minute.toString().padLeft(2, '0');
      final String amPm = dt.hour >= 12 ? 'PM' : 'AM';

      return '$day $month $year, $hour:$minute $amPm';
    } catch (e) {
      return value;
    }
  }
  /// Formats date only.
  /// Example: "23 Sep 2026"
  static String formatDate(dynamic rawInput, {String fallback = 'N/A'}) {
    if (rawInput == null) return fallback;
    final String str = rawInput.toString().trim();
    if (str.isEmpty || str == 'N/A' || str == 'null') return fallback;

    final dt = parse(rawInput);
    if (dt == null) return str;

    final String day = dt.day.toString().padLeft(2, '0');
    final String month = _monthNames[dt.month - 1];
    final String year = dt.year.toString();

    return '$day $month $year';
  }

  /// Formats time only.
  /// Example: "05:40 PM"
  static String formatTime(dynamic rawInput, {String fallback = 'N/A'}) {
    if (rawInput == null) return fallback;
    final String str = rawInput.toString().trim();
    if (str.isEmpty || str == 'N/A' || str == 'null') return fallback;

    final dt = parse(rawInput);
    if (dt == null) return str;

    final int hourInt = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final String hour = hourInt.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String amPm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $amPm';
  }
}
