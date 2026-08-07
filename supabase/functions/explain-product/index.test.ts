import { assertEquals } from "jsr:@std/assert@^1";
import {
  callLlmPlaceholder,
  clampToFloor,
  ruleFloorLevel,
  validateLlmResponse,
} from "./index.ts";
import { fromSupabaseProfile, parseProfile } from "./profile_parser.ts";

Deno.test("ruleFloorLevel: çakışma varsa warning", () => {
  assertEquals(ruleFloorLevel({ has_conflict: true }), "warning");
  assertEquals(ruleFloorLevel({ matched_allergens: ["milk"] }), "warning");
  assertEquals(ruleFloorLevel({ has_conflict: false, matched_allergens: [] }), "ok");
});

Deno.test("clampToFloor: LLM seviyeyi düşüremez, yükseltebilir", () => {
  // floor warning: LLM "ok" dese bile warning kalır
  assertEquals(clampToFloor("ok", "warning"), "warning");
  assertEquals(clampToFloor("caution", "warning"), "warning");
  assertEquals(clampToFloor("warning", "warning"), "warning");
  // floor ok: LLM yükseltebilir
  assertEquals(clampToFloor("ok", "ok"), "ok");
  assertEquals(clampToFloor("caution", "ok"), "caution");
  assertEquals(clampToFloor("warning", "ok"), "warning");
  // geçersiz seviye -> floor
  assertEquals(clampToFloor("banana", "ok"), "ok");
});

Deno.test("validateLlmResponse: LLM 'ok' dese de floor warning ise warning", () => {
  const out = validateLlmResponse({
    summary: "özet",
    personal_warning: { level: "ok", message: "her şey yolunda" },
    disclaimer: "tıbbi tavsiye değildir",
  }, "warning");

  assertEquals(out.personal_warning.level, "warning");
  assertEquals(out.personal_warning.message, "her şey yolunda");
});

Deno.test("validateLlmResponse: eksik alanda placeholder, floor korunur", () => {
  const out = validateLlmResponse({ summary: "x" }, "warning");
  assertEquals(out.personal_warning.level, "warning");
});

Deno.test("callLlmPlaceholder: seviye floor'dan gelir, hardcoded 'ok' değil", () => {
  assertEquals(callLlmPlaceholder("test", "warning").personal_warning.level, "warning");
  assertEquals(callLlmPlaceholder("test", "ok").personal_warning.level, "ok");
});

Deno.test("fromSupabaseProfile birden çok diyeti korur (text[])", () => {
  const profile = fromSupabaseProfile({
    allergies: [],
    diet_preference: ["Vegan", "Ketojenik"],
    health_conditions: [],
  });

  assertEquals(profile.diets, ["vegan", "ketojenik"]);
});

Deno.test("fromSupabaseProfile eski tekil string diyeti de kabul eder", () => {
  const profile = fromSupabaseProfile({
    diet_preference: "vegan",
    allergies: [],
    health_conditions: [],
  });

  assertEquals(profile.diets, ["vegan"]);
});

Deno.test("parseDietList standard/boş değerleri eler, bilinmeyeni korur", () => {
  const result = parseProfile({ diets: ["standard", "Sirke Diyeti", ""] });
  if (!result.success) throw new Error("parse failed");
  assertEquals(result.profile.diets, ["sirke diyeti"]);
});
