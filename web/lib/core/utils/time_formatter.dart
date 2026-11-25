/// Formats a [DateTime] into a concise human-readable relative timestamp or date.
String formatRelativeTime(DateTime publishedAt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final localPublished = publishedAt.toLocal();
  final diff = reference.difference(localPublished);

  if (diff.isNegative) {
    return 'Just now';
  }
  if (diff.inMinutes < 1) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final monthName = months[localPublished.month - 1];
  if (localPublished.year == reference.year) {
    return '$monthName ${localPublished.day}';
  }
  return '$monthName ${localPublished.day}, ${localPublished.year}';
}

/// Formats a [DateTime] for the broadsheet masthead dateline (e.g. "WEDNESDAY, NOV 25, 2026").
String formatMastheadDate(DateTime date) {
  const weekdays = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY',
  ];
  const months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  final local = date.toLocal();
  final weekday = weekdays[local.weekday - 1];
  final month = months[local.month - 1];
  return '$weekday, $month ${local.day}, ${local.year}';
}
