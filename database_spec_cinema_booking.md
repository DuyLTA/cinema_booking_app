# Cinema Booking App — Database Specification for Supabase

## 1. Project Overview

This project is a Flutter mobile application for booking movie tickets, inspired by cinema apps such as CGV Cinemas. Users can browse movies, choose cinemas, select showtimes, choose seats, buy food and drink combos, apply coupons, make payments, receive notifications, and chat with support staff.

The backend database uses **Supabase PostgreSQL**. Supabase Auth is used for authentication. The Flutter app should use the **Supabase publishable key**, not the secret key.

---

## 2. Main Actors

| Actor | Description |
|---|---|
| Customer | The main user of the mobile app. Customers can register, log in, browse movies, choose cinema/showtime, select seats, buy food combos, apply coupons, pay, view tickets, receive notifications, and chat with support. |
| Support Staff | Internal support actor. Support staff can view customer conversations, reply to messages, check booking/ticket information, support payment or coupon issues, and mark conversations as resolved or closed. |
| System | Handles booking logic, price calculation, ticket generation, seat status update, notifications, and data synchronization. |

---

## 3. Database Design Notes

The original ERD idea is improved for a real booking system:

1. **Seat status must depend on each showtime.**  
   A physical seat like A1 can be booked for the 19:00 showtime but still available for the 21:30 showtime. Therefore, the database separates:
   - `seats`: physical seats in a room.
   - `showtime_seats`: seat status for a specific showtime.

2. **Selected seats should not be saved permanently.**  
   `selected` is only a temporary state in the Flutter app using Provider/Bloc. In the database, seat status should mainly be:
   - `available`
   - `booked`
   - `blocked`

3. **Food and beverages should connect to bookings, not directly to tickets.**  
   A booking can contain many tickets and many food items. Therefore, food items are stored through `booking_foods`.

4. **Customers should not store passwords in a custom table.**  
   Supabase Auth manages password and authentication data. The `customers` table only stores profile information and references `auth.users`.

5. **Support Staff is added as a separate actor.**  
   Chat is improved with `support_staff`, `chat_conversations`, and `chat_messages`.

---

## 4. Main Tables

### 4.1 `customers`

Stores customer profile information. The primary key references `auth.users(id)` from Supabase Auth.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key, references `auth.users(id)` |
| full_name | text | Customer full name |
| email | text | Customer email |
| phone | text | Customer phone number |
| gender | text | Customer gender, optional |
| address | text | Customer address |
| city | text | Customer city |
| membership_level | enum | `regular`, `silver`, `gold`, `vip` |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

---

### 4.2 `support_staff`

Stores support staff profiles. A support staff account also references `auth.users(id)`.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key, references `auth.users(id)` |
| full_name | text | Staff full name |
| email | text | Staff email |
| phone | text | Staff phone number |
| role | text | Default: `support` |
| is_active | boolean | Whether the staff account is active |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

---

### 4.3 `movies`

Stores movie information.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| title | text | Movie title |
| description | text | Movie description |
| poster_url | text | Poster image URL |
| banner_url | text | Banner image URL |
| trailer_url | text | Trailer URL |
| genre | text | Movie genre |
| director | text | Director name |
| language | text | Movie language |
| subtitle | text | Subtitle information |
| duration_minutes | int | Movie duration |
| age_rating | text | Age rating, for example P, T13, T16, T18 |
| release_date | date | Release date |
| status | enum | `now_showing`, `coming_soon`, `ended` |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

---

### 4.4 `cinemas`

Stores cinema information and map location.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| name | text | Cinema name |
| location | text | General location name |
| address | text | Full address |
| hotline | text | Cinema hotline |
| working_hours | text | Opening hours |
| latitude | numeric | Map latitude |
| longitude | numeric | Map longitude |
| total_screens | int | Number of screens/rooms |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

---

### 4.5 `rooms`

Stores screening rooms inside each cinema.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| cinema_id | uuid | References `cinemas(id)` |
| room_name | text | Room name, for example Room 1 |
| capacity | int | Number of seats |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

