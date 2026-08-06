/**
 * Akıllı Sepet — Profil JSON Parser
 *
 * Görev: LLM çıktısını veya ham kullanıcı girdisini
 * standart ProfileSchema formatına normalize eder.
 *
 * Çıktı şeması:
 * {
 *   "allergies": string[],   // bilinen alerjiler (gluten, fındık, süt...)
 *   "diets":     string[],   // diyet tercihleri (vegan, ketojenik...)
 *   "goals":     string[],   // sağlık hedefleri (kilo ver, şeker kontrolü...)
 *   "avoid":     string[]    // kaçınılacak içerikler (şeker, tuz, kırmızı et...)
 * }
 */

// ─────────────────────────────────────────────
// Tip tanımları
// ─────────────────────────────────────────────

export interface ProfileSchema {
  allergies: string[];
  /** All selected diets — diet_preference is text[], so a user may have several. */
  diets: string[];
  goals: string[];
  avoid: string[];
}

/** parse() başarısız olursa döner — ham girdiyi de taşır */
export interface ProfileParseError {
  success: false;
  error: string;
  raw: unknown;
}

export interface ProfileParseSuccess {
  success: true;
  profile: ProfileSchema;
}

export type ProfileParseResult = ProfileParseSuccess | ProfileParseError;

// ─────────────────────────────────────────────
// Bilinen değer listeleri (normalize için)
// ─────────────────────────────────────────────

const KNOWN_DIETS = [
  "standard", "vegan", "vejetaryen", "diyabet_dostu",
  "sporcu", "glutensiz", "laktozsuz", "ketojenik", "paleo",
];

// ─────────────────────────────────────────────
// Ana parser
// ─────────────────────────────────────────────

/**
 * Ham JSON (LLM ciktisi ya da istek body'si) -> ProfileSchema
 *
 * Kurallar:
 * - Eksik alan varsa bos dizi / bos string ile doldur (null/undefined kabul etme)
 * - String olarak gelen liste degerlerini diziye cevir ("gluten, sut" -> ["gluten","sut"])
 * - Bilinen degerlerle eslestirerek normalize et (buyuk/kucuk harf, Turkce karakter)
 * - Bilinmeyen degerleri reddetme; lowercase trim yaparak oldugu gibi sakla
 */
export function parseProfile(raw: unknown): ProfileParseResult {
  if (raw === null || raw === undefined) {
    return { success: false, error: "Girdi bos (null/undefined)", raw };
  }

  if (typeof raw !== "object" || Array.isArray(raw)) {
    return {
      success: false,
      error: `Girdi nesne degil: ${typeof raw}`,
      raw,
    };
  }

  const obj = raw as Record<string, unknown>;

  const allergies = parseStringList(obj["allergies"]);
  const diets     = parseDietList(obj["diet"] ?? obj["diets"]);
  const goals     = parseStringList(obj["goals"]);
  const avoid     = parseStringList(obj["avoid"]);

  return {
    success: true,
    profile: { allergies, diets, goals, avoid },
  };
}

// ─────────────────────────────────────────────
// Yardimci fonksiyonlar
// ─────────────────────────────────────────────

/**
 * Dizi ya da virgülle ayrilmis string -> normalize string[]
 * Ornekler:
 *   ["Gluten", " Sut "]  -> ["gluten", "sut"]
 *   "gluten, sut"        -> ["gluten", "sut"]
 *   null / undefined     -> []
 */
function parseStringList(value: unknown): string[] {
  if (value === null || value === undefined) return [];

  let items: string[] = [];

  if (typeof value === "string") {
    items = value.split(/[,;|]+/);
  } else if (Array.isArray(value)) {
    items = value
      .filter((v) => v !== null && v !== undefined)
      .map((v) => String(v));
  } else {
    items = [String(value)];
  }

  return items
    .map((s) => normalizeTr(s))
    .filter((s) => s.length > 0);
}

/**
 * Diyet listesini normalize eder. Dizi ya da virgüllü string kabul eder;
 * "standard" (tercih yok) elenir. Bilinmeyen diyetler olduğu gibi korunur ki
 * LLM onları da görsün.
 */
function parseDietList(value: unknown): string[] {
  return parseStringList(value)
    .map(normalizeDiet)
    .filter((diet) => diet.length > 0 && diet !== "standard");
}

/** Tek bir diyet değerini bilinen kataloğa (yaklaşık) eşler. */
function normalizeDiet(raw: string): string {
  if (KNOWN_DIETS.includes(raw)) return raw;
  const partial = KNOWN_DIETS.find((d) => d.includes(raw) || raw.includes(d));
  return partial ?? raw;
}

/**
 * Turkce karakter duyarli lowercase + trim
 */
function normalizeTr(s: string): string {
  return s
    .trim()
    .toLowerCase()
    .replace(/\u0130/g, "i")
    .replace(/I/g, "\u0131")
    .replace(/\u011e/g, "\u011f")
    .replace(/\u00dc/g, "\u00fc")
    .replace(/\u015e/g, "\u015f")
    .replace(/\u00d6/g, "\u00f6")
    .replace(/\u00c7/g, "\u00e7");
}

// ─────────────────────────────────────────────
// Bos / varsayilan profil
// ─────────────────────────────────────────────

export function emptyProfile(): ProfileSchema {
  return { allergies: [], diets: [], goals: [], avoid: [] };
}

// ─────────────────────────────────────────────
// Mevcut UserProfile (Supabase) -> ProfileSchema donusumu
// Mobil pod'un gonderdigi formati AI semasina cevirir.
// ─────────────────────────────────────────────

/**
 * Supabase `profiles` tablosundan gelen nesneyi
 * ProfileSchema'ya cevirir.
 *
 * Supabase formati:
 *   { user_id, allergies, diet_preference, health_conditions }
 *
 * ProfileSchema formati:
 *   { allergies, diets, goals, avoid }
 */
export function fromSupabaseProfile(supabase: Record<string, unknown>): ProfileSchema {
  const allergies = parseStringList(supabase["allergies"]);
  const diets     = parseDietList(supabase["diet_preference"]);

  const conditions = parseStringList(supabase["health_conditions"]);
  const goals: string[] = [];
  const avoid: string[] = [];

  for (const condition of conditions) {
    if (
      condition.includes("diyabet") ||
      condition.includes("tansiyon") ||
      condition.includes("kolesterol") ||
      condition.includes("kilo")
    ) {
      goals.push(`${condition} kontrolu`);
    } else {
      avoid.push(condition);
    }
  }

  return { allergies, diets, goals, avoid };
}
