# Cinema Booking App – Database Specification

## 1. Overview

Project: **Cinema Ticket Booking App**  
Database: **Supabase PostgreSQL**  
Main flow: **Register/Login → Browse Movies → Choose Cinema/Showtime → Select Seats → Add Food/Coupon → Checkout → Ticket QR → Chat Support**

---

## 2. Main Tables

### `customers`

Stores customer profile after Supabase Auth registration.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK, references `auth.users(id)` |
| `full_name` | text | Customer name |
| `email` | text | Customer email |
| `phone` | text | Phone number |
| `gender` | text | Optional |
| `address` | text | Optional |
| `city` | text | Optional |
| `membership_level` | enum/text | regular, silver, gold, vip |
| `created_at` | timestamptz | Created time |
| `updated_at` | timestamptz | Updated time |

---

### `support_staff`

Stores staff account profile.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK, references `auth.users(id)` |
| `full_name` | text | Staff name |
| `email` | text | Staff email |
| `phone` | text | Optional |
| `role` | text | Example: support |
| `is_active` | boolean | Staff status |
| `created_at` | timestamptz | Created time |
| `updated_at` | timestamptz | Updated time |

---

### `movies`

Stores movie information.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `title` | text | Movie title |
| `description` | text | Movie description |
| `poster_url` | text | Poster image |
| `banner_url` | text | Banner image |
| `trailer_url` | text | Trailer link |
| `genre` | text | Movie genres |
| `director` | text | Director name |
| `language` | text | Movie language |
| `subtitle` | text | Subtitle info |
| `duration_minutes` | int | Duration |
| `age_rating` | text | P, T13, T16, T18 |
| `release_date` | date | Release date |
| `status` | enum/text | now_showing, coming_soon, ended |
| `cast_members` | jsonb | List of actors |
| `crew_members` | jsonb | List of crew |
| `created_at` | timestamptz | Created time |

Example `cast_members`:

```json
[
  {
    "name": "Actor Name",
    "role": "Character Name",
    "image_url": "https://..."
  }
]
```

Example `crew_members`:

```json
[
  {
    "name": "Crew Name",
    "job": "Director",
    "image_url": "https://..."
  }
]
```

---

### `cinemas`

Stores cinema branches.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `name` | text | Cinema name |
| `location` | text | Area/district |
| `address` | text | Full address |
| `hotline` | text | Phone |
| `working_hours` | text | Opening time |
| `latitude` | numeric | Map latitude |
| `longitude` | numeric | Map longitude |
| `total_screens` | int | Number of rooms |
| `created_at` | timestamptz | Created time |

---

### `rooms`

Stores cinema rooms.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `cinema_id` | uuid | FK → `cinemas.id` |
| `room_name` | text | Example: Room 1 |
| `capacity` | int | Total seats |
| `created_at` | timestamptz | Created time |

---

### `seats`

Stores physical seats in each room.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `room_id` | uuid | FK → `rooms.id` |
| `seat_code` | text | Example: A1, A2 |
| `row_label` | text | Example: A, B, C |
| `seat_number` | int | Seat number |
| `type` | enum/text | standard, vip, couple |
| `is_active` | boolean | Seat usable or not |

Important: this table stores fixed physical seats only. Seat availability for each showtime is stored in `showtime_seats`.

---

### `showtimes`

Stores movie screening sessions.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `movie_id` | uuid | FK → `movies.id` |
| `cinema_id` | uuid | FK → `cinemas.id` |
| `room_id` | uuid | FK → `rooms.id` |
| `start_time` | timestamptz | Start time |
| `end_time` | timestamptz | End time |
| `format` | text | 2D, 3D, IMAX |
| `is_active` | boolean | Showtime status |

---

### `showtime_seats`

Stores seat status for each showtime.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `showtime_id` | uuid | FK → `showtimes.id` |
| `seat_id` | uuid | FK → `seats.id` |
| `status` | enum/text | available, booked, blocked |

Important: do not store `selected` here. `selected` is only temporary in Flutter state before checkout.

---

### `ticket_prices`

Stores ticket price by showtime and seat type.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `showtime_id` | uuid | FK → `showtimes.id` |
| `seat_type` | enum/text | standard, vip, couple |
| `age_group` | text | adult, child, student |
| `price` | numeric | Ticket price |

---

### `foods`

Stores popcorn, drinks, and combos.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `product_name` | text | Food/combo name |
| `category` | text | Popcorn, Drink, Combo |
| `description` | text | Description |
| `image_url` | text | Image |
| `price` | numeric | Price |
| `is_available` | boolean | Availability |

---

### `coupons`

Stores discount codes.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `code` | text | Unique coupon code |
| `name` | text | Coupon name |
| `description` | text | Description |
| `discount_type` | enum/text | percent, fixed |
| `discount_value` | numeric | Discount value |
| `min_order_amount` | numeric | Minimum order |
| `max_discount_amount` | numeric | Max discount for percent |
| `start_date` | timestamptz | Start date |
| `end_date` | timestamptz | End date |
| `usage_limit` | int | Max usage |
| `used_count` | int | Used count |
| `is_active` | boolean | Coupon status |

---

### `payment_methods`

Stores available payment methods.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `method_name` | text | E-wallet, Bank Card, Pay at Counter |
| `description` | text | Optional |
| `is_active` | boolean | Method status |

---

### `bookings`

