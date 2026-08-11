// supabase/functions/_shared/alternativeProducts.service.ts

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
 * Kural motoru sonucunu değerlendirerek ürünün güvenli alternatif olup olmadığını belirler.
 *
 * Güvenli alternatif olabilmesi için:
 * - Hiçbir alerji kuralında conflict olmamalı.
 * - Hiçbir sağlık koşulunda conflict olmamalı.
 * - Hiçbir diyet uyumluluğunda conflict olmamalı.
 * - Hiçbir sağlık koşulu not_evaluated olmamalı.
 */
function isSafeAlternative(ruleResult: any): boolean {
  if (!ruleResult) return false;

  const hasConflict =
    (ruleResult.allergens?.some((a: any) => a.status === "conflict") ?? false) ||
    (ruleResult.health_conditions?.some((h: any) => h.status === "conflict") ?? false) ||
    (ruleResult.diet_compatibility?.some((d: any) => d.status === "conflict") ?? false);

  const hasUnknown =
    ruleResult.health_conditions?.some(
      (h: any) => h.status === "not_evaluated"
    ) ?? false;

  return !hasConflict && !hasUnknown;
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
  // Ana kategoriyi veya ilk kategori etiketini belirle
  const category =
    scannedProduct.main_category?.trim() ||
    scannedProduct.categories_tags?.[0];

  if (!category) return [];

  // 1. Öncelikle main_category ile ara
  let { data: candidates, error } = await supabaseClient
    .from("product_cache")
    .select("*")
    .eq("main_category", category)
    .neq("barcode", scannedProduct.barcode)
    .limit(20);

  if (error) {
    console.error("Alternatif ürün sorgu hatası:", error);
    return [];
  }

  // 2. Sonuç bulunamazsa categories_tags üzerinden ara
  if (!candidates || candidates.length === 0) {
    const { data: fallbackCandidates, error: fallbackError } =
      await supabaseClient
        .from("product_cache")
        .select("*")
        .contains("categories_tags", [category])
        .neq("barcode", scannedProduct.barcode)
        .limit(20);

    if (fallbackError) {
      console.error("Fallback kategori sorgu hatası:", fallbackError);
      return [];
    }

    candidates = fallbackCandidates ?? [];
  }

  if (candidates.length === 0) {
    return [];
  }

  const safeAlternatives: AlternativeProduct[] = [];

  // Deterministik rule engine süzgeci
  for (const candidate of candidates) {
    const ruleResult = runRuleEngine(candidate, userProfile);

    if (!isSafeAlternative(ruleResult)) {
      continue;
    }

    const grade = candidate.nutriscore_grade?.toUpperCase();

    safeAlternatives.push({
      barcode: candidate.barcode,
      product_name: candidate.product_name ?? "Bilinmeyen Ürün",
      brand: candidate.brand,
      image_url: candidate.image_url,
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

  // En fazla limit kadar güvenli alternatif döndür
  return safeAlternatives.slice(0, limit);
}