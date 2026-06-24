-- Booking flow seed/fix for Session Selection + Seat Selection.
-- Run this in Supabase SQL Editor.
--
-- What this script does:
-- 1. Adds sample cinemas with non-empty location/region.
-- 2. Ensures every seeded cinema has Room 1 and a basic seat map.
-- 3. Adds active showtimes for all now_showing movies for today + next 3 days.
-- 4. Adds showtime_seats and ticket_prices needed by the Flutter booking flow.

create extension if not exists pgcrypto;

do $$
declare
  cinema_rec record;
  movie_rec record;
  v_room_id uuid;
  v_showtime_id uuid;
  v_seat_id uuid;
  v_row_label text;
  v_seat_number int;
  v_seat_type seat_type;
  v_day_offset int;
  v_show_time time;
  v_start_at timestamptz;
  v_end_at timestamptz;
begin
  insert into cinemas (
    id,
    name,
    location,
    address,
    hotline,
    working_hours,
    total_screens,
    created_at
  )
  select
    gen_random_uuid(),
    seed.name,
    seed.location,
    seed.address,
    seed.hotline,
    seed.working_hours,
    seed.total_screens,
    now()
  from (
    values
      (
        'CineBooking Landmark',
        'District 1',
        '72 Le Loi, District 1, Ho Chi Minh City',
        '1900 1001',
        '08:00 - 23:30',
        4
      ),
      (
        'CineBooking Vivocity',
        'District 7',
        '1058 Nguyen Van Linh, District 7, Ho Chi Minh City',
        '1900 1002',
        '08:00 - 23:30',
        5
      ),
      (
        'CineBooking Mega Mall',
        'District 2',
        '161 Hanoi Highway, District 2, Ho Chi Minh City',
        '1900 1003',
        '08:00 - 23:30',
        5
      ),
      (
        'Vintage Cinema Plaza',
        'District 3',
        '126 Cach Mang Thang 8, District 3, Ho Chi Minh City',
        '1900 1004',
        '08:00 - 23:30',
        3
      ),
      (
        'Marquee Art House',
        'District 7',
        '88 Nguyen Thi Thap, District 7, Ho Chi Minh City',
        '1900 1005',
        '08:00 - 23:30',
        3
      ),
      (
        'CineBooking Ha Noi Center',
        'Ha Noi',
        '54 Lieu Giai, Ba Dinh, Ha Noi',
        '1900 1006',
        '08:00 - 23:30',
        4
      ),
      (
        'CineBooking Da Nang Riverside',
        'Da Nang',
        '2 Bach Dang, Hai Chau, Da Nang',
        '1900 1007',
        '08:00 - 23:30',
        4
      )
  ) as seed(name, location, address, hotline, working_hours, total_screens)
  where not exists (
    select 1
    from cinemas c
    where lower(c.name) = lower(seed.name)
  );

  update cinemas
  set
    location = case
      when lower(name) like '%vivocity%' then 'District 7'
      when lower(name) like '%landmark%' then 'District 1'
      when lower(name) like '%mega mall%' then 'District 2'
      when lower(name) like '%vintage%' then 'District 3'
      when lower(name) like '%art house%' then 'District 7'
      when lower(name) like '%ha noi%' then 'Ha Noi'
      when lower(name) like '%da nang%' then 'Da Nang'
      else coalesce(nullif(location, ''), 'Ho Chi Minh City')
    end,
    address = coalesce(nullif(address, ''), 'Ho Chi Minh City')
  where location is null
    or btrim(location) = ''
    or lower(name) like any (array[
      '%vivocity%',
      '%landmark%',
      '%mega mall%',
      '%vintage%',
      '%art house%',
      '%ha noi%',
      '%da nang%'
    ]);

  for cinema_rec in
    select id, name
    from cinemas
    where lower(name) in (
      'cinebooking landmark',
      'cinebooking vivocity',
      'cinebooking mega mall',
      'vintage cinema plaza',
      'marquee art house',
      'cinebooking ha noi center',
      'cinebooking da nang riverside'
    )
  loop
    select r.id
    into v_room_id
    from rooms r
    where r.cinema_id = cinema_rec.id
      and lower(r.room_name) = 'room 1'
    limit 1;

    if v_room_id is null then
      insert into rooms (id, cinema_id, room_name, capacity, created_at)
      values (gen_random_uuid(), cinema_rec.id, 'Room 1', 80, now())
      returning id into v_room_id;
    end if;

    foreach v_row_label in array array['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
    loop
      for v_seat_number in 1..10 loop
        v_seat_type := case
          when v_row_label in ('F', 'G') then 'vip'::seat_type
          when v_row_label = 'H' and v_seat_number in (9, 10) then 'couple'::seat_type
          else 'standard'::seat_type
        end;

        if not exists (
          select 1
          from seats s
          where s.room_id = v_room_id
            and s.seat_code = v_row_label || v_seat_number::text
        ) then
          insert into seats (
            id,
            room_id,
            seat_code,
            row_label,
            seat_number,
            type,
            is_active
          )
          values (
            gen_random_uuid(),
            v_room_id,
            v_row_label || v_seat_number::text,
            v_row_label,
            v_seat_number,
            v_seat_type,
            true
          );
        end if;
      end loop;
    end loop;

    for movie_rec in
      select id, duration_minutes
      from movies
      where status = 'now_showing'
    loop
      for v_day_offset in 0..3 loop
        foreach v_show_time in array array[
          time '10:00',
          time '13:30',
          time '16:20',
          time '19:10',
          time '21:45'
        ]
        loop
          v_start_at := (current_date + v_day_offset + v_show_time) at time zone 'Asia/Bangkok';
          v_end_at := v_start_at + make_interval(
            mins => coalesce(movie_rec.duration_minutes, 120)
          );

          select st.id
          into v_showtime_id
          from showtimes st
          where st.movie_id = movie_rec.id
            and st.cinema_id = cinema_rec.id
            and st.room_id = v_room_id
            and st.start_time = v_start_at
          limit 1;

          if v_showtime_id is null then
            insert into showtimes (
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

          insert into ticket_prices (
            id,
            showtime_id,
            seat_type,
            age_group,
            price
          )
          select gen_random_uuid(), v_showtime_id, price_seed.seat_type::seat_type, 'adult', price_seed.price
          from (
            values
              ('standard', 65000),
              ('vip', 80000),
              ('couple', 130000)
          ) as price_seed(seat_type, price)
          where not exists (
            select 1
            from ticket_prices tp
            where tp.showtime_id = v_showtime_id
              and tp.seat_type = price_seed.seat_type::seat_type
              and tp.age_group = 'adult'
          );

          for v_seat_id in
            select s.id
            from seats s
            where s.room_id = v_room_id
          loop
            if not exists (
              select 1
              from showtime_seats ss
              where ss.showtime_id = v_showtime_id
                and ss.seat_id = v_seat_id
            ) then
              insert into showtime_seats (
                id,
                showtime_id,
                seat_id,
                status
              )
              values (
                gen_random_uuid(),
                v_showtime_id,
                v_seat_id,
                'available'
              );
            end if;
          end loop;
        end loop;
      end loop;
    end loop;
  end loop;
end $$;

update ticket_prices
set price = case
  when seat_type::text = 'vip' then 80000
  when seat_type::text = 'couple' then 130000
  else 65000
end
where seat_type::text in ('standard', 'vip', 'couple');

-- Quick checks after running:
select name, location, address
from cinemas
order by name;

select
  m.title,
  c.name as cinema_name,
  c.location,
  st.start_time at time zone 'Asia/Bangkok' as local_start_time,
  st.format
from showtimes st
join movies m on m.id = st.movie_id
join cinemas c on c.id = st.cinema_id
where m.status = 'now_showing'
  and st.start_time >= now() - interval '1 hour'
order by st.start_time, c.name, m.title
limit 50;