Relationship: one cinema has many rooms.

---

### 4.6 `seats`

Stores physical seats inside a room.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| room_id | uuid | References `rooms(id)` |
| seat_code | text | Seat code, for example A1, A2 |
| row_label | text | Row label, for example A, B, C |
| seat_number | int | Seat number |
| type | enum | `standard`, `vip`, `couple` |
| is_active | boolean | Whether the seat is available for use |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

Relationship: one room has many seats.

---

### 4.7 `showtimes`

Stores movie screening schedules.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| movie_id | uuid | References `movies(id)` |
| cinema_id | uuid | References `cinemas(id)` |
| room_id | uuid | References `rooms(id)` |
| start_time | timestamptz | Showtime start time |
| end_time | timestamptz | Showtime end time |
| format | text | `2D`, `3D`, `IMAX`, `4DX` |
| is_active | boolean | Whether this showtime is active |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

Relationships:
- one movie has many showtimes.
- one cinema has many showtimes.
- one room has many showtimes.

---

### 4.8 `showtime_seats`

Stores seat status for each specific showtime.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| showtime_id | uuid | References `showtimes(id)` |
| seat_id | uuid | References `seats(id)` |
| status | enum | `available`, `booked`, `blocked` |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

Relationship: one showtime has many showtime seats.

Important note: this table is used when the user opens the seat selection screen.

---

### 4.9 `ticket_prices`

Stores ticket price rules.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| showtime_id | uuid | References `showtimes(id)` |
| seat_type | enum | `standard`, `vip`, `couple` |
| age_group | text | For example adult, student, child |
| price | numeric | Ticket price |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

Price depends on showtime, seat type, and age group.

---

### 4.10 `foods`

Stores popcorn, drinks, and combo products.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| product_name | text | Food/combo name |
| category | text | Popcorn, Drink, Combo |
| description | text | Product description |
| image_url | text | Product image URL |
| price | numeric | Product price |
| is_available | boolean | Whether the item is available |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

---

### 4.11 `coupons`

Stores coupons and discount programs.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| code | text | Coupon code, unique |
| name | text | Coupon name |
| description | text | Coupon description |
| discount_type | enum | `percent` or `fixed` |
| discount_value | numeric | Percent value or fixed amount |
| min_order_amount | numeric | Minimum order amount |
| max_discount_amount | numeric | Maximum discount amount |
| start_date | timestamptz | Start date |
| end_date | timestamptz | End date |
| usage_limit | int | Usage limit |
| used_count | int | Number of used times |
| is_active | boolean | Whether the coupon is active |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

---

### 4.12 `bookings`

Stores the main booking/order information.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| customer_id | uuid | References `customers(id)` |
| coupon_id | uuid | References `coupons(id)`, nullable |
| booking_date | timestamptz | Booking date |
| total_before_discount | numeric | Total before discount |
| discount_amount | numeric | Discount amount |
| final_amount | numeric | Final amount after discount |
| booking_status | enum | `pending`, `confirmed`, `cancelled`, `refunded` |
| payment_status | enum | `unpaid`, `paid`, `failed`, `refunded` |
| note | text | Optional note |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

Relationship: one customer has many bookings.

---

### 4.13 `booking_foods`

Stores food/combo items inside a booking.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| booking_id | uuid | References `bookings(id)` |
| food_id | uuid | References `foods(id)` |
| quantity | int | Quantity |
| price_each | numeric | Price at booking time |
| line_total | numeric | Generated value: quantity × price_each |
| created_at | timestamptz | Created time |

Relationship: one booking can contain many food items.

---

### 4.14 `tickets`

Stores actual tickets. One ticket represents one selected seat in one showtime.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| booking_id | uuid | References `bookings(id)` |
| showtime_seat_id | uuid | References `showtime_seats(id)` |
| ticket_price_id | uuid | References `ticket_prices(id)` |
| ticket_code | text | Unique ticket code |
| qr_code | text | QR code text or URL |
| price | numeric | Ticket price |
| status | enum | `booked`, `used`, `cancelled` |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |

Relationship: one booking can have many tickets.

