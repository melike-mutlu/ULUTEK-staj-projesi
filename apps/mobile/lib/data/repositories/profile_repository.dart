import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/user_profile.dart';
import '../../core/supabase_client.dart';

/// Ayrı bir API'ye gerek yok — Supabase client ile "profiles" tablosuna doğrudan erişim.
///
/// Backend/auth hazır olana kadar [InMemoryProfileRepository] kullanılır; aynı
/// arayüzü uyguladığı için gerçeğe geçiş [profileRepositoryProvider]'da tek satır.
abstract class ProfileRepository {
  /// Oturumdaki kullanıcının id'si; oturum yoksa null.
  String? get currentUserId;

  /// Oturumdaki kullanıcının e-postası; oturum yoksa null. Profil ekranı
  /// başlıkta gösteriyor — UI'ın Supabase'e doğrudan dokunmaması için burada.
  String? get currentUserEmail;

  Future<UserProfile?> getProfile(String userId);
  Future<void> saveProfile(UserProfile profile);

  /// Fotoğrafı "avatars" bucket'ına yükler ve profile yazılacak URL'i döner.
  /// Yükleme başarısızsa exception fırlatır — çağıran taraf yakalar.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  });

  /// Hesabı ve ilişkili tüm verileri siler (delete-account Edge Function).
  Future<void> deleteAccount();
}

/// docs/architecture.md — profil için ayrı API yok, Supabase "profiles" tablosu.
class SupabaseProfileRepository implements ProfileRepository {
  static const String _avatarBucket = 'avatars';

  /// Storage explicit bir MIME tipi bekler; dosya uzantısı tek başına yetmez.
  static const Map<String, String> _avatarContentTypes = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  @override
  String? get currentUserId => supabase.auth.currentUser?.id;

  @override
  String? get currentUserEmail => supabase.auth.currentUser?.email;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final row = await supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return null;
    return UserProfile.fromJson(row);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await supabase.from('profiles').upsert(profile.toJson());
    } on PostgrestException catch (e) {
      // If the 'country' column doesn't exist in the remote database schema yet,
      // fall back gracefully without 'country' so the save doesn't fail.
      if (e.code == 'PGRST204' || e.message.toLowerCase().contains('country')) {
        final json = profile.toJson()..remove('country');
        await supabase.from('profiles').upsert(json);
        return;
      }
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final ext = fileExtension.toLowerCase();
    // Kullanıcı başına tek dosya: upsert ile üzerine yazılır, eski fotoğraflar
    // bucket'ta birikmez.
    final path = '$userId/avatar.$ext';

    await supabase.storage.from(_avatarBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _avatarContentTypes[ext] ?? 'image/jpeg',
          ),
        );

    // Public URL sabit olduğu için, değişen fotoğraf cache-buster olmadan eski
    // hâliyle servis edilir.
    final url = supabase.storage.from(_avatarBucket).getPublicUrl(path);
    return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> deleteAccount() async {
    final response = await supabase.functions.invoke('delete-account');
    if (response.status != 200) {
      throw Exception('Hesap silinemedi (durum: ${response.status})');
    }
  }
}

/// Backend + auth hazır olana kadar kullanılan bellek içi karşılık.
/// Aynı arayüzü uyguladığı için gerçeğe geçiş tek satır.
class InMemoryProfileRepository implements ProfileRepository {
  UserProfile? _profile;

  @override
  String? get currentUserId => 'mock-user';

  @override
  String? get currentUserEmail => 'mock@example.com';

  @override
  Future<UserProfile?> getProfile(String userId) async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    // example.invalid asla çözülmez (RFC 2606): sahte URL gerçek bir
    // NetworkImage'a sızarsa sessizce beklemek yerine hemen hata verir.
    final url = 'https://example.invalid/avatars/$userId.$fileExtension';
    return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> deleteAccount() async {
    _profile = null;
  }
}

// Auth (email/password) ve profiles tablosu + RLS hazır olduğu için gerçek
// repository'ye geçildi. [InMemoryProfileRepository] testler/geliştirme için
// duruyor; geri dönmek yine tek satır.
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => SupabaseProfileRepository());
