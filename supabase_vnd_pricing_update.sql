-- Update demo pricing to VND.
-- Run this in Supabase SQL Editor.

do $$
begin
  if to_regclass('public.ticket_prices') is not null then
    update ticket_prices
    set price = case
      when seat_type::text = 'vip' then 80000
      when seat_type::text = 'couple' then 130000
      else 65000
    end
    where seat_type::text in ('standard', 'vip', 'couple');
  end if;

  if to_regclass('public.foods') is not null then
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
  end if;
end $$;

select seat_type, age_group, price
from ticket_prices
where seat_type::text in ('standard', 'vip', 'couple')
order by seat_type::text, age_group
limit 20;

select product_name, category, price
from foods
order by category, product_name;
