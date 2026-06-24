import 'package:flutter/material.dart';

import '../../../models/booking_flow_models.dart';
import '../../../services/food_service.dart';

class FoodBeverageProvider extends ChangeNotifier {
  final FoodService _foodService = FoodService();

  bool isLoading = false;
  String? errorMessage;
  String selectedCategory = 'All Snacks';
  List<FoodItemModel> foods = [];
  final Map<String, int> quantities = {};

  List<String> get categories {
    final values =
        foods
            .map((food) => food.category.trim())
            .where(
              (category) =>
                  category.isNotEmpty && category.toLowerCase() != 'all snacks',
            )
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All Snacks', ...values];
  }

  List<FoodItemModel> get filteredFoods {
    if (selectedCategory == 'All Snacks') return foods;
    return foods
        .where(
          (food) =>
              food.category.toLowerCase() == selectedCategory.toLowerCase(),
        )
        .toList();
  }

  List<SelectedFoodItemModel> get selectedFoods {
    return foods
        .where((food) => (quantities[food.id] ?? 0) > 0)
        .map(
          (food) =>
              SelectedFoodItemModel(food: food, quantity: quantities[food.id]!),
        )
        .toList();
  }

  int get selectedItemCount {
    return quantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double get foodTotal {
    return selectedFoods.fold(0, (sum, item) => sum + item.lineTotal);
  }

  Future<void> loadFoods() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      foods = await _foodService.getAvailableFoods();
      final availableCategories = categories;
      if (!availableCategories.contains(selectedCategory)) {
        selectedCategory = availableCategories.first;
      }
    } catch (e) {
      errorMessage = e.toString();
      foods = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void increment(FoodItemModel food) {
    quantities[food.id] = (quantities[food.id] ?? 0) + 1;
    notifyListeners();
  }

  void decrement(FoodItemModel food) {
    final current = quantities[food.id] ?? 0;
    if (current <= 0) return;
    if (current == 1) {
      quantities.remove(food.id);
    } else {
      quantities[food.id] = current - 1;
    }
    notifyListeners();
  }
}
