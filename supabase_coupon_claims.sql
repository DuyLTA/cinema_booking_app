-- Coupon claims storage for per-user claim state.

create extension if not exists pgcrypto;

create table if not exists public.coupon_claims (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  coupon_id text not null,
  coupon_code text not null,
  coupon_name text not null,
  claimed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, coupon_id)
);

alter table public.coupon_claims enable row level security;

drop policy if exists "Users can read own coupon claims" on public.coupon_claims;
drop policy if exists "Users can insert own coupon claims" on public.coupon_claims;
drop policy if exists "Users can update own coupon claims" on public.coupon_claims;

create policy "Users can read own coupon claims"
on public.coupon_claims
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert own coupon claims"
on public.coupon_claims
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update own coupon claims"
on public.coupon_claims
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

grant select, insert, update, delete on public.coupon_claims to authenticated;

insert into public.coupons (
  id,
  code,
  name,
  description,
  discount_type,
  discount_value,
  min_order_amount,
  max_discount_amount,
  start_date,
  end_date,
  is_active
)
select
  gen_random_uuid(),
  seed.code,
  seed.name,
  seed.description,
  seed.discount_type::discount_type,
  seed.discount_value,
  seed.min_order_amount,
  seed.max_discount_amount,
  seed.start_date,
  seed.end_date,
  true
from (
  values
    (
      'WELCOME10',
      'Welcome Offer',
      '10% off for new users.',
      'percent',
      10,
      0,
      50000,
      now() - interval '1 day',
      now() + interval '30 days'
    ),
    (
      'WEEKEND20',
      'Weekend Saver',
      '20% off on weekend bookings.',
      'percent',
      20,
      100000,
      60000,
      now() - interval '1 day',
      now() + interval '30 days'
    ),
    (
      'SNACK50',
      'Snack Saver',
      '50000 VND off for food orders.',
      'fixed',
      50000,
      120000,
      0,
      now() - interval '1 day',
      now() + interval '30 days'
    )
) as seed(
  code,
  name,
  description,
  discount_type,
  discount_value,
  min_order_amount,
  max_discount_amount,
  start_date,
  end_date
)
where not exists (
  select 1 from public.coupons c where c.code = seed.code
);

select id, code, name, discount_type, discount_value, min_order_amount, max_discount_amount
from public.coupons
order by created_at desc;

select *
from public.coupon_claims
order by claimed_at desc;
