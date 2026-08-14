import { assertEquals } from "jsr:@std/assert@^1";
import {
  getAdditiveInfo,
  normalizeAdditiveCode,
} from "./additives_dictionary.ts";

Deno.test("normalizeAdditiveCode tags ve kod tiplerini doğru ayrıştırır", () => {
  assertEquals(normalizeAdditiveCode("en:e330"), "e330");
  assertEquals(normalizeAdditiveCode("E-330"), "e330");
  assertEquals(normalizeAdditiveCode("E 621"), "e621");
  assertEquals(normalizeAdditiveCode("330"), "e330");
  assertEquals(normalizeAdditiveCode("e150d"), "e150d");
});

Deno.test("getAdditiveInfo bilinen E-kodları için doğru sözlük açıklamasını döndürür", () => {
  const e330 = getAdditiveInfo("en:e330");
  assertEquals(e330.code, "E330");
  assertEquals(e330.name, "Sitrik Asit (Limon Tuzu)");
  assertEquals(e330.riskLevel, "safe");

  const e621 = getAdditiveInfo("E621");
  assertEquals(e621.code, "E621");
  assertEquals(e621.isControversial, true);
  assertEquals(e621.riskLevel, "caution");

  const e250 = getAdditiveInfo("en:e250");
  assertEquals(e250.code, "E250");
  assertEquals(e250.riskLevel, "avoid");
});

Deno.test("getAdditiveInfo bilinmeyen E-kodları için varsayılan fallback nesnesi üretir", () => {
  const unknown = getAdditiveInfo("en:e9999");
  assertEquals(unknown.code, "E9999");
  assertEquals(unknown.riskLevel, "safe");
  assertEquals(
    unknown.description,
    "Bu katkı maddesi için henüz detaylı bir açıklama tanımlanmamıştır.",
  );
});
