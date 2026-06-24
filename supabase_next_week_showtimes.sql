-- Seed complete booking sessions for the next calendar week.
-- Run this file in Supabase SQL Editor.
-- The script is idempotent: existing showtimes, prices, and seats are skipped.

create extension if not exists pgcrypto;

do $$
declare
  cinema_rec record;
  movie_rec record;
  v_room_id uuid;
  v_showtime_id uuid;
  v_seat_id uuid;
  v_week_start date;
  v_day_offset integer;
  v_show_time time;
  v_start_at timestamptz;
  v_end_at timestamptz;
begin
  -- Monday of the following calendar week in the app timezone.
  v_week_start := (
    date_trunc('week', now() at time zone 'Asia/Bangkok')
    + interval '1 week'
  )::date;

  for cinema_rec in
    select c.id, c.name
    from public.cinemas c
    where exists (
      select 1
      from public.rooms r
      where r.cinema_id = c.id
    )
  loop
    -- Keep the demo flow predictable by using the first room of each cinema.
    select r.id
    into v_room_id
    from public.rooms r
    where r.cinema_id = cinema_rec.id
    order by r.created_at nulls last, r.id
    limit 1;

    for movie_rec in
      select m.id, coalesce(m.duration_minutes, 120) as duration_minutes
      from public.movies m
      where m.status::text = 'now_showing'
    loop
      for v_day_offset in 0..6 loop
        foreach v_show_time in array array[
          time '10:00',
          time '13:30',
          time '16:20',
          time '19:10',
          time '21:45'
        ]
        loop
          v_start_at := (
            v_week_start + v_day_offset + v_show_time
          ) at time zone 'Asia/Bangkok';
          v_end_at := v_start_at + make_interval(
            mins => movie_rec.duration_minutes
          );

          select st.id
          into v_showtime_id
          from public.showtimes st
          where st.movie_id = movie_rec.id
            and st.cinema_id = cinema_rec.id
            and st.room_id = v_room_id
            and st.start_time = v_start_at
          limit 1;

          if v_showtime_id is null then
            insert into public.showtimes (
              id,
              movie_id,
              cinema_id,
              room_id,
              start_time,
              end_time,
              format,
              is_active
            )
            values (
              gen_random_uuid(),
              movie_rec.id,
              cinema_rec.id,
              v_room_id,
              v_start_at,
              v_end_at,
              case
                when v_show_time in (time '16:20', time '21:45') then 'IMAX'
                else '2D'
              end,
              true
            )
            returning id into v_showtime_id;
          end if;

          insert into public.ticket_prices (
            id,
            showtime_id,
            seat_type,
            age_group,
            price
          )
          select
            gen_random_uuid(),
            v_showtime_id,
            price_seed.seat_type::seat_type,
            'adult',
            price_seed.price
          from (
            values
              ('standard', 65000),
              ('vip', 80000),
              ('couple', 130000)
          ) as price_seed(seat_type, price)
          where not exists (
            select 1
            from public.ticket_prices tp
            where tp.showtime_id = v_showtime_id
              and tp.seat_type = price_seed.seat_type::seat_type
              and tp.age_group = 'adult'
          );

          for v_seat_id in
            select s.id
            from public.seats s
            where s.room_id = v_room_id
              and coalesce(s.is_active, true)
          loop
            insert into public.showtime_seats (
              id,
              showtime_id,
              seat_id,
              status
            )
            select
              gen_random_uuid(),
              v_showtime_id,
              v_seat_id,
              'available'
            where not exists (
              select 1
              from public.showtime_seats ss
              where ss.showtime_id = v_showtime_id
                and ss.seat_id = v_seat_id
            );
          end loop;
        end loop;
      end loop;
    end loop;
  end loop;
end $$;

-- Verify the generated sessions in local app time.
select
  m.title,
  c.name as cinema_name,
  st.start_time at time zone 'Asia/Bangkok' as local_start_time,
  st.format,
  count(ss.id) as seat_count
from public.showtimes st
join public.movies m on m.id = st.movie_id
join public.cinemas c on c.id = st.cinema_id
left join public.showtime_seats ss on ss.showtime_id = st.id
where st.start_time >= (
    date_trunc('week', now() at time zone 'Asia/Bangkok') + interval '1 week'
  ) at time zone 'Asia/Bangkok'
  and st.start_time < (
    date_trunc('week', now() at time zone 'Asia/Bangkok') + interval '2 weeks'
  ) at time zone 'Asia/Bangkok'
group by m.title, c.name, st.start_time, st.format
order by st.start_time, c.name, m.title;
