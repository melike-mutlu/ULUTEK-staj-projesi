import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

export interface UserHealthProfile {
  userId: string;
  allergies: string[];
  dietPreference: string[];
  healthConditions: string[];
}

/**
 * Gelen veriyi güvenli bir şekilde string[] dizisine dönüştürür.
 */
function parseArrayField(fieldValue: unknown): string[] {
  if (!fieldValue) return [];
  if (Array.isArray(fieldValue)) {
    return fieldValue.map((item) => String(item).trim()).filter(Boolean);
  }
  if (typeof fieldValue === 'string') {
    return fieldValue.split(',').map((item) => item.trim()).filter(Boolean);
  }
  return [];
}

/**
 * Veritabanından (profiles tablosu) kullanıcının alerji, diyet ve sağlık verilerini çeker.
 */
export async function getUserHealthProfile(
  supabaseClient: SupabaseClient,
  userId: string
): Promise<UserHealthProfile> {
  const { data: profile, error } = await supabaseClient
    .from('profiles')
    .select('allergies, diet_preference, health_conditions')
    .eq('user_id', userId)
    .maybeSingle();

  if (error || !profile) {
    if (error) {
      console.error(`[UserProfile] Profil verisi alınırken hata oluştu (userId: ${userId}):`, error);
    }
    return {
      userId,
      allergies: [],
      dietPreference: [],
      healthConditions: [],
    };
  }

  return {
    userId,
    allergies: parseArrayField(profile.allergies),
    dietPreference: parseArrayField(profile.diet_preference),
    healthConditions: parseArrayField(profile.health_conditions),
  };
}

/**
 * Çekilen profil verisini Sevde'nin v2 servisine verilecek prompt metnine dönüştürür.
 */
export function buildProfilePromptContext(profile: UserHealthProfile): string {
  const details: string[] = [];

  if (profile.allergies.length > 0) {
    details.push(`Alerjiler: ${profile.allergies.join(', ')}`);
  }
  if (profile.dietPreference.length > 0) {
    details.push(`Diyet Tercihi: ${profile.dietPreference.join(', ')}`);
  }
  if (profile.healthConditions.length > 0) {
    details.push(`Sağlık Durumları: ${profile.healthConditions.join(', ')}`);
  }

  if (details.length === 0) {
    return 'Kullanıcının tanımlı özel bir sağlık, alerji veya diyet kısıtlaması bulunmamaktadır.';
  }

  return `Kullanıcı Özel Sağlık ve Diyet Profili:\n- ${details.join('\n- ')}\n\nBu kullanıcının sorularını yanıtlarken yukarıdaki kısıtlamalarını dikkate alarak yanıt ver.`;
}
