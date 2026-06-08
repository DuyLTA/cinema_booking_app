# Quick Start Guide - Backend Setup

## Prerequisites
- Flutter SDK installed
- Supabase account
- VS Code or Android Studio

## 1. Setup Environment

### 1.1 Create `.env` file
Create a file named `.env` in the project root:

```
SUPABASE_URL=https://your-project-url.supabase.co
SUPABASE_KEY=your-public-anon-key
```

Get these values from your Supabase project settings.

### 1.2 Install Dependencies
```bash
flutter pub get
```

## 2. Setup Supabase Database

### 2.1 Create Supabase Project
1. Go to https://supabase.com
2. Create a new project
3. Save your project URL and public key

### 2.2 Create Database Tables
1. Go to SQL Editor in Supabase dashboard
2. Copy all SQL from `SUPABASE_SETUP.md` (Section 3 and 4)
3. Run the SQL scripts
4. Enable RLS policies

### 2.3 Insert Sample Data
1. Copy SQL from `SUPABASE_SETUP.md` (Section 5)
2. Run in SQL Editor
3. Verify movies appear in the movies table

## 3. Test Backend (Without UI)

### 3.1 Run the App
```bash
flutter run
```

You should see:
- Splash screen with "CineBooking" title
- Loading indicator for 1 second
- SnackBar showing "User is not logged in" (since no user is registered yet)

### 3.2 Test Registration
1. Register a user via Supabase dashboard:
   - Go to **Authentication** > **Users**
   - Click **Add user**
   - Enter email: `test@example.com`
   - Enter password: `Test@1234`
   - Save

2. Verify customer profile was created by checking SQL:
   ```sql
   SELECT * FROM customers WHERE email = 'test@example.com';
   ```

### 3.3 Test Movie Loading
Run this SQL to verify movies are in database:
```sql
SELECT id, title, status, release_date FROM movies ORDER BY release_date DESC;
```

## 4. File Structure Summary

**Models:**
- `lib/models/customer_model.dart` - Customer data structure
- `lib/models/movie_model.dart` - Movie data structure

**Services:**
- `lib/services/auth_service.dart` - Auth operations (register, login, logout)
- `lib/services/movie_service.dart` - Movie CRUD operations

**Providers:**
- `lib/providers/auth_provider.dart` - Auth state management
- `lib/providers/movie_provider.dart` - Movie state management

**Configuration:**
- `lib/main.dart` - App entry point with provider setup

## 5. Common Issues & Solutions

### Connection Failed
**Error:** `Connection failed: Connection to supabase failed`
- Check `.env` file has correct SUPABASE_URL and SUPABASE_KEY
- Verify Supabase project is running
- Check internet connection

### Auth Error
**Error:** `Registration failed: Email already exists`
- This email is already registered
- Use a different email address

**Error:** `Password must be at least 6 characters`
- Use password with 6+ characters

### Database Error
**Error:** `ProgramError: relation "movies" does not exist`
- Run SQL from `SUPABASE_SETUP.md` Section 3 to create tables

**Error:** `new row violates row-level security policy`
- Check RLS policies are set up correctly

## 6. Usage Examples

### Example 1: Check Registration in Code
```dart
import 'package:cinema_booking_app/services/auth_service.dart';

final authService = AuthService();

try {
  final user = await authService.register(
    email: 'newuser@example.com',
    password: 'SecurePass123',
    fullName: 'John Doe',
    phone: '+84912345678',
  );
  print('User registered: ${user.id}');
} catch (e) {
  print('Error: $e');
}
```

### Example 2: Check Movies in Code
```dart
import 'package:cinema_booking_app/services/movie_service.dart';

final movieService = MovieService();

try {
  final movies = await movieService.getNowShowingMovies();
  print('Found ${movies.length} now showing movies');
  for (final movie in movies) {
    print('- ${movie.title} (${movie.genre})');
  }
} catch (e) {
  print('Error: $e');
}
```

## 7. Next Steps - Frontend Implementation

### 7.1 Create Login Screen
**Location:** `lib/screens/login_screen.dart`

Use `AuthProvider`:
```dart
context.read<AuthProvider>().login(
  email: emailController.text,
  password: passwordController.text,
)
```

### 7.2 Create Register Screen
**Location:** `lib/screens/register_screen.dart`

Use `AuthProvider`:
```dart
context.read<AuthProvider>().register(
  email: emailController.text,
  password: passwordController.text,
  fullName: nameController.text,
  phone: phoneController.text,
)
```

### 7.3 Create Home Screen
**Location:** `lib/screens/home_screen.dart`

Use `MovieProvider`:
```dart
// Load movies
context.read<MovieProvider>().loadNowShowingMovies()

// Get movies
final movies = context.watch<MovieProvider>().movies;

// Search
context.read<MovieProvider>().searchMovies(keyword: searchText);
```

### 7.4 Update SplashScreen Navigation
Update `main.dart` SplashScreen to navigate to actual screens instead of SnackBar.

## 8. Useful Commands

### Install dependencies
```bash
flutter pub get
```

### Run app on emulator
```bash
flutter run
```

### Run app on specific device
```bash
flutter devices  # List devices
flutter run -d <device-id>
```

### Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### View Flutter logs
```bash
flutter logs
```

## 9. Deployment Checklist

Before production:
- ✅ Create separate Supabase project for production
- ✅ Update API keys in production `.env`
- ✅ Set up RLS policies on all tables
- ✅ Enable backups in Supabase
- ✅ Test all authentication flows
- ✅ Verify error messages are user-friendly
- ✅ Set up error logging/monitoring

## 10. Documentation Reference

- **SUPABASE_SETUP.md** - Database setup instructions
- **BACKEND_API.md** - Complete API reference
- **simple_auth_movie_flow.md** - Business requirements
- **database_spec_cinema_booking.md** - Full database schema

---

## Support

For Supabase documentation: https://supabase.com/docs
For Flutter Provider: https://pub.dev/packages/provider
For Flutter documentation: https://flutter.dev/docs
