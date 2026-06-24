-- Demo data for Food & Beverage screen.
-- Run this in Supabase SQL Editor after your base schema exists.

create extension if not exists pgcrypto;

create table if not exists foods (
  id uuid primary key default gen_random_uuid(),
  product_name text not null,
  category text not null,
  description text,
  image_url text,
  price numeric not null default 0,
  is_available boolean not null default true,
  created_at timestamptz not null default now()
);

insert into foods (
  id,
  product_name,
  category,
  description,
  image_url,
  price,
  is_available
)
select
  gen_random_uuid(),
  seed.product_name,
  seed.category,
  seed.description,
  seed.image_url,
  seed.price,
  true
from (
  values
    (
      'Premiere Duo',
      'Combos',
      'Large Popcorn, 2x Large Sodas, Choice of Candy',
      'https://images.unsplash.com/photo-1585647347483-22b66260dfff?auto=format&fit=crop&w=800&q=80',
      185000
    ),
    (
      'Director''s Cut',
      'Combos',
      'Gourmet Nachos, Large Soda, Ice Cream Pint',
      'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?auto=format&fit=crop&w=800&q=80',
      145000
    ),
    (
      'Solo Show',
      'Beverages',
      'Medium Popcorn, Medium Soda',
      'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=800&q=80',
      95000
    ),
    (
      'Sweet Scene',
      'Snacks',
      'Choice of 3 Artisanal Candies',
      'https://images.unsplash.com/photo-1548907040-4baa42d10919?auto=format&fit=crop&w=800&q=80',
      75000
    ),
    (
      'Golden Popcorn',
      'Snacks',
      'Classic salted popcorn with butter glaze',
      'https://images.unsplash.com/photo-1578849278619-e73505e9610f?auto=format&fit=crop&w=800&q=80',
      65000
    ),
    (
      'Sparkling Noir Soda',
      'Beverages',
      'Large sparkling cola served chilled',
      'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=800&q=80',
      45000
    )
) as seed(product_name, category, description, image_url, price)
where not exists (
  select 1
  from foods f
  where lower(f.product_name) = lower(seed.product_name)
);

update foods
set price = case lower(product_name)
  when 'premiere duo' then 185000
  when 'director''s cut' then 145000
  when 'solo show' then 95000
  when 'sweet scene' then 75000
  when 'golden popcorn' then 65000
  when 'sparkling noir soda' then 45000
  else price
end
where lower(product_name) in (
  'premiere duo',
  'director''s cut',
  'solo show',
  'sweet scene',
  'golden popcorn',
  'sparkling noir soda'
);

select product_name, category, price, is_available
from foods
order by category, product_name;
