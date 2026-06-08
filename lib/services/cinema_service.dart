import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cinema_entity_model.dart';

class CinemaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CinemaEntityModel>> getAllCinemas() async {
    try {
      final response = await _supabase
          .from('cinemas')
          .select()
          .order('name')
          .timeout(const Duration(seconds: 10));

      return (response as List)
          .map(
            (json) => CinemaEntityModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cinemas: $e');
    }
  }
}