Stores one complete booking order.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `customer_id` | uuid | FK → `customers.id` |
| `coupon_id` | uuid | FK → `coupons.id`, nullable |
| `booking_date` | timestamptz | Booking time |
| `total_before_discount` | numeric | Original total |
| `discount_amount` | numeric | Discount amount |
| `final_amount` | numeric | Final amount |
| `booking_status` | enum/text | pending, confirmed, cancelled, refunded |
| `payment_status` | enum/text | unpaid, paid, failed, refunded |
| `note` | text | Optional |

---

### `booking_foods`

Stores food items in each booking.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `booking_id` | uuid | FK → `bookings.id` |
| `food_id` | uuid | FK → `foods.id` |
| `quantity` | int | Quantity |
| `price_each` | numeric | Price at booking time |
| `line_total` | numeric | quantity × price_each |

---

### `tickets`

Stores real tickets after booking is successful.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `booking_id` | uuid | FK → `bookings.id` |
| `showtime_seat_id` | uuid | FK → `showtime_seats.id` |
| `ticket_price_id` | uuid | FK → `ticket_prices.id` |
| `ticket_code` | text | Unique ticket code |
| `qr_code` | text | QR content/string |
| `price` | numeric | Ticket price |
| `status` | enum/text | booked, used, cancelled |
| `created_at` | timestamptz | Created time |

Important: **1 selected seat = 1 ticket**. If a user selects A1 and A2, create 1 booking and 2 tickets.

---

### `transactions`

Stores payment transaction data.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `booking_id` | uuid | FK → `bookings.id` |
| `payment_method_id` | uuid | FK → `payment_methods.id` |
| `transaction_code` | text | Payment code |
| `amount` | numeric | Paid amount |
| `status` | enum/text | unpaid, paid, failed, refunded |
| `paid_at` | timestamptz | Paid time |

---

### `notifications`

Stores customer notifications.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `customer_id` | uuid | FK → `customers.id` |
| `title` | text | Notification title |
| `message` | text | Notification content |
| `type` | text | booking, promotion, reminder |
| `is_read` | boolean | Read status |
| `created_at` | timestamptz | Created time |

---

### `chat_conversations`

Stores support chat conversations.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `customer_id` | uuid | FK → `customers.id` |
| `support_staff_id` | uuid | FK → `support_staff.id`, nullable |
| `subject` | text | Chat subject |
| `status` | enum/text | open, assigned, resolved, closed |
| `last_message` | text | Latest message |
| `last_message_at` | timestamptz | Latest message time |
| `created_at` | timestamptz | Created time |
| `closed_at` | timestamptz | Closed time |

---

### `chat_messages`

Stores messages in a conversation.

| Field | Type | Note |
|---|---|---|
| `id` | uuid | PK |
| `conversation_id` | uuid | FK → `chat_conversations.id` |
| `customer_id` | uuid | FK → `customers.id` |
| `support_staff_id` | uuid | FK → `support_staff.id`, nullable |
| `sender` | enum/text | customer, support |
| `sender_user_id` | uuid | FK → `auth.users.id` |
| `message` | text | Message content |
| `attachment_url` | text | Optional |
| `is_read` | boolean | Read status |
| `created_at` | timestamptz | Created time |

---

## 3. Relationships

```text
auth.users 1 ── 1 customers
auth.users 1 ── 1 support_staff

cinemas 1 ── n rooms
rooms 1 ── n seats

movies 1 ── n showtimes
cinemas 1 ── n showtimes
rooms 1 ── n showtimes

showtimes 1 ── n showtime_seats
seats 1 ── n showtime_seats

showtimes 1 ── n ticket_prices

customers 1 ── n bookings
coupons 1 ── n bookings

bookings 1 ── n tickets
showtime_seats 1 ── 1 tickets
ticket_prices 1 ── n tickets

bookings 1 ── n booking_foods
foods 1 ── n booking_foods

bookings 1 ── n transactions
payment_methods 1 ── n transactions

customers 1 ── n notifications

customers 1 ── n chat_conversations
support_staff 1 ── n chat_conversations
chat_conversations 1 ── n chat_messages
```

---

## 4. Main Flows

### Register/Login

```text
User registers with Supabase Auth
→ Supabase creates auth.users record
→ App creates customer profile in customers table
→ User logs in
→ App loads movie list
```

### Booking Ticket

```text
Select movie
→ Select cinema/showtime
→ Load showtime_seats
→ Select available seats
→ Calculate ticket price
→ Add foods
→ Apply coupon
→ Create booking
→ Create tickets
→ Update showtime_seats to booked
→ Create transaction
→ Show ticket QR
```

### Chat Support

```text
Customer opens chat
→ Create chat_conversation
→ Customer sends chat_message
→ Support staff replies
→ Conversation status becomes resolved/closed
```

---

## 5. Important Notes

1. Supabase Auth stores login accounts in `auth.users`.
2. `customers.id` and `support_staff.id` must match `auth.users.id`.
3. Do not insert random UUID into `customers` or `support_staff` unless that UUID exists in `auth.users`.
4. Use `showtime_seats.status` for real seat availability.
5. Do not store selected seats in database before checkout; selected seats should stay in Flutter state.
6. One booking can contain many tickets.
7. One ticket represents one seat in one showtime.
8. `cast_members` and `crew_members` use `jsonb` for movie detail display.
9. RLS must allow users to insert/read/update their own profile.
10. Use Publishable/Anon key in Flutter. Never use Secret key in Flutter.
11. For testing register, disable email confirmation or login again before inserting customer profile.
12. Test simple flow first: Auth → Movies → Showtimes → Seats → Booking → Tickets.


