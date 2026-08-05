import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

// Mesaj rolleri için tip tanımı
export type ChatRole = 'user' | 'assistant' | 'system';

// Mesaj nesnesi arayüzü
export interface ChatMessage {
  id?: string;
  user_id: string;
  session_id?: string;
  message: string;
  role: ChatRole;
  metadata?: Record<string, any>;
  created_at?: string;
}

/**
 * 1. Mesajı chat_history tablosuna kaydetme fonksiyonu
 */
export async function saveMessage(
  supabase: SupabaseClient,
  userId: string,
  sessionId: string,
  message: string,
  role: ChatRole,
  metadata: Record<string, any> = {}
): Promise<any> {
  const { data, error } = await supabase
    .from('chat_history')
    .insert([
      {
        user_id: userId,
        session_id: sessionId,
        message: message,
        role: role,
        metadata: metadata
      }
    ]);

  if (error) {
    console.error('Mesaj kaydedilirken hata oluştu:', error);
    throw error;
  }
  return data;
}

/**
 * 2. Sohbet geçmişini çekip LLM'e besleme fonksiyonu
 */
export async function getConversationHistory(
  supabase: SupabaseClient,
  userId: string,
  sessionId: string | null = null
): Promise<ChatMessage[]> {
  let query = supabase
    .from('chat_history')
    .select('*')
    .eq('user_id', userId);

  if (sessionId) {
    query = query.eq('session_id', sessionId);
  }

  const { data, error } = await query.order('created_at', { ascending: true });

  if (error) {
    console.error('Sohbet geçmişi alınırken hata oluştu:', error);
    throw error;
  }

  return data as ChatMessage[];
}
