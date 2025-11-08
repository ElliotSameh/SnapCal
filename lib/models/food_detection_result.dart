import 'dart:math';
import '../models/food_detection_result.dart';  // Adjust path to your models

class MockFoodDetector {
  // Your 30 food classes with sample nutrition (per 100g)
  final Map<String, Map<String, double>> _nutritionDatabase = {
    'baby corn': {'calories': 23, 'protein': 2.0, 'carbs': 4.7, 'fat': 0.1},
    'bean sprout': {'calories': 30, 'protein': 3.0, 'carbs': 5.9, 'fat': 0.2},
    'black glutinous rice': {'calories': 356, 'protein': 8.9, 'carbs': 75.6, 'fat': 3.3},
    'boiled egg': {'calories': 155, 'protein': 13.0, 'carbs': 1.1, 'fat': 11.0},
    'broccoli': {'calories': 34, 'protein': 2.8, 'carbs': 7.0, 'fat': 0.4},
    'cabbage': {'calories': 25, 'protein': 1.3, 'carbs': 5.8, 'fat': 0.1},
    'carrot': {'calories': 41, 'protein': 0.9, 'carbs': 10.0, 'fat': 0.2},
    'chicken breast': {'calories': 165, 'protein': 31.0, 'carbs': 0.0, 'fat': 3.6},
    'chicken leg': {'calories': 172, 'protein': 25.9, 'carbs': 0.0, 'fat': 6.9},
    'corn': {'calories': 86, 'protein': 3.3, 'carbs': 19.0, 'fat': 1.4},
    'cucumber': {'calories': 16, 'protein': 0.7, 'carbs': 3.6, 'fat': 0.1},
    'dark green leaf vegetable': {'calories': 23, 'protein': 2.9, 'carbs': 3.6, 'fat': 0.4},
    'fried chicken': {'calories': 246, 'protein': 19.0, 'carbs': 9.0, 'fat': 15.0},
    'fried egg': {'calories': 196, 'protein': 13.6, 'carbs': 0.8, 'fat': 15.0},
    'fried tofu': {'calories': 271, 'protein': 17.2, 'carbs': 10.5, 'fat': 17.7},
    'green bean': {'calories': 31, 'protein': 1.8, 'carbs': 7.0, 'fat': 0.1},
    'green pepper': {'calories': 20, 'protein': 0.9, 'carbs': 4.6, 'fat': 0.2},
    'oily tofu': {'calories': 144, 'protein': 15.8, 'carbs': 4.3, 'fat': 8.7},
    'okra': {'calories': 33, 'protein': 1.9, 'carbs': 7.5, 'fat': 0.2},
    'pork chop': {'calories': 231, 'protein': 25.8, 'carbs': 0.0, 'fat': 13.9},
    'rice': {'calories': 130, 'protein': 2.7, 'carbs': 28.0, 'fat': 0.3},
    'salmon': {'calories': 208, 'protein': 20.4, 'carbs': 0.0, 'fat': 13.4},
    'sausage': {'calories': 301, 'protein': 12.0, 'carbs': 1.5, 'fat': 27.0},
    'scrambled eggs with tomatoes': {'calories': 154, 'protein': 10.9, 'carbs': 5.3, 'fat': 10.4},
    'shred chicken': {'calories': 239, 'protein': 27.0, 'carbs': 0.0, 'fat': 14.0},
    'shrimp': {'calories': 99, 'protein': 24.0, 'carbs': 0.2, 'fat': 0.3},
    'shrimp roll': {'calories': 175, 'protein': 8.5, 'carbs': 15.0, 'fat': 9.0},
    'stewed pork': {'calories': 297, 'protein': 26.0, 'carbs': 0.0, 'fat': 21.0},
    'sweet potato': {'calories': 86, 'protein': 1.6, 'carbs': 20.1, 'fat': 0.1},
    'tomato': {'calories': 18, 'protein': 0.9, 'carbs': 3.9, 'fat': 0.2},
  };

  // List of food class names for random selection
  final List<String> _foodClasses = _nutritionDatabase.keys.toList();

  // Simulate AI detection (replace real model inference)
  Future<FoodDetectionResult> detectFood(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 1500));  // Simulate API/model delay

    final random = Random();
    final numDetections = random.nextInt(4) + 1;  // 1-4 ingredients
    final ingredients = <Ingredient>[];

    for (int i = 0; i < numDetections; i++) {
      final foodName = _foodClasses[random.nextInt(_foodClasses.length)];
      final confidence = (random.nextDouble() * 0.4) + 0.6;  // 60-100% confidence
      final estimatedWeight = (random.nextDouble() * 200) + 50;  // 50-250g

      final nutritionData = _nutritionDatabase[foodName]!;
      final nutrition = NutritionData(
        calories: (nutritionData['calories']! / 100) * estimatedWeight,
        protein: (nutritionData['protein']! / 100) * estimatedWeight,
        carbs: (nutritionData['carbs']! / 100) * estimatedWeight,
        fat: (nutritionData['fat']! / 100) * estimatedWeight,
      );

      ingredients.add(Ingredient(
        name: foodName,
        confidence: confidence,
        weight: estimatedWeight,
        nutrition: nutrition,
      ));
    }

    final totalNutrition = _calculateTotal(ingredients);
    final avgConfidence = ingredients.isEmpty ? 0.0 : ingredients.map((e) => e.confidence).reduce((a, b) => a + b) / ingredients.length;

    return FoodDetectionResult(
      imageId: DateTime.now().millisecondsSinceEpoch.toString(),
      ingredients: ingredients,
      totalNutrition: totalNutrition,
      timestamp: DateTime.now().toIso8601String(),
      confidenceScore: avgConfidence,
    );
  }

  NutritionData _calculateTotal(List<Ingredient> ingredients) {
    double calories = 0, protein = 0, carbs = 0, fat = 0;
    for (final ingredient in ingredients) {
      calories += ingredient.nutrition.calories;
      protein += ingredient.nutrition.protein;
      carbs += ingredient.nutrition.carbs;
      fat += ingredient.nutrition.fat;
    }
    return NutritionData(calories: calories, protein: protein, carbs: carbs, fat: fat);
  }
}