---

### 4.15 `payment_methods`

Stores available payment methods.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| method_name | text | Payment method name |
| description | text | Description |
| is_active | boolean | Whether this method is active |
| created_at | timestamptz | Created time |

Examples:
- E-wallet Demo
- Bank Transfer
- Credit/Debit Card
- Pay at Counter

---

### 4.16 `transactions`

Stores payment transaction records.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| booking_id | uuid | References `bookings(id)` |
| payment_method_id | uuid | References `payment_methods(id)` |
| transaction_code | text | Payment transaction code |
| amount | numeric | Paid amount |
| status | enum | `unpaid`, `paid`, `failed`, `refunded` |
| paid_at | timestamptz | Payment time |
| created_at | timestamptz | Created time |

---

### 4.17 `notifications`

Stores customer notifications.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| customer_id | uuid | References `customers(id)` |
| title | text | Notification title |
| message | text | Notification message |
| type | text | booking, promotion, reminder, system |
| is_read | boolean | Read/unread status |
| created_at | timestamptz | Created time |

Relationship: one customer has many notifications.

---

### 4.18 `chat_conversations`

Stores chat sessions between customers and support staff.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| customer_id | uuid | References `customers(id)` |
| support_staff_id | uuid | References `support_staff(id)`, nullable |
| subject | text | Conversation subject |
| status | enum | `open`, `assigned`, `resolved`, `closed` |
| last_message | text | Last message preview |
| last_message_at | timestamptz | Last message time |
| created_at | timestamptz | Created time |
| updated_at | timestamptz | Updated time |
| closed_at | timestamptz | Closed time |

Relationships:
- one customer can have many conversations.
- one support staff can handle many conversations.

---

### 4.19 `chat_messages`

Stores messages inside a chat conversation.

| Column | Type | Description |
|---|---|---|
| id | uuid | Primary key |
| conversation_id | uuid | References `chat_conversations(id)` |
| customer_id | uuid | References `customers(id)` |
| support_staff_id | uuid | References `support_staff(id)`, nullable |
| sender_user_id | uuid | References `auth.users(id)` |
| sender | enum | `customer` or `support` |
| message | text | Message content |
| attachment_url | text | Optional attachment URL |
| is_read | boolean | Read/unread status |
| created_at | timestamptz | Created time |

Relationship: one conversation has many messages.

---

## 5. Main Relationships

```txt
customers 1 - n bookings
customers 1 - n notifications
customers 1 - n chat_conversations
support_staff 1 - n chat_conversations
chat_conversations 1 - n chat_messages

cinemas 1 - n rooms
rooms 1 - n seats
movies 1 - n showtimes
cinemas 1 - n showtimes
rooms 1 - n showtimes
showtimes 1 - n showtime_seats
seats 1 - n showtime_seats

showtimes 1 - n ticket_prices
bookings 1 - n tickets
showtime_seats 1 - 1 active ticket
bookings 1 - n booking_foods
foods 1 - n booking_foods
coupons 1 - n bookings
bookings 1 - n transactions
payment_methods 1 - n transactions
```

---

## 6. Main App Flows and Related Tables

### 6.1 Login Flow

```txt
Supabase Auth → customers
```

- Supabase Auth handles email/password login.
- `customers` stores additional profile data.

---

### 6.2 Buy Ticket by Movie

```txt
movies → showtimes → cinemas → rooms → showtime_seats → bookings → tickets
```

Steps:
1. User chooses a movie.
2. App loads available showtimes for that movie.
3. User chooses cinema and showtime.
4. App loads `showtime_seats`.
5. User selects seats.
6. App creates booking and tickets.

---

### 6.3 Buy Ticket by Cinema

```txt
cinemas → showtimes → movies → showtime_seats → bookings → tickets
```

Steps:
1. User chooses a cinema.
2. App loads movies and showtimes for that cinema.
3. User chooses movie and showtime.
4. App loads seats.
5. User books ticket.

---

### 6.4 Food and Combo Flow

```txt
foods → booking_foods → bookings
```

