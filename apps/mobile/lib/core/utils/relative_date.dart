const List<String> _monthsShort = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

/// Short, human label for a scan time: relative for the last week
/// ("az önce", "5 dk önce", "3 saat önce", "dün"), a date after that
/// ("3 Ağu", and with the year when it is not the current one).
///
/// [now] is injectable so callers and tests can pin the reference time; both
/// values are compared in local time.
String formatScanDate(DateTime scannedAt, {DateTime? now}) {
  final reference = (now ?? DateTime.now()).toLocal();
  final scanned = scannedAt.toLocal();
  final difference = reference.difference(scanned);

  // Clock skew or a future timestamp should not read as "-3 saat önce".
  if (difference.isNegative) return 'az önce';

  if (difference.inMinutes < 1) return 'az önce';
  if (difference.inMinutes < 60) return '${difference.inMinutes} dk önce';
  if (difference.inHours < 24) return '${difference.inHours} saat önce';

  // Calendar days, not 24-hour blocks, so a scan always keeps the day label a
  // user would expect regardless of the hour it happened.
  final startOfToday = DateTime(reference.year, reference.month, reference.day);
  final startOfScanDay = DateTime(scanned.year, scanned.month, scanned.day);
  final dayDifference = startOfToday.difference(startOfScanDay).inDays;

  if (dayDifference <= 1) return 'dün';
  if (dayDifference < 7) return '$dayDifference gün önce';

  final label = '${scanned.day} ${_monthsShort[scanned.month - 1]}';
  return scanned.year == reference.year ? label : '$label ${scanned.year}';
}
