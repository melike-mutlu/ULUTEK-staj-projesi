import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { validateReviewText } from "./reviewValidation.ts";

// product_reviews tablosundaki bir satırın tip tanımı
export interface ProductReview {
  id?: string;
  product_barcode: string;
  user_id: string;
  rating: number;
  comment: string;
  created_at?: string;
  updated_at?: string;
}

/**
 * Yeni bir ürün yorumu ekler.
 *
 * Validasyon DB'ye gitmeden önce yapılır.
 * Comment için:
 * - boş / whitespace-only kontrolü
 * - maksimum 500 karakter kontrolü
 * - uygunsuz içerik kontrolü
 *
 * Rating için:
 * - 1 ile 5 arasında olmalıdır.
 */
export async function addProductReview(
  supabase: SupabaseClient,
  userId: string,
  productBarcode: string,
  rating: number,
  comment: string,
): Promise<
  | { success: true; data: ProductReview }
  | { success: false; error: string }
> {
  const validation = validateReviewText(comment);

  if (!validation.valid) {
    return {
      success: false,
      error: validation.error!,
    };
  }

  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    return {
      success: false,
      error: "invalid_rating",
    };
  }

  const { data, error } = await supabase
    .from("product_reviews")
    .insert([
      {
        user_id: userId,
        product_barcode: productBarcode,
        rating,
        comment: comment.trim(),
      },
    ])
    .select()
    .single();

  if (error) {
    console.error("Yorum eklenirken hata oluştu:", error);
    throw error;
  }

  return {
    success: true,
    data: data as ProductReview,
  };
}

/**
 * Belirli bir ürüne ait yorumları listeler.
 * En yeni yorum en üstte olacak şekilde sıralanır.
 */
export async function listProductReviews(
  supabase: SupabaseClient,
  productBarcode: string,
): Promise<ProductReview[]> {
  const { data, error } = await supabase
    .from("product_reviews")
    .select("*")
    .eq("product_barcode", productBarcode)
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Yorumlar alınırken hata oluştu:", error);
    throw error;
  }

  return data as ProductReview[];
}

/**
 * Bir kullanıcının kendi yorumunu siler.
 *
 * RLS zaten kullanıcının yalnızca kendi yorumunu
 * silebilmesini sağlayacak şekilde yapılandırılmalıdır.
 * Buna ek olarak user_id query'ye dahil edilerek
 * ikinci bir güvenlik katmanı sağlanır.
 */
export async function deleteProductReview(
  supabase: SupabaseClient,
  userId: string,
  reviewId: string,
): Promise<void> {
  const { error } = await supabase
    .from("product_reviews")
    .delete()
    .eq("id", reviewId)
    .eq("user_id", userId);

  if (error) {
    console.error("Yorum silinirken hata oluştu:", error);
    throw error;
  }
}