- User can add popcorn, drinks, or combo before checkout.
- Selected food items are saved in `booking_foods`.

---

### 6.5 Coupon Flow

```txt
coupons → bookings
```

- User enters coupon code.
- App checks coupon validity.
- Discount is calculated and saved in booking.

---

### 6.6 Payment Flow

```txt
payment_methods → transactions → bookings
```

- User selects payment method.
- App creates a transaction.
- Booking payment status is updated.

---

### 6.7 Notification Flow

```txt
bookings → notifications → customer
```

Example notifications:
- Booking confirmed.
- Showtime reminder.
- New promotion.
- Coupon expiring soon.

---

### 6.8 Chat Support Flow

```txt
customers → chat_conversations → chat_messages ← support_staff
```

Steps:
1. Customer sends a message.
2. System creates or loads a conversation.
3. Support staff reads the conversation.
4. Support staff replies.
5. Conversation can be marked as resolved or closed.

---

## 7. Flutter Model Naming Suggestion

| Supabase Table | Flutter Model |
|---|---|
| customers | CustomerModel |
| support_staff | SupportStaffModel |
| movies | MovieModel |
| cinemas | CinemaModel |
| rooms | RoomModel |
| seats | SeatModel |
| showtimes | ShowtimeModel |
| showtime_seats | ShowtimeSeatModel |
| ticket_prices | TicketPriceModel |
| foods | FoodModel |
| coupons | CouponModel |
| bookings | BookingModel |
| booking_foods | BookingFoodModel |
| tickets | TicketModel |
| payment_methods | PaymentMethodModel |
| transactions | TransactionModel |
| notifications | AppNotificationModel |
| chat_conversations | ChatConversationModel |
| chat_messages | ChatMessageModel |

---

## 8. Flutter Provider / Bloc State Suggestion

| State | Responsibility |
|---|---|
| AuthProvider | Login, logout, current user |
| MovieProvider | Load movies, search movies, filter now showing/coming soon |
| CinemaProvider | Load cinemas, cinema details, map data |
| ShowtimeProvider | Load showtimes by movie or by cinema |
| SeatProvider | Load showtime seats, handle selected seats temporarily |
| BookingProvider | Manage booking summary, selected seats, selected foods, totals |
| FoodProvider | Load popcorn/drink/combo list |
| CouponProvider | Validate coupon and calculate discount |
| PaymentProvider | Manage payment method and transaction status |
| NotificationProvider | Load and mark notifications as read |
| ChatProvider | Manage conversations and messages |

---

## 9. Important Supabase Security Notes

1. Use **Publishable key** in Flutter.
2. Never use **Secret key** in Flutter.
3. Enable **Row Level Security (RLS)** for all tables.
4. Public read is acceptable for data such as:
   - movies
   - cinemas
   - rooms
   - seats
   - showtimes
   - showtime_seats
   - ticket_prices
   - foods
   - active coupons
   - payment methods
5. Customer private data should only be readable by the owner:
   - bookings
   - tickets
   - transactions
   - notifications
   - chat conversations
   - chat messages
6. Support staff should have separate policies for reading and replying to customer chat messages.

---

## 10. Recommended Folder Structure in Flutter

```txt
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── supabase_client.dart
├── models/
│   ├── customer_model.dart
│   ├── support_staff_model.dart
│   ├── movie_model.dart
│   ├── cinema_model.dart
│   ├── room_model.dart
│   ├── seat_model.dart
│   ├── showtime_model.dart
│   ├── showtime_seat_model.dart
│   ├── ticket_price_model.dart
│   ├── food_model.dart
│   ├── coupon_model.dart
│   ├── booking_model.dart
│   ├── booking_food_model.dart
│   ├── ticket_model.dart
│   ├── payment_method_model.dart
│   ├── transaction_model.dart
│   ├── app_notification_model.dart
│   ├── chat_conversation_model.dart
│   └── chat_message_model.dart
├── services/
│   ├── auth_service.dart
│   ├── movie_service.dart
│   ├── cinema_service.dart
│   ├── showtime_service.dart
│   ├── seat_service.dart
│   ├── booking_service.dart
│   ├── food_service.dart
│   ├── coupon_service.dart
│   ├── payment_service.dart
│   ├── notification_service.dart
│   └── chat_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── movie_provider.dart
│   ├── cinema_provider.dart
│   ├── showtime_provider.dart
│   ├── seat_provider.dart
│   ├── booking_provider.dart
│   ├── food_provider.dart
│   ├── coupon_provider.dart
│   ├── payment_provider.dart
│   ├── notification_provider.dart
│   └── chat_provider.dart
├── screens/
└── widgets/
```

