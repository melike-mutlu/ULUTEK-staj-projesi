import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

/// docs/architecture.md — profil için ayrı API yok, Supabase "profiles" tablosu.
class SupabaseProfileRepository implements ProfileRepository {
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
    await supabase.from('profiles').upsert(profile.toJson());
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
}

// Auth (email/password) ve profiles tablosu + RLS hazır olduğu için gerçek
// repository'ye geçildi. [InMemoryProfileRepository] testler/geliştirme için
// duruyor; geri dönmek yine tek satır.
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => SupabaseProfileRepository());
