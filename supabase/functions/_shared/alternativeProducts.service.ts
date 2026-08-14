import { searchProductsByCategory } from "./openFoodFacts/openFoodFacts.service.ts";
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

const IGNORED_CATEGORIES = new Set([
  "en:foods",
  "en:groceries",
  "en:plant-based-foods",
  "en:plant-based-foods-and-beverages",
  "en:beverages-and-beverages-preparations",
]);

/**
 * İki kategori kümesi arasındaki Jaccard benzerliğini hesaplar.
 * J(A, B) = |A ∩ B| / |A ∪ B|
 */
function calculateJaccardSimilarity(
  setA: Set<string>,
  setB: Set<string>,
): number {
  if (setA.size === 0 || setB.size === 0) return 0;

  let intersectionCount = 0;
  for (const item of setA) {
    if (setB.has(item)) intersectionCount++;
  }

  const unionCount = new Set([...setA, ...setB]).size;
  return unionCount === 0 ? 0 : intersectionCount / unionCount;
}

/**
 * Rule engine sonucunu değerlendirir.
 */
function isSafeAlternative(ruleResult: any): boolean {
  if (!ruleResult) return false;
  if (ruleResult.data_sufficiency === "insufficient") return false;
  return !ruleResult.has_conflict;
}

export async function findSafeAlternatives(
  scannedProduct: ProductData,
  userProfile: UserProfile,
  _supabaseClient: any,
  limit: number = 5,
): Promise<AlternativeProduct[]> {
  const scannedCategories: string[] = scannedProduct.categories_tags ?? [];
  if (scannedCategories.length === 0) return [];

  // Çok genel kategorileri çıkar
  const scannedFiltered = scannedCategories.filter(
    (c) => !IGNORED_CATEGORIES.has(c),
  );
  if (scannedFiltered.length === 0) return [];

  const scannedSet = new Set<string>(scannedFiltered);

  // En spesifik 3 kategoriyi dene
  const categoriesToTry = scannedFiltered.slice(-3).reverse();

  let rawCandidates: any[] = [];

  for (const category of categoriesToTry) {
    try {
      const results = await searchProductsByCategory(category, 25);

      if (results.length > 0) {
        rawCandidates = results;
        break;
      }
    } catch (e) {
      console.error("OFF Arama Hatası:", e);
    }
  }

  if (rawCandidates.length === 0) return [];

  const scannedBarcode = scannedProduct.barcode || scannedProduct.code;

  // Benzerlik hesapla ve sırala
  const scoredCandidates = rawCandidates
    .filter((candidate) => {
      const candidateBarcode = candidate.barcode || candidate.code;
      return candidateBarcode !== scannedBarcode;
    })
    .map((candidate) => {
      const candidateCategories: string[] = candidate.categories_tags ?? [];
      const candidateFiltered = candidateCategories.filter(
        (c) => !IGNORED_CATEGORIES.has(c),
      );
      const candidateSet = new Set<string>(candidateFiltered);

      const similarity = calculateJaccardSimilarity(
        scannedSet,
        candidateSet,
      );

      return { candidate, similarity };
    })
    .filter((item) => item.similarity >= 0.15)
    .sort((a, b) => b.similarity - a.similarity);

  const safeAlternatives: AlternativeProduct[] = [];

  // Rule engine filtresi
  for (const { candidate } of scoredCandidates) {
    const ruleResult = runRuleEngine(candidate, userProfile);

    if (!isSafeAlternative(ruleResult)) continue;

    const grade = (
      candidate.nutriscore_grade ?? candidate.nutriscore
    )?.toUpperCase();

    safeAlternatives.push({
      barcode: candidate.barcode || candidate.code,
      product_name:
        candidate.product_name ??
        candidate.name ??
        "Bilinmeyen Ürün",
      brand: candidate.brands || candidate.brand,
      image_url:
        candidate.image_front_small_url ||
        candidate.image_url ||
        candidate.image_front_url,
      nutriscore_grade: grade,
      is_safe: true,
      recommendation_reason: grade
        ? `Nutri-Score ${grade} kalitesinde ve sağlık profilinizle uyumlu.`
        : "Sağlık ve diyet profilinizle uyumlu.",
    });

    if (safeAlternatives.length >= limit) break;
  }

  // Tek özet log
  console.log("Alternative search completed", {
    barcode: scannedBarcode,
    candidatesFound: scoredCandidates.length,
    alternativesReturned: safeAlternatives.length,
  });

  return safeAlternatives;
}