---

## 11. Example Supabase Queries for Flutter

### Load now showing movies

```dart
final response = await supabase
    .from('movies')
    .select()
    .eq('status', 'now_showing')
    .order('release_date', ascending: false);
```

### Load cinemas

```dart
final response = await supabase
    .from('cinemas')
    .select()
    .order('name');
```

### Load showtimes by movie

```dart
final response = await supabase
    .from('showtimes')
    .select('*, cinemas(*), rooms(*)')
    .eq('movie_id', movieId)
    .eq('is_active', true)
    .order('start_time');
```

### Load showtimes by cinema

```dart
final response = await supabase
    .from('showtimes')
    .select('*, movies(*), rooms(*)')
    .eq('cinema_id', cinemaId)
    .eq('is_active', true)
    .order('start_time');
```

### Load seats for one showtime

```dart
final response = await supabase
    .from('showtime_seats')
    .select('*, seats(*)')
    .eq('showtime_id', showtimeId);
```

### Load food combos

```dart
final response = await supabase
    .from('foods')
    .select()
    .eq('is_available', true)
    .order('product_name');
```

### Check coupon

```dart
final response = await supabase
    .from('coupons')
    .select()
    .eq('code', couponCode)
    .eq('is_active', true)
    .maybeSingle();
```

### Load customer notifications

```dart
final userId = supabase.auth.currentUser!.id;

final response = await supabase
    .from('notifications')
    .select()
    .eq('customer_id', userId)
    .order('created_at', ascending: false);
```

### Load customer conversations

```dart
final userId = supabase.auth.currentUser!.id;

final response = await supabase
    .from('chat_conversations')
    .select()
    .eq('customer_id', userId)
    .order('updated_at', ascending: false);
```

### Load messages in one conversation

```dart
final response = await supabase
    .from('chat_messages')
    .select()
    .eq('conversation_id', conversationId)
    .order('created_at', ascending: true);
```

---

## 12. Booking Logic Summary

When the user confirms payment:

1. Create a new record in `bookings`.
2. Insert selected food items into `booking_foods`.
3. For each selected seat:
   - Check if `showtime_seats.status` is still `available`.
   - Update `showtime_seats.status` to `booked`.
   - Insert one record into `tickets`.
4. Insert a record into `transactions`.
5. Insert a confirmation notification into `notifications`.

For a real production app, this should be handled by a secure Supabase RPC function to avoid two users booking the same seat at the same time. For this student project, basic insert/update logic from Flutter is acceptable for demo.

---

## 13. Minimal Demo Data Needed

To test the app, the database should have at least:

- 2 customers
- 1 support staff
- 3 movies
- 2 cinemas
- 2 rooms for each cinema
- seats for each room
- 5 showtimes
- showtime seats generated for each showtime
- ticket prices for each showtime
- 5 food/combo items
- 2 coupons
- 3 payment methods
- sample notifications
- sample chat conversation and messages

---

## 14. Naming Rules for AI Code Generation

When generating Flutter code, use these database names exactly:

- `customers`
- `support_staff`
- `movies`
- `cinemas`
- `rooms`
- `seats`
- `showtimes`
- `showtime_seats`
- `ticket_prices`
- `foods`
- `coupons`
- `bookings`
- `booking_foods`
- `tickets`
- `payment_methods`
- `transactions`
- `notifications`
- `chat_conversations`
- `chat_messages`

Do not invent alternative table names such as `movie`, `cinema`, `ticket_cart`, or `food_cart_items`.

