// supabase/functions/_shared/alternativeProducts.service.ts

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

interface EvaluatedAlternative extends AlternativeProduct {
  similarity: number;
}

const IGNORED_CATEGORIES = new Set([
  "en:foods",
  "en:groceries",
  "en:plant-based-foods",
  "en:plant-based-foods-and-beverages",
  "en:beverages-and-beverages-preparations",
]);

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

  return unionCount === 0
    ? 0
    : intersectionCount / unionCount;
}

function isSafeAlternative(ruleResult: any): boolean {
  if (!ruleResult) return false;

  if (ruleResult.data_sufficiency === "insufficient") {
    return false;
  }

  return !ruleResult.has_conflict && !ruleResult.hasConflict;
}

const scoreOrder: Record<string, number> = {
  A: 1,
  B: 2,
  C: 3,
  D: 4,
  E: 5,
};

export async function findSafeAlternatives(
  scannedProduct: ProductData,
  userProfile: UserProfile,
  _supabaseClient: any,
  limit: number = 3,
): Promise<AlternativeProduct[]> {
  const scannedCategories: string[] =
    scannedProduct.categories_tags ?? [];

  if (scannedCategories.length === 0) return [];

  const scannedFiltered = scannedCategories.filter(
    (c) => !IGNORED_CATEGORIES.has(c),
  );

  if (scannedFiltered.length === 0) return [];

  const scannedSet = new Set<string>(scannedFiltered);
  const scannedBarcode =
    scannedProduct.barcode || scannedProduct.code;

  // En spesifik 4 kategoriye kadar tara ve aday havuzlarını birleştir.
  const categoriesToTry =
    scannedFiltered.slice(-4).reverse();

  const rawCandidatesMap = new Map<string, any>();

  for (const category of categoriesToTry) {
    try {
      const results =
        await searchProductsByCategory(category, 30);

      if (Array.isArray(results)) {
        for (const item of results) {
          const bCode = item.barcode || item.code;

          if (
            bCode &&
            bCode !== scannedBarcode &&
            !rawCandidatesMap.has(bCode)
          ) {
            rawCandidatesMap.set(bCode, item);
          }
        }
      }
    } catch (e) {
      console.error("OFF Arama Hatası:", e);
    }
  }

  const rawCandidates =
    Array.from(rawCandidatesMap.values());

  if (rawCandidates.length === 0) return [];

  // Adayların kategori benzerliğini hesapla.
  const scoredCandidates = rawCandidates
    .map((candidate) => {
      const candidateCategories: string[] =
        candidate.categories_tags ?? [];

      const candidateFiltered =
        candidateCategories.filter(
          (c) => !IGNORED_CATEGORIES.has(c),
        );

      const candidateSet =
        new Set<string>(candidateFiltered);

      const similarity =
        calculateJaccardSimilarity(
          scannedSet,
          candidateSet,
        );

      return {
        candidate,
        similarity,
        barcode: candidate.barcode || candidate.code,
      };
    })
    .filter((item) => item.similarity >= 0.02);

  const allSafeCandidates: EvaluatedAlternative[] = [];

  // Tüm adayları Rule Engine'den geçir.
  // Limit'e ulaşıldığında döngüyü kesmiyoruz;
  // böylece daha iyi Nutri-Score'a sahip adayları
  // sonradan değerlendirebiliyoruz.
  for (
    const {
      candidate,
      similarity,
      barcode,
    } of scoredCandidates
  ) {
    const ruleResult =
      runRuleEngine(candidate, userProfile);

    // Sağlık/diyet/alergen açısından uygun olmayanları çıkar.
    if (!isSafeAlternative(ruleResult)) continue;

    const grade = (
      candidate.nutriscore_grade ??
      candidate.nutriscore
    )?.toUpperCase();

    allSafeCandidates.push({
      barcode: barcode ?? "0000000000000",
      product_name:
        candidate.product_name_tr ??
        candidate.product_name ??
        candidate.name ??
        "Bilinmeyen Ürün",
      brand:
        candidate.brands ||
        candidate.brand,
      image_url:
        candidate.image_front_small_url ||
        candidate.image_url ||
        candidate.image_front_url,
      nutriscore_grade: grade,
      is_safe: true,
      similarity,
      recommendation_reason: grade
        ? `Nutri-Score ${grade} kalitesinde ve sağlık profilinizle uyumlu.`
        : "Sağlık ve diyet profilinizle uyumlu.",
    });
  }

  // Önce daha iyi Nutri-Score,
  // aynı Nutri-Score'da ise daha yüksek
  // kategori benzerliği.
  allSafeCandidates.sort((a, b) => {
    const scoreA =
      scoreOrder[a.nutriscore_grade ?? "Z"] ?? 99;

    const scoreB =
      scoreOrder[b.nutriscore_grade ?? "Z"] ?? 99;

    if (scoreA !== scoreB) {
      return scoreA - scoreB;
    }

    return b.similarity - a.similarity;
  });

  const finalAlternatives =
    allSafeCandidates.slice(0, limit);

  console.log("Alternative search completed", {
    barcode: scannedBarcode,
    candidatesFound: scoredCandidates.length,
    safeCandidatesTotal: allSafeCandidates.length,
    alternativesReturned: finalAlternatives.length,
  });

  return finalAlternatives.map(
    ({ similarity, ...rest }) => rest,
  );
}
