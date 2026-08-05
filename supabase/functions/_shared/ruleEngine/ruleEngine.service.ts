import { resolveAllergenKeys } from "./allergen_dictionary.ts";

export function runRuleEngine(product: any, profile: any) {
  const userAllergies: string[] = profile?.allergies ?? [];

  // 1. Alerjen Eşleşmesi Kontrolü
  // Both sides are resolved to canonical keys and intersected; no substring
  // matching, so "Süt/Laktoz" matches "en:milk" but never "en:milk-chocolate".
  const productKeys: string[] = [];
  for (const tag of product.allergens_tags ?? []) {
    for (const key of resolveAllergenKeys(String(tag))) {
      if (!productKeys.includes(key)) productKeys.push(key);
    }
  }
  const productKeySet = new Set(productKeys);

  const profileKeys = new Set(
    userAllergies.flatMap((allergy) => resolveAllergenKeys(String(allergy))),
  );

  // Kept as the user's original profile strings — existing consumers read this.
  const matched = userAllergies.filter((allergy) =>
    resolveAllergenKeys(String(allergy)).some((key) => productKeySet.has(key))
  );

  // Every allergen found on the product, in tag order; matched=false means the
  // product has it but the profile does not.
  const allergens = productKeys.map((key) => ({
    key,
    matched: profileKeys.has(key),
  }));

  // 2. Vegan Uyumluluk Kontrolü (ürünün kendisi vegan mı?)
  const ingredients = (product.ingredients_text || "").toLowerCase();
  const allergensTags = product.allergens_tags || [];

  const nonVeganKeywords = [
    "süt", "milk", "peynir", "cheese", "yoğurt", "yogurt", "tereyağı", "butter",
    "yumurta", "egg", "bal", "honey", "et", "meat", "tavuk", "chicken", "jelatin", "gelatin"
  ];

  const hasNonVeganIngredient = nonVeganKeywords.some((keyword) => ingredients.includes(keyword));
  const hasNonVeganAllergen = allergensTags.some((tag: string) =>
    ["milk", "egg", "fish", "meat"].some((nonVeganTag) => tag.toLowerCase().includes(nonVeganTag))
  );

  const isVeganCompatible = !hasNonVeganIngredient && !hasNonVeganAllergen;

  // 3. Diyabet Değerlendirmesi (Şeker Oranına Göre, herkes için bilgilendirici)
  const sugars = product.nutriments?.sugars_100g ?? product.nutriments?.sugars ?? 0;
  let diabeticNote: string | null = null;

  if (sugars > 15) {
    diabeticNote = "Yüksek şeker oranı! Diyabet hastaları için önerilmez.";
  } else if (sugars > 5) {
    diabeticNote = "Orta seviye şeker oranı. Tüketirken dikkat edilmeli.";
  } else {
    diabeticNote = "Düşük şeker oranı. Diyabet dostu.";
  }

  // 4. Sporcu Profili Kontrolü (Protein Oranına Göre — PRD Senaryo 2)
  const proteins = product.nutriments?.proteins_100g ?? product.nutriments?.proteins ?? 0;
  let athleteNote: string | null = null;
  let isLowProteinForAthlete = false;

  // Gerçek şema: profiles.diet_preference — 'standard' | 'vegan' | 'vejetaryen' | 'diyabet_dostu' | 'sporcu'
  const dietPreference: string | undefined = profile?.diet_preference;
  const isVeganUser = dietPreference === "vegan";
  const isAthleteUser = dietPreference === "sporcu";

  if (isAthleteUser) {
    if (proteins < 5) {
      athleteNote = "Düşük protein oranı! Sporcu beslenmesi için yetersiz (Kırmızı Uyarı).";
      isLowProteinForAthlete = true;
    } else if (proteins <= 15) {
      athleteNote = "Orta seviye protein oranı (Sarı Uyarı).";
    } else {
      athleteNote = "Yüksek protein oranı! Sporcu dostu ürün.";
    }
  }

  // Çakışma Kontrolleri
  const hasVeganConflict = isVeganUser && !isVeganCompatible;
  const hasAthleteConflict = isLowProteinForAthlete;

  const hasConflict = matched.length > 0 || hasVeganConflict || hasAthleteConflict;

  return {
    matched_allergens: matched,
    allergens,
    has_conflict: hasConflict,
    diet_flags: {
      vegan_compatible: isVeganCompatible,
      diabetic_note: diabeticNote,
      athlete_note: athleteNote,
      protein_100g: proteins,
    },
  };
}

export function findMissingFields(product: any) {
  const missing: string[] = [];
  const n = product.nutriments;
  if (!n || Object.values(n).every((v) => v == null)) missing.push("nutriments");
  return missing;
}
