# Backend API Documentation - Cinema Booking App (Simple Flow)

This document provides API reference for the Backend services.

## Table of Contents

1. [AuthService](#authservice)
2. [MovieService](#movieservice)
3. [AuthProvider](#authprovider)
4. [MovieProvider](#movieprovider)

---

## AuthService

**File:** `lib/services/auth_service.dart`

Handles authentication operations with Supabase Auth.

### Methods

#### `register()`

Register a new user account.

```dart
Future<User> register({
  required String email,
  required String password,
  required String fullName,
  String? phone,
})
```

**Parameters:**
- `email` - User email address
- `password` - Password (minimum 6 characters)
- `fullName` - Customer full name
- `phone` - Phone number (optional)

**Returns:** `User` object from Supabase

**Throws:** Exception with error message

**Example:**
```dart
final authService = AuthService();
try {
  final user = await authService.register(
    email: 'user@example.com',
    password: 'password123',
    fullName: 'John Doe',
    phone: '+84912345678',
  );
  print('User registered: ${user.id}');
} catch (e) {
  print('Error: $e');
}
```

---

#### `login()`

Login with email and password.

```dart
Future<Session> login({
  required String email,
  required String password,
})
```

**Parameters:**
- `email` - User email address
- `password` - User password

**Returns:** `Session` object if successful

**Throws:** Exception with error message

**Example:**
```dart
final authService = AuthService();
try {
  final session = await authService.login(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Logged in successfully');
} catch (e) {
  print('Error: $e');
}
```

---

#### `logout()`

Logout current user.

```dart
Future<void> logout()
```

**Throws:** Exception if logout fails

**Example:**
```dart
final authService = AuthService();
await authService.logout();
```

---

#### `checkSession()`

Check if user has an active session.

```dart
bool checkSession()
```

**Returns:** `true` if session exists, `false` otherwise

**Example:**
```dart
final authService = AuthService();
if (authService.checkSession()) {
  print('User is logged in');
} else {
  print('User is not logged in');
}
```

---

#### `getCurrentUserProfile()`

Get current user's customer profile.

```dart
Future<CustomerModel?> getCurrentUserProfile()
```

**Returns:** `CustomerModel` if found, `null` if user not logged in

**Throws:** Exception if query fails

**Example:**
```dart
final authService = AuthService();
final profile = await authService.getCurrentUserProfile();
if (profile != null) {
  print('Name: ${profile.fullName}');
}
```

---

#### `resetPassword()`

Send password reset email.

```dart
Future<void> resetPassword({required String email})
```

**Parameters:**
- `email` - User email address

**Throws:** Exception if reset fails

**Example:**
```dart
final authService = AuthService();
await authService.resetPassword(email: 'user@example.com');
```

---

### Properties

#### `currentUser`

```dart
User? get currentUser
```

Get the currently authenticated user.

---

#### `currentSession`

```dart
Session? get currentSession
```

Get the current authentication session.

---

#### `isLoggedIn`

```dart
bool get isLoggedIn
```

Check if any user is logged in.

---

## MovieService

**File:** `lib/services/movie_service.dart`

Handles movie data operations.

### Methods

#### `getMoviesByStatus()`

Get movies filtered by status.

```dart
Future<List<MovieModel>> getMoviesByStatus({
  required String status,
})
```

**Parameters:**
- `status` - Movie status: `'now_showing'`, `'coming_soon'`, or `'ended'`

**Returns:** List of `MovieModel` sorted by release date (newest first)

**Throws:** Exception if query fails

**Example:**
```dart
final movieService = MovieService();
final movies = await movieService.getMoviesByStatus(status: 'now_showing');
```

---

#### `getNowShowingMovies()`

Get all now showing movies.

```dart
Future<List<MovieModel>> getNowShowingMovies()
```

**Returns:** List of `MovieModel`

**Example:**
```dart
final movieService = MovieService();
final movies = await movieService.getNowShowingMovies();
```

---

#### `getComingSoonMovies()`

Get all coming soon movies.

```dart
Future<List<MovieModel>> getComingSoonMovies()
```

**Returns:** List of `MovieModel`

**Example:**
```dart
final movieService = MovieService();
final movies = await movieService.getComingSoonMovies();
```

---

#### `getAllMovies()`

Get all movies regardless of status.

```dart
Future<List<MovieModel>> getAllMovies()
```

**Returns:** List of all `MovieModel`

**Example:**
```dart
final movieService = MovieService();
final movies = await movieService.getAllMovies();
```

---

#### `getMovieById()`

Get a single movie by ID.

```dart
Future<MovieModel?> getMovieById({required String movieId})
```

**Parameters:**
- `movieId` - Movie UUID

**Returns:** `MovieModel` if found, `null` otherwise

**Example:**
```dart
final movieService = MovieService();
final movie = await movieService.getMovieById(movieId: 'uuid-here');
```

---

#### `searchMovies()`

Search movies by title or genre.

```dart
Future<List<MovieModel>> searchMovies({
  required String keyword,
  String? status,
})
```

**Parameters:**
- `keyword` - Search term
- `status` - Optional status filter

**Returns:** List of matching `MovieModel`

**Example:**
```dart
final movieService = MovieService();
final results = await movieService.searchMovies(
  keyword: 'Dragon',
  status: 'now_showing',
);
```

---

#### `getMoviesByGenre()`

Get movies by genre.

```dart
Future<List<MovieModel>> getMoviesByGenre({required String genre})
```

**Parameters:**
- `genre` - Genre name

**Returns:** List of `MovieModel`

**Example:**
```dart
final movieService = MovieService();
final scifi = await movieService.getMoviesByGenre(genre: 'Science Fiction');
```

---

## AuthProvider

**File:** `lib/providers/auth_provider.dart`

State management for authentication using Provider package.

### Methods

#### `checkSession()`

Check authentication state at app startup.

```dart
Future<void> checkSession()
```

**Use Case:** Call this when app starts to check if user is already logged in.

**Example:**
```dart
final authProvider = context.read<AuthProvider>();
await authProvider.checkSession();
```

---

#### `register()`

Register new user via provider.

```dart
Future<bool> register({
  required String email,
  required String password,
  required String fullName,
  String? phone,
})
```

**Returns:** `true` if successful, `false` if failed

**Validates:**
- Email not empty
- Email format is valid
- Password not empty
- Password at least 6 characters
- Full name not empty

**Example:**
```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.register(
  email: 'user@example.com',
  password: 'password123',
  fullName: 'John Doe',
);
```

---

#### `login()`

Login via provider.

```dart
Future<bool> login({
  required String email,
  required String password,
})
```

**Returns:** `true` if successful, `false` if failed

**Validates:**
- Email not empty
- Email format is valid
- Password not empty

**Example:**
```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password123',
);
```

---

#### `logout()`

Logout current user.

```dart
Future<void> logout()
```

**Example:**
```dart
final authProvider = context.read<AuthProvider>();
await authProvider.logout();
```

---

#### `clearError()`

Clear error message.

```dart
void clearError()
```

---

### Properties

#### `isLoading`

```dart
bool get isLoading
```

Loading state during async operations.

---

#### `errorMessage`

```dart
String? get errorMessage
```

Error message if operation failed.

---

#### `currentUser`

```dart
User? get currentUser
```

Currently authenticated user.

---

#### `currentCustomer`

```dart
CustomerModel? get currentCustomer
```

Current user's customer profile.

---

#### `isLoggedIn`

```dart
bool get isLoggedIn
```

Check if user is logged in.

---

## MovieProvider

**File:** `lib/providers/movie_provider.dart`

State management for movies using Provider package.

### Methods

#### `loadNowShowingMovies()`

Load all now showing movies.

```dart
Future<void> loadNowShowingMovies()
```

**Example:**
```dart
final movieProvider = context.read<MovieProvider>();
await movieProvider.loadNowShowingMovies();
```

---

#### `loadComingSoonMovies()`

Load all coming soon movies.

```dart
Future<void> loadComingSoonMovies()
```

---

#### `loadAllMovies()`

Load all movies regardless of status.

```dart
Future<void> loadAllMovies()
```

---

#### `loadMoviesByStatus()`

Load movies by specific status.

```dart
Future<void> loadMoviesByStatus({required String status})
```

**Parameters:**
- `status` - Movie status

---

#### `searchMovies()`

Search in already loaded movies (client-side).

```dart
void searchMovies({required String keyword})
```

**Parameters:**
- `keyword` - Search term

**Use:** Call after loading movies to filter locally.

**Example:**
```dart
final movieProvider = context.read<MovieProvider>();
await movieProvider.loadNowShowingMovies();
movieProvider.searchMovies(keyword: 'Dragon');
```

---

#### `searchMoviesFromServer()`

Search from server (useful for searching across all movies).

```dart
Future<void> searchMoviesFromServer({
  required String keyword,
  String? status,
})
```

**Example:**
```dart
final movieProvider = context.read<MovieProvider>();
await movieProvider.searchMoviesFromServer(keyword: 'Dragon');
```

---

#### `clearSearch()`

Clear search filter and show all loaded movies.

```dart
void clearSearch()
```

---

#### `switchStatus()`

Switch between now showing and coming soon tabs.

```dart
Future<void> switchStatus({required String status})
```

---

#### `getMovieById()`

Get a single movie by ID.

```dart
Future<MovieModel?> getMovieById({required String movieId})
```

---

#### `clearError()`

Clear error message.

```dart
void clearError()
```

---

### Properties

#### `isLoading`

```dart
bool get isLoading
```

Loading state.

---

#### `errorMessage`

```dart
String? get errorMessage
```

Error message.

---

#### `movies`

```dart
List<MovieModel> get movies
```

Current displayed movies (filtered or all).

---

#### `allMovies`

```dart
List<MovieModel> get allMovies
```

All loaded movies.

---

#### `selectedStatus`

```dart
String get selectedStatus
```

Currently selected status filter.

---

#### `searchKeyword`

```dart
String get searchKeyword
```

Current search keyword.

---

## Models

### CustomerModel

**File:** `lib/models/customer_model.dart`

```dart
class CustomerModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String membershipLevel; // 'regular', 'silver', 'gold', 'vip'
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### MovieModel

**File:** `lib/models/movie_model.dart`

```dart
class MovieModel {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String bannerUrl;
  final String trailerUrl;
  final String genre;
  final String director;
  final String language;
  final String? subtitle;
  final int durationMinutes;
  final String ageRating;
  final DateTime releaseDate;
  final String status; // 'now_showing', 'coming_soon', 'ended'
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## Usage Examples

### Complete Registration Flow

```dart
final authProvider = context.read<AuthProvider>();

// Register
final success = await authProvider.register(
  email: 'john@example.com',
  password: 'securePass123',
  fullName: 'John Doe',
  phone: '+84912345678',
);

if (success) {
  print('Registration successful');
  print('User: ${authProvider.currentCustomer?.fullName}');
} else {
  print('Error: ${authProvider.errorMessage}');
}
```

### Complete Login Flow

```dart
final authProvider = context.read<AuthProvider>();

// Login
final success = await authProvider.login(
  email: 'john@example.com',
  password: 'securePass123',
);

if (success) {
  print('Login successful');
  // Navigate to home screen
} else {
  print('Error: ${authProvider.errorMessage}');
}
```

### Complete Movie Loading Flow

```dart
final movieProvider = context.read<MovieProvider>();

// Load movies
await movieProvider.loadNowShowingMovies();

// Get movies
final movies = movieProvider.movies;

// Search
movieProvider.searchMovies(keyword: 'Dragon');

// Clear search
movieProvider.clearSearch();

// Switch to coming soon
await movieProvider.switchStatus(status: 'coming_soon');
```

---

## Error Handling

All services throw exceptions with descriptive messages. Always wrap calls in try-catch:

```dart
try {
  await authProvider.login(email: email, password: password);
} catch (e) {
  print('Login error: $e');
}
```

Providers set `errorMessage` automatically, which you can display to users.

---

## Next Steps

Implement the Frontend Screens:
- Splash/Auth Check Screen
- Login Screen
- Register Screen
- Home/Movie List Screen

All screens should use these providers to manage state and make API calls.
