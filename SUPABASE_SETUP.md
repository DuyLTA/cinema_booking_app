# Supabase Database Setup Guide - Simple Auth & Movie Flow

This guide explains how to set up Supabase for the simple authentication and movie list flow.

## 1. Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Create a new project:
   - Project name: `cinema-booking-app`
   - Database password: Create a strong password (save it)
   - Region: Choose closest to your location
4. Wait for project initialization (usually 2-3 minutes)

## 2. Get API Keys

After project is created:

1. Go to **Project Settings** > **API**
2. Copy these values:
   - **Project URL** → `SUPABASE_URL` in .env
   - **anon public** key → `SUPABASE_KEY` in .env (NOT the secret key!)

3. Create `.env` file in project root:
```
SUPABASE_URL=https://your-project-url.supabase.co
SUPABASE_KEY=your-public-key
```

## 3. Create Tables

Go to **SQL Editor** in Supabase dashboard and run these SQL commands:

### 3.1 Create customers table

```sql
CREATE TABLE customers (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  membership_level TEXT DEFAULT 'regular',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on email for faster lookups
CREATE INDEX idx_customers_email ON customers(email);
```

### 3.2 Create movies table

```sql
CREATE TABLE movies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  poster_url TEXT NOT NULL,
  banner_url TEXT NOT NULL,
  trailer_url TEXT,
  genre TEXT NOT NULL,
  director TEXT NOT NULL,
  language TEXT NOT NULL,
  subtitle TEXT,
  duration_minutes INTEGER NOT NULL,
  age_rating TEXT NOT NULL,
  release_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'coming_soon',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_movies_status ON movies(status);
CREATE INDEX idx_movies_release_date ON movies(release_date DESC);
```

## 4. Set Up Row Level Security (RLS)

### 4.1 Enable RLS

1. Go to **Authentication** > **Policies** in Supabase dashboard
2. For **customers** table:
   - Enable RLS
   - Create policy: **SELECT** - Allow users to view only their own profile
   - Policy name: `Enable select for users based on id`
   - Target role: `authenticated`
   - Command: `SELECT`
   - Using expression: `auth.uid() = id`
   - Create policy: **UPDATE** - Allow users to update only their own profile
   - Policy name: `Users can update own profile`
   - Target role: `authenticated`
   - Command: `UPDATE`
   - Using expression: `auth.uid() = id`
   - Check expression: `auth.uid() = id`
   - Create policy: **INSERT** - Allow users to insert their own profile row
   - Policy name: `Users can insert own profile`
   - Target role: `authenticated`
   - Command: `INSERT`
   - Check expression: `auth.uid() = id`

3. For **movies** table:
   - Enable RLS
   - Create policy: **SELECT** - Allow public read
   - Policy name: `Enable select for all users`
   - Target role: `anon`
   - Command: `SELECT`
   - Using expression: `true`

### 4.2 SQL for RLS (Alternative)

```sql
-- Enable RLS on customers
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own profile
CREATE POLICY "Users can view own profile"
ON customers FOR SELECT
USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
ON customers FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
ON customers FOR INSERT
WITH CHECK (auth.uid() = id);

-- Enable RLS on movies
ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read movies
CREATE POLICY "Anyone can read movies"
ON movies FOR SELECT
USING (true);
```

## 5. Insert Sample Data

Go to **SQL Editor** and run:

