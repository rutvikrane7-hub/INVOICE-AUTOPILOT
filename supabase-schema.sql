-- ================================================================
-- Invoice Autopilot — Supabase Database Schema
-- Run this SQL in: Supabase Dashboard > SQL Editor > New Query
-- ================================================================

-- ── Profiles table ────────────────────────────────────────────────
-- Extends auth.users with plan information
CREATE TABLE IF NOT EXISTS profiles (
  id              UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email           TEXT,
  plan            TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'business')),
  plan_expires_at TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, plan)
  VALUES (NEW.id, NEW.email, 'free')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


-- ── Invoices table ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS invoices (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_name  TEXT NOT NULL,
  amount       NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
  currency     TEXT NOT NULL DEFAULT 'INR' CHECK (currency IN ('INR', 'USD', 'EUR', 'GBP')),
  due_date     DATE NOT NULL,
  project_name TEXT,
  status       TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid')),
  paid_at      TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast user-scoped queries
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_due_date ON invoices(due_date);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);

DROP TRIGGER IF EXISTS update_invoices_updated_at ON invoices;
CREATE TRIGGER update_invoices_updated_at
  BEFORE UPDATE ON invoices
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


-- ── Row Level Security ────────────────────────────────────────────

-- Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);


-- Invoices
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own invoices"
  ON invoices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own invoices"
  ON invoices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own invoices"
  ON invoices FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own invoices"
  ON invoices FOR DELETE
  USING (auth.uid() = user_id);


-- ── Enable Realtime ───────────────────────────────────────────────
-- Run this in Supabase Dashboard > Database > Replication
-- and enable the 'invoices' and 'profiles' tables for realtime.
-- Or uncomment the lines below:

-- ALTER PUBLICATION supabase_realtime ADD TABLE invoices;
-- ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
