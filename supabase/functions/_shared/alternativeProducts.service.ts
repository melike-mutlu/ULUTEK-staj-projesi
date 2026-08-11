import { runRuleEngine } from "./ruleEngine/ruleEngine.service.ts";

type UserProfile = any;
type ProductData = any;

export interface AlternativeProduct {
  barcode: string;
  product_name: string;
  brand?: string;
  image_url?: string;
  nutriscore_grade?: string;
  is_safe: boolean;
  recommendation_reason?: string;
}

/**
 * "Safe" mirrors the rule engine's own verdict directly — has_conflict already
 * rolls up allergens, health conditions, and diet conflicts. Insufficient data
 * is never "safe" either: an alternative with no evidence is not a real
 * recommendation.
 */
function isSafeAlternative(ruleResult: any): boolean {
  if (!ruleResult) return false;
  if (ruleResult.data_sufficiency === "insufficient") return false;
  return !ruleResult.has_conflict;
}

/**
 * Nutri-Score sıralama önceliği.
 */
const scoreOrder: Record<string, number> = {
  A: 1,
  B: 2,
  C: 3,
  D: 4,
  E: 5,
};

/**
 * Taratılan ürünle aynı kategorideki doğrulanmış ürünleri product_cache tablosundan çeker,
 * mevcut rule engine'den geçirir ve yalnızca güvenli alternatifleri döndürür.
 */
export async function findSafeAlternatives(
  scannedProduct: ProductData,
  userProfile: UserProfile,
  supabaseClient: any,
  limit: number = 3,
): Promise<AlternativeProduct[]> {
  const category = scannedProduct.categories_tags?.[0];
  if (!category) return [];

  const { data: candidates, error } = await supabaseClient
    .from("product_cache")
    .select("*")
    .contains("categories_tags", [category])
    .neq("barcode", scannedProduct.barcode)
    .limit(20);

  if (error) {
    console.error("Alternatif ürün sorgu hatası:", error);
    return [];
  }

  if (!candidates || candidates.length === 0) {
    return [];
  }

  const safeAlternatives: AlternativeProduct[] = [];

  // Deterministik rule engine süzgeci
  for (const candidate of candidates) {
    const ruleResult = runRuleEngine(candidate, userProfile);

    if (!isSafeAlternative(ruleResult)) {
      continue;
    }

    const grade = candidate.nutriscore?.toUpperCase();

    safeAlternatives.push({
      barcode: candidate.barcode,
      product_name: candidate.name ?? "Bilinmeyen Ürün",
      brand: candidate.brand ?? undefined,
      image_url: candidate.image_url ?? undefined,
      nutriscore_grade: grade,
      is_safe: true,
      recommendation_reason: grade
        ? `Nutri-Score ${grade} kalitesinde ve sağlık profilinizle uyumlu.`
        : "Sağlık ve diyet profilinizle uyumlu.",
    });
  }

  // Nutri-Score'a göre sırala (A -> E)
  safeAlternatives.sort((a, b) => {
    const scoreA = scoreOrder[a.nutriscore_grade ?? "Z"] ?? 99;
    const scoreB = scoreOrder[b.nutriscore_grade ?? "Z"] ?? 99;
    return scoreA - scoreB;
  });

  return safeAlternatives.slice(0, limit);
}
