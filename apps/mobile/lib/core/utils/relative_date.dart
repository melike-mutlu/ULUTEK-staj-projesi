import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Short, human label for a scan time: relative for the last week
/// ("just now", "5 min ago", "3 h ago", "yesterday"), a date after that
/// ("3 Aug", and with the year when it is not the current one).
///
/// Localized through [l10n]; month names and date ordering follow the active
/// locale via [DateFormat]. [now] is injectable so callers and tests can pin
/// the reference time; both values are compared in local time.
String formatScanDate(
  AppLocalizations l10n,
  DateTime scannedAt, {
  DateTime? now,
}) {
  final reference = (now ?? DateTime.now()).toLocal();
  final scanned = scannedAt.toLocal();
  final difference = reference.difference(scanned);

  // Clock skew or a future timestamp should not read as "-3 h ago".
  if (difference.isNegative) return l10n.relativeJustNow;

  if (difference.inMinutes < 1) return l10n.relativeJustNow;
  if (difference.inMinutes < 60) return l10n.relativeMinutesAgo(difference.inMinutes);
  if (difference.inHours < 24) return l10n.relativeHoursAgo(difference.inHours);

  // Calendar days, not 24-hour blocks, so a scan always keeps the day label a
  // user would expect regardless of the hour it happened.
  final startOfToday = DateTime(reference.year, reference.month, reference.day);
  final startOfScanDay = DateTime(scanned.year, scanned.month, scanned.day);
  final dayDifference = startOfToday.difference(startOfScanDay).inDays;

  if (dayDifference <= 1) return l10n.relativeYesterday;
  if (dayDifference < 7) return l10n.relativeDaysAgo(dayDifference);

  final locale = l10n.localeName;
  final format = scanned.year == reference.year
      ? DateFormat.MMMd(locale)
      : DateFormat.yMMMd(locale);
  return format.format(scanned);
}
