-- Run this in Supabase SQL Editor if seat status is not being updated
-- after a successful booking.

alter table if exists public.showtime_seats enable row level security;

grant usage on schema public to authenticated;
grant select, update on public.showtime_seats to authenticated;

drop policy if exists "Authenticated users can read showtime seats"
on public.showtime_seats;

drop policy if exists "Authenticated users can update booked seats"
on public.showtime_seats;

do $$
begin
  create policy "Authenticated users can read showtime seats"
  on public.showtime_seats
  for select
  to authenticated
  using (true);

  create policy "Authenticated users can update booked seats"
  on public.showtime_seats
  for update
  to authenticated
  using (true)
  with check (status in ('available', 'booked', 'blocked'));
end $$;

select policyname, cmd, roles
from pg_policies
where schemaname = 'public'
  and tablename = 'showtime_seats'
order by policyname;

select grantee, privilege_type
from information_schema.role_table_grants
where table_schema = 'public'
  and table_name = 'showtime_seats'
  and grantee = 'authenticated'
order by privilege_type;
