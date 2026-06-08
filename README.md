# Cinema Booking App

A Flutter mobile application for booking movie tickets, inspired by cinema apps such as CGV Cinemas. Users can browse movies, choose cinemas, select showtimes, choose seats, buy food and drink combos, apply coupons, make payments, receive notifications, and chat with support staff.

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **State Management**: Provider

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Supabase account

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/cinema_booking_app.git
cd cinema_booking_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_publishable_key
```

Get your Supabase credentials from your Supabase project settings.

### 4. Run the App

**For Android:**
```bash
flutter run
```

**For iOS:**
```bash
flutter run
```

**For Web:**
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── core/              # Core utilities and helpers
├── models/            # Data models
├── providers/        # State management providers
├── services/         # API services (Supabase)
├── presentation/     # UI screens
│   ├── cinema_home_screen/
│   ├── movie_list_screen/
│   ├── movie_detail_screen/
│   └── ...
├── routes/           # App routing
└── theme/            # App theming
```

## Database Setup

The database schema is defined in `database_spec_cinema_booking.md`. Make sure to set up your Supabase database according to the specification before running the app.

## Features

- Browse movies (Now Showing, Coming Soon)
- Movie detail pages with trailer links
- Cinema selection
- Showtime selection
- Seat selection (coming soon)
- Food & drink combos (coming soon)
- Coupon application (coming soon)
- Payment integration (coming soon)
- User authentication

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.
