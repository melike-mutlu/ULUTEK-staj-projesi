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
}

