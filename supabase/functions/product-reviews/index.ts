import {
  handleCorsPreflight,
  jsonResponse,
} from "../_shared/http.ts";

import { getUserClient } from "../_shared/lib/supabaseClient.ts";

import {
  addProductReview,
  listProductReviews,
  deleteProductReview,
} from "../_shared/productReview.service.ts";

Deno.serve(async (req: Request) => {
  // ---------------------------------------------------------
  // CORS preflight
  // ---------------------------------------------------------
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const supabase = getUserClient(req);

    // -------------------------------------------------------
    // POST - Add a product review
    // -------------------------------------------------------
    if (req.method === "POST") {
      // Get authenticated user
      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();

      if (authError || !user) {
        return jsonResponse(
          {
            success: false,
            error: "unauthorized",
          },
          401,
        );
      }

      let body: unknown;

      try {
        body = await req.json();
      } catch {
        return jsonResponse(
          {
            success: false,
            error: "invalid_json",
          },
          400,
        );
      }

      // Make sure the request body is an object
      if (
        typeof body !== "object" ||
        body === null
      ) {
        return jsonResponse(
          {
            success: false,
            error: "invalid_request_body",
          },
          400,
        );
      }

      const {
        product_barcode,
        rating,
        comment,
      } = body as {
        product_barcode?: unknown;
        rating?: unknown;
        comment?: unknown;
      };

      // Validate product barcode
      if (
        typeof product_barcode !== "string" ||
        product_barcode.trim().length === 0
      ) {
        return jsonResponse(
          {
            success: false,
            error: "invalid_product_barcode",
          },
          400,
        );
      }

      // Validate rating
      if (
        typeof rating !== "number" ||
        !Number.isInteger(rating) ||
        rating < 1 ||
        rating > 5
      ) {
        return jsonResponse(
          {
            success: false,
            error: "invalid_rating",
          },
          400,
        );
      }

      // Comment must be a string.
      // Empty/whitespace/500-character/profanity validation
      // is handled by productReview.service.ts.
      if (typeof comment !== "string") {
        return jsonResponse(
          {
            success: false,
            error: "invalid_comment",
          },
          400,
        );
      }

      const result = await addProductReview(
        supabase,
        user.id,
        product_barcode.trim(),
        rating,
        comment,
      );

      if (!result.success) {
        switch (result.error) {
          case "empty":
          case "too_long":
          case "inappropriate":
          case "invalid_rating":
            return jsonResponse(
              {
                success: false,
                error: result.error,
              },
              400,
            );

          default:
            return jsonResponse(
              {
                success: false,
                error: result.error,
              },
              500,
            );
        }
      }

      return jsonResponse(
        {
          success: true,
          data: result.data,
        },
        201,
      );
    }

    // -------------------------------------------------------
    // GET - List product reviews
    // -------------------------------------------------------
    if (req.method === "GET") {
      const url = new URL(req.url);

      const productBarcode =
        url.searchParams.get("product_barcode");

      if (
        !productBarcode ||
        productBarcode.trim().length === 0
      ) {
        return jsonResponse(
          {
            success: false,
            error: "invalid_product_barcode",
          },
          400,
        );
      }

      const reviews = await listProductReviews(
        supabase,
        productBarcode.trim(),
      );

      return jsonResponse(
        {
          success: true,
          data: reviews,
        },
        200,
      );
    }

    // -------------------------------------------------------
    // DELETE - Delete user's own review
    // -------------------------------------------------------
    if (req.method === "DELETE") {
      // Get authenticated user
      const {
        data: { user },
        error: authError,
      } = await supabase.auth.getUser();

      if (authError || !user) {
        return jsonResponse(
          {
            success: false,
            error: "unauthorized",
          },
          401,
        );
      }

      const url = new URL(req.url);

      const reviewId =
        url.searchParams.get("review_id");

      if (
        !reviewId ||
        reviewId.trim().length === 0
      ) {
        return jsonResponse(
          {
            success: false,
            error: "invalid_review_id",
          },
          400,
        );
      }

      await deleteProductReview(
        supabase,
        user.id,
        reviewId.trim(),
      );

      return jsonResponse(
        {
          success: true,
          message: "review_deleted",
        },
        200,
      );
    }

    // -------------------------------------------------------
    // Unsupported HTTP method
    // -------------------------------------------------------
    return jsonResponse(
      {
        success: false,
        error: "method_not_allowed",
      },
      405,
    );
  } catch (error) {
    console.error(
      "Product reviews Edge Function error:",
      error,
    );

    // PostgreSQL unique constraint:
    // one user can have only one review per product.
    if (
      error &&
      typeof error === "object" &&
      "code" in error &&
      error.code === "23505"
    ) {
      return jsonResponse(
        {
          success: false,
          error: "review_already_exists",
        },
        409,
      );
    }

    return jsonResponse(
      {
        success: false,
        error: "internal_server_error",
      },
      500,
    );
  }
});