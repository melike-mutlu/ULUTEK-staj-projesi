// supabase/functions/_shared/openFoodFacts/searchProducts.service.ts

export interface SearchProductResult {
  barcode: string;
  product_name: string;
  brand?: string;
  image_url?: string;
  nutriscore_grade?: string;
  categories_tags?: string[];
}

/** Gecici sunucu hatalarinda tek seferlik retry tetikler. */
const RETRYABLE_STATUS_CODES = new Set([502, 503, 504]);

/**
 * Ürün ismiyle Open Food Facts arama API'sine sorgu atar.
 *
 * search.openfoodfacts.org (search-a-licious) kullaniliyor - eski
 * world.openfoodfacts.org/cgi/search.pl endpoint'i su anda cok sik
 * 503 donuyor (JSON yerine HTML "temporarily unavailable" sayfasi),
 * bu da kod tarafinda sessizce bos sonuc olarak yorumlaniyordu; kullanici
 * icin "bu urun bulunamadi" gibi goruyordu ama aslinda gecici bir sunucu
 * hatasiydi. Yeni endpoint testlerde tutarli sekilde calisti ve buyuk/
 * kucuk harf farki gozetmiyor (arama zaten case-insensitive).
 */
export async function searchProductsByName(
  query: string,
  pageSize: number = 10,
): Promise<SearchProductResult[]> {
  const trimmedQuery = query.trim();

  if (!trimmedQuery) {
    return [];
  }

  const url = new URL("https://search.openfoodfacts.org/search");
  url.searchParams.append("q", trimmedQuery);
  url.searchParams.append("page_size", pageSize.toString());
  url.searchParams.append(
    "fields",
    "code,product_name,product_name_tr,brands,image_front_small_url,nutriscore_grade,categories_tags",
  );

  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const response = await fetch(url.toString(), {
        headers: {
          "User-Agent": "UlutekStajProject/1.0 (Android/iOS)",
        },
      });

      if (!response.ok) {
        console.error(`OFF Search API hatası: ${response.status}`);
        if (attempt === 0 && RETRYABLE_STATUS_CODES.has(response.status)) {
          continue;
        }
        return [];
      }

      const data = await response.json();

      if (!Array.isArray(data.hits)) {
        return [];
      }

      return data.hits
        .filter((p: any) => p.code && (p.product_name || p.product_name_tr))
        .map((p: any) => ({
          barcode: p.code,
          product_name:
            p.product_name_tr || p.product_name || "Bilinmeyen Ürün",
          brand: Array.isArray(p.brands)
            ? p.brands.join(", ")
            : (p.brands ?? ""),
          image_url: p.image_front_small_url ?? "",
          nutriscore_grade: p.nutriscore_grade?.toUpperCase(),
          categories_tags: p.categories_tags ?? [],
        }));
    } catch (error) {
      console.error("Ürün arama servisinde hata oluştu:", error);
      if (attempt === 0) continue;
      return [];
    }
  }

  return [];
}