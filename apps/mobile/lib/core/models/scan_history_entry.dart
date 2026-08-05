import 'package:flutter/foundation.dart';

/// One row of the user's scan history, ready for display.
///
/// [productName] is filled in from the product cache when available; the UI
/// falls back to the barcode when it is null.
@immutable
class ScanHistoryEntry {
  const ScanHistoryEntry({
    required this.barcode,
    required this.scannedAt,
    this.productName,
  });

  final String barcode;

  /// Local time, so screens can format it without converting again.
  final DateTime scannedAt;

  final String? productName;

  /// Returns null for rows that cannot be displayed (missing barcode or an
  /// unusable `scanned_at`), so one bad row never breaks the whole list.
  static ScanHistoryEntry? tryFromJson(Map<String, dynamic> json) {
    final barcode = json['barcode']?.toString().trim();
    if (barcode == null || barcode.isEmpty) {
      debugPrint('[ScanHistoryEntry] Barkodu olmayan kayıt atlandı: $json');
      return null;
    }

    final rawScannedAt = json['scanned_at'];
    final scannedAt = rawScannedAt == null
        ? null
        : DateTime.tryParse(rawScannedAt.toString())?.toLocal();
    if (scannedAt == null) {
      debugPrint(
        '[ScanHistoryEntry] scanned_at okunamadı, kayıt atlandı: $rawScannedAt',
      );
      return null;
    }

    return ScanHistoryEntry(barcode: barcode, scannedAt: scannedAt);
  }

  ScanHistoryEntry copyWithProductName(String? name) => ScanHistoryEntry(
        barcode: barcode,
        scannedAt: scannedAt,
        productName: name,
      );
}
