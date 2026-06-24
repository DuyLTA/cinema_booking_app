-- Demo ticket storage for the Flutter Tickets tab.
-- Run in Supabase SQL Editor if you want booked tickets to persist after app restart.

create extension if not exists pgcrypto;

create table if not exists booked_tickets (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  payload jsonb not null,
  booked_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

alter table booked_tickets enable row level security;

drop policy if exists "Users can read own booked tickets" on booked_tickets;
create policy "Users can read own booked tickets"
on booked_tickets
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert own booked tickets" on booked_tickets;
create policy "Users can insert own booked tickets"
on booked_tickets
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own booked tickets" on booked_tickets;
create policy "Users can update own booked tickets"
on booked_tickets
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create index if not exists booked_tickets_user_booked_at_idx
on booked_tickets (user_id, booked_at desc);
