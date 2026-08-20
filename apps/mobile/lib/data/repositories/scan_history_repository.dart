import 'package:flutter/foundation.dart';

import '../../core/models/scan_history_entry.dart';
import '../../core/supabase_client.dart';
import 'product_cache_repository.dart';

class ScanHistoryRepository {
  ScanHistoryRepository({ProductCacheRepository? productCacheRepository})
      : _productCacheRepository = productCacheRepository ?? ProductCacheRepository();

  final ProductCacheRepository _productCacheRepository;

  Future<void> saveScanHistory(String barcode , {bool hadConflict = false}) async {
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
        'had_conflict': hadConflict,
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
  Future<List<ScanHistoryEntry>> getUniqueScanHistory({int limit = 10}) async {
    if (limit <= 0) return [];

    final window = (limit * _windowFactor).clamp(_minWindow, _maxWindow);
    final rows = await getScanHistory(limit: window);

    // Rows arrive newest first, so the first row of a barcode is its last scan.
    final seenBarcodes = <String>{};
    final unique = <ScanHistoryEntry>[];
    for (final row in rows) {
      final entry = ScanHistoryEntry.tryFromJson(row);
      if (entry == null) continue;
      if (!seenBarcodes.add(entry.barcode)) continue;

      unique.add(entry);
      if (unique.length == limit) break;
    }

    return _withProductNames(unique);
  }

  /// Attaches cached product names in a single lookup for the whole list.
  /// Barcodes missing from the cache keep a null name.
  Future<List<ScanHistoryEntry>> _withProductNames(
    List<ScanHistoryEntry> entries,
  ) async {
    if (entries.isEmpty) return entries;

    try {
      final names = await _productCacheRepository
          .getNamesByBarcodes(entries.map((e) => e.barcode).toList());
      if (names.isEmpty) return entries;

      return entries
          .map((entry) => entry.copyWithProductName(names[entry.barcode]))
          .toList();
    } catch (e) {
      // Names are optional: the history list must still render with barcodes.
      debugPrint('[ScanHistoryRepository] Ürün adı eşleme hatası: $e');
      return entries;
    }
  }
}

