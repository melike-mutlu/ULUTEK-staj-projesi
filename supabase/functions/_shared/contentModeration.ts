/**
 * Deterministic content moderation for review text.
 * Simple word-list check with word-boundary matching (NOT a substring/.includes()
 * check) so that innocent words containing a banned substring are not
 * incorrectly flagged.
 *
 * NOTE: This is a starter list. Extend BANNED_WORDS as needed — keep it
 * lowercase, Turkish-locale-safe, and one word/phrase per entry.
 */

// Starter list — extend as needed. Keep entries lowercase.
const BANNED_WORDS: string[] = [
  "amk",
  "bok",
  "aq",
  "orospu",
  "piç",
  "yavşak",
  "siktir",
  "göt",
  "salak",
  "gerizekalı",
  "ibne",
];

/**
 * Escapes regex special characters in a word so it can be safely
 * embedded inside a RegExp pattern.
 */
function escapeRegExp(word: string): string {
  return word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Turkish-aware lowercasing. JS's default toLowerCase() mishandles the
 * Turkish dotless/dotted I pair (İ -> i, I -> ı), which matters for
 * matching words like "İbne"/"IBNE" correctly.
 *
 * Also applies Unicode NFC normalization first, so that characters typed
 * via different keyboards/inputs (e.g. a base letter + combining mark vs.
 * a single precomposed character) compare equal.
 */
function toTurkishLower(text: string): string {
  return text
    .normalize("NFC")
    .replace(/İ/g, "i")
    .replace(/I/g, "ı")
    .toLocaleLowerCase("tr-TR");
}

/**
 * Checks whether `text` contains any banned word as a whole word
 * (word-boundary match), case-insensitively. This deliberately avoids
 * plain .includes() so that, e.g., a banned short word embedded inside
 * an unrelated longer word does not trigger a false positive.
 *
 * Case-insensitivity is handled twice, deliberately: once via
 * toTurkishLower() (which correctly handles the Turkish I/İ/ı/i pair),
 * and again via the "i" regex flag as a cheap extra safety layer.
 * "_" is included in the boundary character class alongside letters/digits
 * so that e.g. "mal_123" or "bir_mal_var" don't count "mal" as standalone.
 */
export function containsInappropriateContent(text: string): boolean {
  const normalized = toTurkishLower(text);

  return BANNED_WORDS.some((word) => {
    const pattern = new RegExp(
      `(?<![\\p{L}\\p{N}_])${escapeRegExp(word)}(?![\\p{L}\\p{N}_])`,
      "iu",
    );
    return pattern.test(normalized);
  });
}