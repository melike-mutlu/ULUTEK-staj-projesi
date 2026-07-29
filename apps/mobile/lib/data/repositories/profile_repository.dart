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

  Future<UserProfile?> getProfile(String userId);
  Future<void> saveProfile(UserProfile profile);
}

/// docs/architecture.md — profil için ayrı API yok, Supabase "profiles" tablosu.
class SupabaseProfileRepository implements ProfileRepository {
  @override
  String? get currentUserId => supabase.auth.currentUser?.id;

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
  Future<UserProfile?> getProfile(String userId) async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }
}

// TODO(backend-pod): profiles tablosu + RLS + auth hazır olunca
// SupabaseProfileRepository()'ye çevrilecek. Başka hiçbir yer değişmeyecek.
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => InMemoryProfileRepository());
