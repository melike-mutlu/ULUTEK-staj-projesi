// TODO (Backend pod): diyet tercihine göre gerçek diet_flags mantığı (vegan/diyabet) genişletilecek.
export function runRuleEngine(product: any, profile: any) {
  const userAllergies: string[] = profile?.allergies ?? [];
  
  // 1. Alerjen Eşleşmesi Kontrolü (Mevcut yapı korundu)
  const matched = userAllergies.filter((allergy) =>
    (product.allergens_tags ?? []).some((tag: string) =>
      tag.toLowerCase().includes(allergy.toLowerCase())
    )
  );

  // 2. Vegan Uyumluluk Kontrolü
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

  // 3. Diyabet Değerlendirmesi Kontrolü (Şeker Oranına Göre)
  const sugars = product.nutriments?.sugars_100g ?? product.nutriments?.sugars ?? 0;
  let diabeticNote: string | null = null;

  if (sugars > 15) {
    diabeticNote = "Yüksek şeker oranı! Diyabet hastaları için önerilmez.";
  } else if (sugars > 5) {
    diabeticNote = "Orta seviye şeker oranı. Tüketirken dikkat edilmeli.";
  } else {
    diabeticNote = "Düşük şeker oranı. Diyabet dostu.";
  }

  // Kullanıcı tercihi ile çakışma kontrolü
  const hasVeganConflict = profile?.dietary_preferences?.is_vegan && !isVeganCompatible;
  const hasConflict = matched.length > 0 || hasVeganConflict;

  return {
    matched_allergens: matched,
    has_conflict: hasConflict,
    diet_flags: {
      vegan_compatible: isVeganCompatible,
      diabetic_note: diabeticNote,
    },
  };
}

export function findMissingFields(product: any) {
  const missing: string[] = [];
  const n = product.nutriments;
  if (!n || Object.values(n).every((v) => v == null)) missing.push("nutriments");
  return missing;
}