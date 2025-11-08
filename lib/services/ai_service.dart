import 'package:flutter/foundation.dart';
import '../models/food_detection_result.dart';

class AiService {
  static const String _apiGatewayUrl = 'https://your-api-gateway-url.amazonaws.com/prod';
  static const Duration _timeout = Duration(seconds: 30);

  Future<FoodDetectionResult> processImage(String imageKey) async {
    debugPrint('Processing image: $imageKey');
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Return mock result for now
    return FoodDetectionResult(
      imageId: imageKey,
      ingredients: [
        Ingredient(
          name: 'Detected Food',
          confidence: 0.85,
          weight: 100.0,
          nutrition: NutritionData(
            calories: 150,
            protein: 5,
            carbs: 20,
            fat: 6,
          ),
        ),
      ],
      totalNutrition: NutritionData(
        calories: 150,
        protein: 5,
        carbs: 20,
        fat: 6,
      ),
      timestamp: DateTime.now().toIso8601String(),
      confidenceScore: 0.85,
    );
  }
}
