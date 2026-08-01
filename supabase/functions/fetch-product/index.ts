import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { runRuleEngine, findMissingFields } from "../../services/ruleEngine/ruleEngine.service.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { product, profile } = await req.json();

    if (!product) {
      return new Response(JSON.stringify({ error: "Product data required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const ruleResult = runRuleEngine(product, profile);
    const missingFields = findMissingFields(product);

    return new Response(
      JSON.stringify({
        ...ruleResult,
        missing_fields: missingFields,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});