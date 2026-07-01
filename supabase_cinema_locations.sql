-- Add cinema coordinates for distance sorting and map previews.
-- Run this in Supabase SQL Editor. The script is safe to run multiple times.
-- Replace these coordinates with the exact coordinates of your real cinemas
-- if your cinema names/addresses differ from the demo data.

alter table public.cinemas
add column if not exists latitude double precision,
add column if not exists longitude double precision;

update public.cinemas
set
  latitude = case
    when lower(name) like '%landmark%' then 10.7950
    when lower(name) like '%vivocity%' or lower(name) like '%vivo%' then 10.7308
    when lower(name) like '%da nang%' or lower(name) like '%riverside%' then 16.0614
    when lower(name) like '%ha noi%' or lower(name) like '%hanoi%' then 21.0278
    else latitude
  end,
  longitude = case
    when lower(name) like '%landmark%' then 106.7218
    when lower(name) like '%vivocity%' or lower(name) like '%vivo%' then 106.7035
    when lower(name) like '%da nang%' or lower(name) like '%riverside%' then 108.2230
    when lower(name) like '%ha noi%' or lower(name) like '%hanoi%' then 105.8342
    else longitude
  end
where latitude is null
  or longitude is null;

select id, name, location, address, latitude, longitude
from public.cinemas
order by name;
