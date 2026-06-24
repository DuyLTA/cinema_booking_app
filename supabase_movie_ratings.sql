-- Movie ratings setup for Cinema Booking App
-- Run this in Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS movie_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (movie_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_movie_ratings_movie_id
ON movie_ratings(movie_id);

CREATE INDEX IF NOT EXISTS idx_movie_ratings_user_id
ON movie_ratings(user_id);

CREATE OR REPLACE VIEW movie_rating_stats AS
SELECT
  movie_id,
  ROUND(AVG(rating)::numeric, 2) AS average_rating,
  COUNT(*)::int AS rating_count
FROM movie_ratings
GROUP BY movie_id;

ALTER TABLE movie_ratings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read movie ratings" ON movie_ratings;
CREATE POLICY "Anyone can read movie ratings"
ON movie_ratings FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Users can insert own movie rating" ON movie_ratings;
CREATE POLICY "Users can insert own movie rating"
ON movie_ratings FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own movie rating" ON movie_ratings;
CREATE POLICY "Users can update own movie rating"
ON movie_ratings FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own movie rating" ON movie_ratings;
CREATE POLICY "Users can delete own movie rating"
ON movie_ratings FOR DELETE
USING (auth.uid() = user_id);
