# Simple Flow Specification: Login, Register, and Movie List

## Project Context

This document describes the first simple flow for the Cinema Booking App. The purpose is to help AI/code assistants understand the basic app flow before implementing more advanced features such as booking tickets, seat selection, food combo, coupon, payment, chat, and notifications.

The first implementation should focus only on:

1. User registration
2. User login
3. Authentication state checking
4. Displaying the movie list after login
5. Logging out

The app uses Flutter for the mobile frontend and Supabase for authentication and database.

---

## Main Goal

The user should be able to create an account, log in, and view a list of movies from Supabase.

Basic flow:

```text
Open App
→ Check Auth Session
→ If not logged in: Show Login Screen
→ User can go to Register Screen
→ Register account
→ Login successfully
→ Navigate to Home / Movie List Screen
→ Load movies from Supabase table `movies`
```

---

## Actors

| Actor | Description |
|---|---|
| Customer | A user who registers, logs in, and views the list of movies. |
| Supabase Auth | Handles user registration, login, logout, and session state. |
| Supabase Database | Stores movie data in the `movies` table. |
| Flutter App | Displays UI and communicates with Supabase. |

---

## Required Supabase Tables

For this simple flow, only these parts are needed:

| Table | Purpose |
|---|---|
| `auth.users` | Built-in Supabase authentication table. Stores login accounts automatically. Do not manually insert into this table. |
| `customers` | Stores extra customer profile information such as full name, email, phone, and membership level. |
| `movies` | Stores movie data displayed on the Home / Movie List screen. |

---

## Table: customers

This table stores additional user profile data after registration.

### Important Columns

| Column | Type | Description |
|---|---|---|
| `id` | uuid | Same as `auth.users.id`. Primary key. |
| `full_name` | text | Customer full name. |
| `email` | text | Customer email. |
| `phone` | text | Customer phone number. |
| `membership_level` | enum/text | Customer membership level. Default can be `regular`. |
| `created_at` | timestamptz | Account creation time. |
| `updated_at` | timestamptz | Last update time. |

### Relationship

```text
auth.users.id = customers.id
```

When a user registers successfully with Supabase Auth, the app should create a row in `customers` using the returned user id.

---

## Table: movies

This table stores the movie list shown on the home screen.

### Important Columns

| Column | Type | Description |
|---|---|---|
| `id` | uuid | Movie id. |
| `title` | text | Movie title. |
| `description` | text | Movie description. |
| `poster_url` | text | Poster image URL. |
| `banner_url` | text | Banner image URL. |
| `trailer_url` | text | Trailer URL. |
| `genre` | text | Movie genre. |
| `director` | text | Movie director. |
| `language` | text | Movie language. |
| `subtitle` | text | Subtitle information. |
| `duration_minutes` | int | Movie duration in minutes. |
| `age_rating` | text | Age rating, for example `P`, `T13`, `T16`, `T18`. |
| `release_date` | date | Movie release date. |
| `status` | enum/text | Movie status, for example `now_showing`, `coming_soon`, `ended`. |
| `created_at` | timestamptz | Created time. |
| `updated_at` | timestamptz | Last update time. |

---

## Screen 1: Splash / Auth Check Screen

### Purpose

Check whether the user is already logged in.

### Logic

When the app starts:

1. Initialize Supabase.
2. Check current auth session.
3. If session exists, navigate to `HomeScreen`.
4. If no session exists, navigate to `LoginScreen`.

### Pseudocode

```dart
final session = Supabase.instance.client.auth.currentSession;

if (session != null) {
  navigateToHome();
} else {
  navigateToLogin();
}
```

### UI

Can be very simple:

- App logo or icon
- App name: `CineBooking`
- Loading indicator

---

## Screen 2: Register Screen

### Purpose

Allow a new customer to create an account.

### Input Fields

| Field | Required | Validation |
|---|---|---|
| Full name | Yes | Cannot be empty. |
| Email | Yes | Must be valid email format. |
| Phone | Optional/Yes | Should be valid phone format if used. |
| Password | Yes | At least 6 characters. |
| Confirm password | Yes | Must match password. |

### Button

- `Register`
- `Already have an account? Login`

### Processing Flow

```text
User enters full name, email, phone, password
→ App validates input
→ App calls Supabase Auth signUp()
→ If sign up success, create a row in `customers`
→ Navigate to Login Screen or Home Screen
→ If failed, show error message
```

### Supabase Auth Example

```dart
final response = await supabase.auth.signUp(
  email: email,
  password: password,
);
```

### Insert Customer Profile Example

```dart
final user = response.user;

if (user != null) {
  await supabase.from('customers').insert({
    'id': user.id,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'membership_level': 'regular',
  });
}
```

### Output

| Case | Result |
|---|---|
| Register success | Account is created and customer profile is saved. |
| Invalid input | Show validation error. |
| Email already exists | Show Supabase/Auth error message. |
| Network error | Show connection error message. |

---

## Screen 3: Login Screen

### Purpose

Allow an existing customer to log in.

### Input Fields

| Field | Required | Validation |
|---|---|---|
| Email | Yes | Must be valid email format. |
| Password | Yes | Cannot be empty. |

### Button

- `Login`
- `Create new account`
- Optional: `Forgot password`

### Processing Flow

```text
User enters email and password
→ App validates input
→ App calls Supabase Auth signInWithPassword()
→ If login success, navigate to Home / Movie List Screen
→ If login failed, show error message
```

