import 'package:supabase_flutter/supabase_flutter.dart';

class ScanHistoryRepository {
  ScanHistoryRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<void> saveScanHistory(String barcode) async {
    try {
      // 1. O an giriş yapmış kullanıcının ID'sini Supabase Auth'tan otomatik çekiyoruz
      final userId = _supabase.auth.currentUser?.id;

      print('⏳ Kayıt deneniyor... Kullanıcı ID: $userId, Barkod: $barcode');

      if (userId == null) {
        print('⚠️ UYARI: Kullanıcı oturum açmamış, kayıt atılamadı.');
        return;
      }

      // 2. Veritabanına kullanıcının gerçek ID'si ile birlikte kayıt gönderiyoruz
      await _supabase.from('scan_history').insert({
        'user_id': userId,
        'barcode': barcode,
        'scanned_at': DateTime.now().toUtc().toIso8601String(),
      });

      print('✅ BAŞARILI: Barkod ($barcode) kullanıcı ($userId) geçmişine eklendi!');
    } catch (e) {
      print('❌ SUPABASE KAYIT HATASI: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10}) async {
    try{
      final userId = _supabase.auth.currentUser?.id;
      if(userId == null) return[];

      final response = await _supabase
          .from('scan_history')
          .select()
          .eq('user_id', userId)
          .order('scanned_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e){
      print('❌ GEÇMİŞ OKUMA HATASI: $e');
      return [];
    }
  }
}

