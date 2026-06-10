import 'dart:convert';

class MovieModel {
  final String id;
  final String title;
  final String description;
  final String? posterUrl;
  final String? bannerUrl;
  final String? trailerUrl;
  final String? genre;
  final String? director;
  final String? language;
  final String? subtitle;
  final int? durationMinutes;
  final String? ageRating;
  final DateTime? releaseDate;
  final List<MovieCredit> castMembers;
  final List<MovieCredit> crewMembers;
  final String status; // now_showing, coming_soon, ended
  final DateTime createdAt;
  final DateTime updatedAt;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    this.bannerUrl,
    this.trailerUrl,
    this.genre,
    this.director,
    this.language,
    this.subtitle,
    this.durationMinutes,
    this.ageRating,
    this.releaseDate,
    this.castMembers = const [],
    this.crewMembers = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create MovieModel from JSON (Supabase response)
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      posterUrl: json['poster_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      trailerUrl: json['trailer_url'] as String?,
      genre: json['genre'] as String?,
      director: json['director'] as String?,
      language: json['language'] as String?,
      subtitle: json['subtitle'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      ageRating: json['age_rating'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      castMembers: MovieCredit.listFromJson(
        json['cast_members'],
        roleKey: 'role',
      ),
      crewMembers: MovieCredit.listFromJson(
        json['crew_members'],
        roleKey: 'job',
      ),
      status: json['status'] as String? ?? 'coming_soon',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert MovieModel to JSON for inserting into Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'banner_url': bannerUrl,
      'trailer_url': trailerUrl,
      'genre': genre,
      'director': director,
      'language': language,
      'subtitle': subtitle,
      'duration_minutes': durationMinutes,
      'age_rating': ageRating,
      'release_date': releaseDate?.toIso8601String().split('T')[0],
      'cast_members': castMembers.map((credit) => credit.toJson()).toList(),
      'crew_members': crewMembers.map((credit) => credit.toJson()).toList(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with some fields replaced
  MovieModel copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    String? bannerUrl,
    String? trailerUrl,
    String? genre,
    String? director,
    String? language,
    String? subtitle,
    int? durationMinutes,
    String? ageRating,
    DateTime? releaseDate,
    List<MovieCredit>? castMembers,
    List<MovieCredit>? crewMembers,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      genre: genre ?? this.genre,
      director: director ?? this.director,
      language: language ?? this.language,
      subtitle: subtitle ?? this.subtitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      ageRating: ageRating ?? this.ageRating,
      releaseDate: releaseDate ?? this.releaseDate,
      castMembers: castMembers ?? this.castMembers,
      crewMembers: crewMembers ?? this.crewMembers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'MovieModel(id: $id, title: $title, status: $status, durationMinutes: $durationMinutes)';
}

class MovieCredit {
  final String name;
  final String role;
  final String? imageUrl;

  const MovieCredit({required this.name, required this.role, this.imageUrl});

  factory MovieCredit.fromJson(
    Map<String, dynamic> json, {
    required String roleKey,
  }) {
    return MovieCredit(
      name: json['name'] as String? ?? '',
      role:
          json[roleKey] as String? ??
          json['role'] as String? ??
          json['job'] as String? ??
          '',
      imageUrl: json['image_url'] as String?,
    );
  }

  static List<MovieCredit> listFromJson(
    dynamic value, {
    required String roleKey,
  }) {
    dynamic rawList;
    try {
      rawList = switch (value) {
        final String text when text.trim().isNotEmpty => jsonDecode(text),
        final List<dynamic> list => list,
        _ => const <dynamic>[],
      };
    } catch (_) {
      rawList = const <dynamic>[];
    }

    if (rawList is! List) {
      return const [];
    }

    return rawList
        .whereType<Map>()
        .map(
          (item) => MovieCredit.fromJson(
            Map<String, dynamic>.from(item),
            roleKey: roleKey,
          ),
        )
        .where((credit) => credit.name.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'role': role, 'image_url': imageUrl};
  }
}
