class MovieRatingStats {
  const MovieRatingStats({
    required this.movieId,
    required this.averageRating,
    required this.ratingCount,
  });

  final String movieId;
  final double averageRating;
  final int ratingCount;

  factory MovieRatingStats.fromJson(Map<String, dynamic> json) {
    final rawAverage = json['average_rating'];
    final rawCount = json['rating_count'];

    return MovieRatingStats(
      movieId: json['movie_id'] as String? ?? '',
      averageRating: rawAverage is num ? rawAverage.toDouble() : 0,
      ratingCount: rawCount is int
          ? rawCount
          : rawCount is num
          ? rawCount.toInt()
          : 0,
    );
  }
}
