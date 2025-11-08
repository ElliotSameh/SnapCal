import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_detection_result.dart';

class ResultScreen extends StatefulWidget {
  final XFile imageFile;
  final FoodDetectionResult? detectionResult;
  final Function(Map<String, dynamic>)? onMealSaved;

  const ResultScreen({
    super.key,
    required this.imageFile,
    this.detectionResult,
    this.onMealSaved,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isAnalyzing = true;
  FoodDetectionResult? _result;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _initializeResult();
  }

  Future<void> _initializeResult() async {
    if (widget.detectionResult != null) {
      setState(() {
        _result = widget.detectionResult;
        _isAnalyzing = false;
      });
      _autoSaveMeal();
    } else {
      await _analyzeImageMock();
      _autoSaveMeal();
    }
  }

  void _autoSaveMeal() {
    if (_isSaved || _result == null || widget.onMealSaved == null) return;
    
    final mealData = {
      'name': _result!.ingredients.map((i) => i.name).join(', '),
      'calories': _result!.totalNutrition.calories.toInt(),
      'protein': _result!.totalNutrition.protein,
      'carbs': _result!.totalNutrition.carbs,
      'fat': _result!.totalNutrition.fat,
      'timestamp': DateTime.now(),
      'imagePath': widget.imageFile.path,
      'ingredients': _result!.ingredients.map((i) => {
        'name': i.name,
        'confidence': i.confidence,
        'weight': i.weight,
        'calories': i.nutrition.calories,
        'protein': i.nutrition.protein,
        'carbs': i.nutrition.carbs,
        'fat': i.nutrition.fat,
      }).toList(),
    };
    
    // FIXED: Schedule after the current build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isSaved) {
        widget.onMealSaved!(mealData);
        setState(() {
          _isSaved = true;
        });
      }
    });
  }

  Future<void> _analyzeImageMock() async {
    await Future.delayed(const Duration(seconds: 3));

    final String path = widget.imageFile.path.toLowerCase();
    List<Ingredient> mockIngredients = [];

    if (path.contains('salad')) {
      mockIngredients = [
        Ingredient(
          name: 'Chicken',
          confidence: 0.92,
          weight: 150.0,
          nutrition: NutritionData(calories: 200, protein: 31, carbs: 0, fat: 7.5),
        ),
        Ingredient(
          name: 'Lettuce',
          confidence: 0.88,
          weight: 50.0,
          nutrition: NutritionData(calories: 10, protein: 0.7, carbs: 2.0, fat: 0.1),
        ),
        Ingredient(
          name: 'Tomato',
          confidence: 0.85,
          weight: 80.0,
          nutrition: NutritionData(calories: 15, protein: 0.7, carbs: 3.2, fat: 0.2),
        ),
        Ingredient(
          name: 'Cucumber',
          confidence: 0.90,
          weight: 60.0,
          nutrition: NutritionData(calories: 10, protein: 0.4, carbs: 2.4, fat: 0.1),
        ),
        Ingredient(
          name: 'Dressing',
          confidence: 0.75,
          weight: 30.0,
          nutrition: NutritionData(calories: 80, protein: 0.5, carbs: 2.0, fat: 8.0),
        ),
      ];
    } else if (path.contains('burger')) {
      mockIngredients = [
        Ingredient(
          name: 'Bun',
          confidence: 0.95,
          weight: 100.0,
          nutrition: NutritionData(calories: 250, protein: 8, carbs: 45, fat: 4),
        ),
        Ingredient(
          name: 'Beef Patty',
          confidence: 0.93,
          weight: 150.0,
          nutrition: NutritionData(calories: 350, protein: 26, carbs: 0, fat: 28),
        ),
        Ingredient(
          name: 'Cheese',
          confidence: 0.87,
          weight: 20.0,
          nutrition: NutritionData(calories: 80, protein: 5, carbs: 0.5, fat: 7),
        ),
        Ingredient(
          name: 'Tomato',
          confidence: 0.82,
          weight: 30.0,
          nutrition: NutritionData(calories: 5, protein: 0.3, carbs: 1.2, fat: 0.1),
        ),
      ];
    } else {
      mockIngredients = [
        Ingredient(
          name: 'Food Item 1',
          confidence: 0.80,
          weight: 100.0,
          nutrition: NutritionData(calories: 150, protein: 5, carbs: 20, fat: 6),
        ),
        Ingredient(
          name: 'Food Item 2',
          confidence: 0.75,
          weight: 50.0,
          nutrition: NutritionData(calories: 75, protein: 2, carbs: 10, fat: 3),
        ),
      ];
    }

    final totalNutrition = _calculateTotalNutrition(mockIngredients);

    setState(() {
      _result = FoodDetectionResult(
        imageId: DateTime.now().millisecondsSinceEpoch.toString(),
        ingredients: mockIngredients,
        totalNutrition: totalNutrition,
        timestamp: DateTime.now().toIso8601String(),
        confidenceScore: mockIngredients.isEmpty
            ? 0.0
            : mockIngredients.map((i) => i.confidence).reduce((a, b) => a + b) /
                mockIngredients.length,
      );
      _isAnalyzing = false;
    });
  }

  NutritionData _calculateTotalNutrition(List<Ingredient> ingredients) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var ingredient in ingredients) {
      totalCalories += ingredient.nutrition.calories;
      totalProtein += ingredient.nutrition.protein;
      totalCarbs += ingredient.nutrition.carbs;
      totalFat += ingredient.nutrition.fat;
    }

    return NutritionData(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isAnalyzing ? 'Analyzing' : 'Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (!_isAnalyzing && _result != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showConfidenceInfo(),
            ),
        ],
      ),
      body: _isAnalyzing ? _buildAnalysisView() : _buildResultView(),
    );
  }

  Widget _buildAnalysisView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(widget.imageFile.path),
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: Color(0xFF3F7E03)),
          const SizedBox(height: 20),
          const Text(
            'Analyzing your meal...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Detecting ingredients and calculating nutrition',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null) {
      return const Center(child: Text('No results available'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imageFile.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${(_result!.confidenceScore * 100).toStringAsFixed(0)}% confident',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F7E03), Color(0xFF5BA805)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3F7E03).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Nutrition',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_result!.totalNutrition.calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroChip(
                        'Protein',
                        '${_result!.totalNutrition.protein.toStringAsFixed(1)}g',
                        Icons.egg_outlined,
                      ),
                      _buildMacroChip(
                        'Carbs',
                        '${_result!.totalNutrition.carbs.toStringAsFixed(1)}g',
                        Icons.rice_bowl_outlined,
                      ),
                      _buildMacroChip(
                        'Fat',
                        '${_result!.totalNutrition.fat.toStringAsFixed(1)}g',
                        Icons.water_drop_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detected Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_result!.ingredients.length} items',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _result!.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = _result!.ingredients[index];
                return _buildIngredientCard(ingredient);
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF3F7E03),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3F7E03).withOpacity(0.1),
          child: const Icon(Icons.restaurant, color: Color(0xFF3F7E03), size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                ingredient.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getConfidenceColor(ingredient.confidence).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(ingredient.confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getConfidenceColor(ingredient.confidence),
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${ingredient.weight.toStringAsFixed(0)}g • ${ingredient.nutrition.calories.toStringAsFixed(0)} kcal',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientInfo(
                      'Protein',
                      '${ingredient.nutrition.protein.toStringAsFixed(1)}g',
                      Icons.fitness_center,
                    ),
                    _buildNutrientInfo(
                      'Carbs',
                      '${ingredient.nutrition.carbs.toStringAsFixed(1)}g',
                      Icons.breakfast_dining,
                    ),
                    _buildNutrientInfo(
                      'Fat',
                      '${ingredient.nutrition.fat.toStringAsFixed(1)}g',
                      Icons.opacity,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.85) return Colors.green;
    if (confidence >= 0.70) return Colors.orange;
    return Colors.red;
  }

  void _showConfidenceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detection Confidence'),
        content: Text(
          'Overall confidence: ${(_result!.confidenceScore * 100).toStringAsFixed(1)}%\n\n'
          'This indicates how certain the AI is about the detected ingredients. '
          'Higher confidence means more accurate results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