### Supabase Login Example

```dart
await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);
```

### Output

| Case | Result |
|---|---|
| Login success | Navigate to Home / Movie List Screen. |
| Wrong email/password | Show error message. |
| Empty fields | Show validation message. |
| Network error | Show connection error message. |

---

## Screen 4: Home / Movie List Screen

### Purpose

Display movies from the Supabase `movies` table after the user logs in.

### UI Components

- App bar with app name: `CineBooking`
- Greeting text, for example `Hello, Movie Lover`
- Search bar
- Movie status tabs:
  - `Now Showing`
  - `Coming Soon`
- Movie list or grid
- Movie card
- Logout button

### Movie Card Should Display

| Data | Source Column |
|---|---|
| Poster | `poster_url` |
| Movie title | `title` |
| Genre | `genre` |
| Duration | `duration_minutes` |
| Age rating | `age_rating` |
| Status | `status` |

### Processing Flow

```text
HomeScreen opens
→ App queries movies from Supabase
→ Show loading indicator while fetching
→ If data exists, display movie cards
→ If no movies exist, show empty state
→ If error occurs, show error message
```

### Supabase Query Example

```dart
final data = await supabase
    .from('movies')
    .select()
    .eq('status', 'now_showing')
    .order('release_date', ascending: false);
```

### Search Logic

Search can be handled locally first after loading all movies.

```text
User types keyword
→ Filter movie list by title or genre
→ Display filtered results
```

Basic filter logic:

```dart
movies.where((movie) {
  return movie.title.toLowerCase().contains(keyword.toLowerCase()) ||
         movie.genre.toLowerCase().contains(keyword.toLowerCase());
}).toList();
```

---

## Logout Flow

### Purpose

Allow the user to sign out.

### Processing Flow

```text
User taps Logout
→ App calls Supabase signOut()
→ Clear local auth state if needed
→ Navigate back to Login Screen
```

### Supabase Logout Example

```dart
await supabase.auth.signOut();
```

---

## State Management Suggestion

Use Provider for this basic flow.

### Suggested Providers

| Provider | Responsibility |
|---|---|
| `AuthProvider` | Register, login, logout, check session, store current user. |
| `MovieProvider` | Fetch movies, manage loading/error state, search/filter movies. |

---

## AuthProvider Responsibilities

`AuthProvider` should manage:

- `isLoggedIn`
- `currentUser`
- `isLoading`
- `errorMessage`
- `register()`
- `login()`
- `logout()`
- `checkSession()`

### Suggested State

```dart
bool isLoading = false;
String? errorMessage;
User? currentUser;
```

---

## MovieProvider Responsibilities

`MovieProvider` should manage:

- movie list
- filtered movie list
- loading state
- error message
- search keyword
- selected status tab

### Suggested State

```dart
bool isLoading = false;
String? errorMessage;
List<Movie> movies = [];
List<Movie> filteredMovies = [];
String selectedStatus = 'now_showing';
```

---

## Suggested Flutter Files

Create these files first:

```text
lib/
├── main.dart
├── models/
│   ├── customer_model.dart
│   └── movie_model.dart
├── services/
│   ├── supabase_service.dart
│   ├── auth_service.dart
│   └── movie_service.dart
├── providers/
│   ├── auth_provider.dart
│   └── movie_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   └── home_screen.dart
└── utils/
    └── app_colors.dart
```

---

## Suggested Navigation

```text
SplashScreen
├── if logged in → HomeScreen
└── if not logged in → LoginScreen

LoginScreen
├── login success → HomeScreen
└── tap register → RegisterScreen

RegisterScreen
├── register success → LoginScreen or HomeScreen
└── tap login → LoginScreen

HomeScreen
└── logout → LoginScreen
```

---

## Error Handling Requirements

The app should display clear errors for:

| Situation | Message Example |
|---|---|
| Empty email | `Please enter your email.` |
| Invalid email | `Please enter a valid email.` |
| Empty password | `Please enter your password.` |
| Password too short | `Password must be at least 6 characters.` |
| Password confirmation mismatch | `Passwords do not match.` |
| Login failed | `Invalid email or password.` |
| Register failed | Show Supabase error message. |
| Movie load failed | `Cannot load movies. Please try again.` |
| Empty movie list | `No movies available.` |

---

## Minimum Demo Flow

For the first demo, the app only needs to prove this flow:

```text
Open App
→ Register new account
→ Login
→ View movie list from Supabase
→ Search movie
→ Logout
```

---

## Important Notes for AI Code Generation

When generating code for this flow:

1. Use Supabase Auth for registration and login.
2. Do not manually store passwords in the `customers` table.
3. After successful sign up, insert user profile into `customers`.
4. Load movies from the `movies` table, not from dummy data.
5. Use Provider for state management.
6. Keep UI basic but clean.
7. Use dark cinema theme with red/gold accent colors.
8. Do not implement booking, seats, foods, coupons, payment, or chat in this first flow.
9. This flow is only for authentication and movie list display.

---

## Supabase Tables Used in This Simple Flow

```text
auth.users
customers
movies
```

Do not use these tables yet in this simple flow:

```text
cinemas
rooms
seats
showtimes
showtime_seats
ticket_prices
foods
coupons
bookings
booking_foods
tickets
transactions
notifications
support_staff
chat_conversations
chat_messages
```

These tables will be used in later flows.
