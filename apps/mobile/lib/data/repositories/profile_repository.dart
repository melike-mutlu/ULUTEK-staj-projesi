import '../../core/models/user_profile.dart';
import '../../core/supabase_client.dart';

/// Ayrı bir API'ye gerek yok — Supabase client ile "profiles" tablosuna doğrudan erişim.
class ProfileRepository {
  Future<UserProfile?> getProfile(String userId) async {
    final row = await supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return null;
    return UserProfile.fromJson(row);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await supabase.from('profiles').upsert(profile.toJson());
  }
}
