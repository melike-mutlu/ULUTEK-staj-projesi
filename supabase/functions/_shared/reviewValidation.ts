/**
 * Step 1: Basic validation for review text.
 * Checks: empty, whitespace-only, over max length.
 * Profanity/inappropriate-content check comes in a later step.
 */

import { containsInappropriateContent } from "./contentModeration.ts";

export interface ValidationResult {
  valid: boolean;
  error?: "empty" | "too_long" | "inappropriate";
}

const MAX_REVIEW_LENGTH = 500;

export function validateReviewText(text: string): ValidationResult {
  const trimmed = text.trim();

  if (trimmed.length === 0) {
    return { valid: false, error: "empty" };
  }

  if (text.length > MAX_REVIEW_LENGTH) {
    return { valid: false, error: "too_long" };
  }
    if (containsInappropriateContent(text)) {
    return { valid: false, error: "inappropriate" };
  }

  return { valid: true };
}