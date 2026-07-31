export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

export function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Deno.serve girişinde: `if (req.method === "OPTIONS") return handleCorsPreflight();`
export function handleCorsPreflight() {
  return new Response("ok", { headers: corsHeaders });
}
