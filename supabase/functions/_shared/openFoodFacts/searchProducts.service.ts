// supabase/functions/_shared/openFoodFacts/searchProducts.service.ts

export interface SearchProductResult {
  barcode: string;
  product_name: string;
  brand?: string;
  image_url?: string;
  nutriscore_grade?: string;
  categories_tags?: string[];
}

/**
 * Ürün ismiyle Open Food Facts arama API'sine sorgu atar.
 */
export async function searchProductsByName(
  query: string,
  pageSize: number = 10,
): Promise<SearchProductResult[]> {
  const trimmedQuery = query.trim();

  if (!trimmedQuery) {
    return [];
  }

  try {
    const url = new URL(
      "https://world.openfoodfacts.org/cgi/search.pl",
    );

    url.searchParams.append("search_terms", trimmedQuery);
    url.searchParams.append("search_simple", "1");
    url.searchParams.append("action", "process");
    url.searchParams.append("json", "1");
    url.searchParams.append("page_size", pageSize.toString());

    url.searchParams.append(
      "fields",
      "code,product_name,product_name_tr,brands,image_front_small_url,nutriscore_grade,categories_tags",
    );

    const response = await fetch(url.toString(), {
      headers: {
        "User-Agent": "UlutekStajProject/1.0 (Android/iOS)",
      },
    });

    if (!response.ok) {
      console.error(`OFF Search API hatası: ${response.status}`);
      return [];
    }

    const data = await response.json();

    if (!Array.isArray(data.products)) {
      return [];
    }

    return data.products
      .filter((p: any) => p.code && (p.product_name || p.product_name_tr))
      .map((p: any) => ({
        barcode: p.code,
        product_name:
          p.product_name_tr || p.product_name || "Bilinmeyen Ürün",
        brand: p.brands ?? "",
        image_url: p.image_front_small_url ?? "",
        nutriscore_grade: p.nutriscore_grade?.toUpperCase(),
        categories_tags: p.categories_tags ?? [],
      }));
  } catch (error) {
    console.error("Ürün arama servisinde hata oluştu:", error);
    return [];
  }
}