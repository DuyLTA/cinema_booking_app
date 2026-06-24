import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_flow_models.dart';

class FoodService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<FoodItemModel>> getAvailableFoods() async {
    try {
      final response = await _supabase
          .from('foods')
          .select(
            'id,product_name,category,description,image_url,price,is_available',
          )
          .eq('is_available', true)
          .order('category')
          .order('product_name')
          .timeout(const Duration(seconds: 10));

      return (response as List)
          .map(
            (json) =>
                FoodItemModel.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch food and beverage: $e');
    }
  }
}