```sql
-- Insert sample movies
INSERT INTO movies (title, description, poster_url, banner_url, trailer_url, genre, director, language, subtitle, duration_minutes, age_rating, release_date, status)
VALUES
  (
    'The Quantum Paradox',
    'A brilliant physicist discovers a way to manipulate time itself, but every change creates dangerous ripples through reality.',
    'https://via.placeholder.com/300x450?text=The+Quantum+Paradox',
    'https://via.placeholder.com/1200x600?text=The+Quantum+Paradox',
    'https://www.youtube.com/embed/placeholder1',
    'Science Fiction',
    'Christopher Nolan',
    'English',
    'Vietnamese',
    148,
    'T16',
    '2026-01-15',
    'now_showing'
  ),
  (
    'Hearts in the Rain',
    'Two strangers meet in a train station during a storm and discover they share an unexpected connection from the past.',
    'https://via.placeholder.com/300x450?text=Hearts+in+the+Rain',
    'https://via.placeholder.com/1200x600?text=Hearts+in+the+Rain',
    'https://www.youtube.com/embed/placeholder2',
    'Romance',
    'Sofia Coppola',
    'English',
    'Vietnamese',
    118,
    'T13',
    '2026-02-14',
    'now_showing'
  ),
  (
    'Dragon Legacy',
    'In a fantasy world, a young warrior must unite the five kingdoms to defeat an ancient evil awakening from the shadows.',
    'https://via.placeholder.com/300x450?text=Dragon+Legacy',
    'https://via.placeholder.com/1200x600?text=Dragon+Legacy',
    'https://www.youtube.com/embed/placeholder3',
    'Fantasy',
    'Peter Jackson',
    'English',
    'Vietnamese',
    162,
    'T13',
    '2026-03-01',
    'coming_soon'
  ),
  (
    'Code Red',
    'A hacker discovers evidence of a massive conspiracy within the government and must go on the run to expose it.',
    'https://via.placeholder.com/300x450?text=Code+Red',
    'https://via.placeholder.com/1200x600?text=Code+Red',
    'https://www.youtube.com/embed/placeholder4',
    'Thriller',
    'Denis Villeneuve',
    'English',
    'Vietnamese',
    135,
    'T18',
    '2026-02-20',
    'now_showing'
  ),
  (
    'Starlight Adventure',
    'A group of space explorers must navigate through an asteroid field while dealing with personal conflicts and limited oxygen.',
    'https://via.placeholder.com/300x450?text=Starlight+Adventure',
    'https://via.placeholder.com/1200x600?text=Starlight+Adventure',
    'https://www.youtube.com/embed/placeholder5',
    'Science Fiction',
    'James Cameron',
    'English',
    'Vietnamese',
    155,
    'T13',
    '2026-04-10',
    'coming_soon'
  );
```

## 6. Enable Auth with Email/Password

1. Go to **Authentication** > **Providers**
2. Make sure **Email** provider is enabled (should be default)
3. Go to **Email Templates** and customize if needed

## 7. Test the Setup

### 7.1 Test with Flutter App

Run the Flutter app:

```bash
flutter pub get
flutter run
```

The app should:
- Load without errors
- Show splash screen
- Check if user is logged in

### 7.2 Test Registration/Login

You can test the backend without UI by:

1. Create a test user in Supabase dashboard:
   - Go to **Authentication** > **Users**
   - Click **Add user**
   - Enter email and password
   - Create user

2. Or test through the app when screens are implemented

## 8. Useful Supabase Queries for Testing

### Get all movies:
```sql
SELECT * FROM movies ORDER BY release_date DESC;
```

### Get now showing movies:
```sql
SELECT * FROM movies WHERE status = 'now_showing' ORDER BY release_date DESC;
```

### Get customer profile:
```sql
SELECT * FROM customers WHERE email = 'test@example.com';
```

### Check RLS policies:
```sql
SELECT * FROM pg_policies WHERE tablename = 'customers';
SELECT * FROM pg_policies WHERE tablename = 'movies';
```

## 9. Important Notes

### Security Checklist:
- ✅ Use **public/anon key** in Flutter (not secret key)
- ✅ Always keep **secret key** private (server-side only)
- ✅ Enable RLS on all tables
- ✅ Create specific policies for each table
- ✅ Test RLS policies before production

### Environment Variables:
- Keep `.env` file in `.gitignore` (do NOT commit)
- Never share your API keys publicly
- Use different projects for development/production

### Database Maintenance:
- Regularly backup your database in Supabase dashboard
- Monitor query performance using Supabase logs
- Use indexes for better query performance
- Set up automatic backups if production

## 10. Troubleshooting

### Connection Issues:
- Check if `.env` file exists with correct URL and key
- Verify project is running in Supabase dashboard
- Check network connection

### Auth Errors:
- Email already exists: User already registered
- Invalid email: Check email format
- Password too short: Must be at least 6 characters
- Invalid credentials: Wrong email or password

### Database Errors:
- Table doesn't exist: Run SQL scripts in section 3
- RLS errors: Check policies in section 4
- Permission denied: Check RLS policies

## 11. Next Steps

After this simple flow is working:

1. Implement Frontend Screens:
   - Splash/Auth Check Screen
   - Login Screen
   - Register Screen
   - Home/Movie List Screen

2. Add More Features:
   - Cinema and showtime management
   - Seat selection
   - Booking system
   - Payment integration
   - Chat support
   - Notifications

For more information, visit: [Supabase Documentation](https://supabase.com/docs)
