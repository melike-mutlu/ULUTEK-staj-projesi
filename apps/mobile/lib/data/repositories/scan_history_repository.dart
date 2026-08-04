import 'package:flutter/foundation.dart';

import '../../core/supabase_client.dart';

class ScanHistoryRepository {
  Future<void> saveScanHistory(String barcode) async {
    try {
      // O an giriş yapmış kullanıcının ID'sini Supabase Auth'tan otomatik çekiyoruz
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('[ScanHistoryRepository] Kullanıcı oturum açmamış, kayıt atılamadı.');
        return;
      }

      await supabase.from('scan_history').insert({
        'user_id': userId,
        'barcode': barcode,
        'scanned_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[ScanHistoryRepository] Kayıt hatası: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10}) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase
          .from('scan_history')
          .select()
          .eq('user_id', userId)
          .order('scanned_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[ScanHistoryRepository] Geçmiş okuma hatası: $e');
      return [];
    }
  }

  /// How many raw rows to read per requested unique product. Repeated scans of
  /// the same barcode are collapsed, so more rows than [limit] are needed.
  static const int _windowFactor = 5;
  static const int _minWindow = 50;
  static const int _maxWindow = 200;

  /// Scan history with one entry per barcode, most recently scanned first.
  ///
  /// Raw scans stay in the database (they are needed for analytics); this only
  /// collapses them for display. Reads a bounded window of recent rows, so if
  /// the user keeps scanning the same few products the list can be shorter than
  /// [limit] — that is the real number of distinct products, not an error.
  Future<List<Map<String, dynamic>>> getUniqueScanHistory({int limit = 10}) async {
    if (limit <= 0) return [];

    final window = (limit * _windowFactor).clamp(_minWindow, _maxWindow);
    final rows = await getScanHistory(limit: window);

    // Rows arrive newest first, so the first row of a barcode is its last scan.
    final seenBarcodes = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final row in rows) {
      final barcode = row['barcode']?.toString();
      if (barcode == null || barcode.isEmpty) continue;
      if (!seenBarcodes.add(barcode)) continue;

      unique.add(row);
      if (unique.length == limit) break;
    }

    return unique;
  }
}

