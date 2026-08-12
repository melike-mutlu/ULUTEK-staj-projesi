-- profiles tablosuna is_premium sütununun eklenmesi
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS is_premium boolean DEFAULT false;