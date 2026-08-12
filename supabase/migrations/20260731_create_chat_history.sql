-- Chatbot konuşma geçmişi tablosu (Gelişmiş versiyon)
create table if not exists public.chat_history (
    id uuid default gen_random_uuid() primary key,
    user_id uuid references auth.users(id) on delete cascade not null,
    session_id uuid default gen_random_uuid(), -- Farklı sohbet oturumlarını ayırmak için
    message text not null,
    role text not null check (role in ('user', 'assistant', 'system')),
    metadata jsonb default '{}'::jsonb, -- Ekstra veriler (token, model adı vb. için)
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS (Row Level Security) aktif etme
alter table public.chat_history enable row level security;

-- Kullanıcıların sadece kendi mesajlarını okuyabilmesi
create policy "Users can view their own chat history"
    on public.chat_history for select
    using (auth.uid() = user_id);

-- Kullanıcıların kendi mesajlarını ekleyebilmesi
create policy "Users can insert their own chat history"
    on public.chat_history for insert
    with check (auth.uid() = user_id);