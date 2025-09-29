create extension if not exists pgcrypto;

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  region text not null default 'KE',
  language text not null default 'en',
  consents jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  type text not null,
  answers jsonb not null,
  risk_score numeric,
  explanation text,
  created_at timestamptz not null default now()
);

create index if not exists idx_assessments_user_id on assessments(user_id);

create table if not exists alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  type text not null,
  schedule_at timestamptz not null,
  delivered_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_alerts_user_id on alerts(user_id);
