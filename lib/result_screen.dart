import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ResultScreen extends StatefulWidget {
  final XFile imageFile;

  const ResultScreen({super.key, required this.imageFile});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isAnalyzing = true;
  List<Map<String, dynamic>> _ingredients = [];

  // --- MOCK ANALYSIS FUNCTION ---
  Future<void> _analyzeImage() async {
    // Simulate a network call for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    final String path = widget.imageFile.path.toLowerCase();
    List<Map<String, dynamic>> mockResult = [];

    if (path.contains('salad')) {
      mockResult = [
        {'name': 'Chicken', 'weight': '150g', 'calories': 200},
        {'name': 'Lettuce', 'weight': '50g', 'calories': 10},
        {'name': 'Tomato', 'weight': '80g', 'calories': 15},
        {'name': 'Cucumber', 'weight': '60g', 'calories': 10},
        {'name': 'Dressing', 'weight': '30g', 'calories': 80},
      ];
    } else if (path.contains('burger')) {
      mockResult = [
        {'name': 'Bun', 'weight': '100g', 'calories': 250},
        {'name': 'Beef Patty', 'weight': '150g', 'calories': 350},
        {'name': 'Cheese', 'weight': '20g', 'calories': 80},
        {'name': 'Tomato', 'weight': '30g', 'calories': 5},
      ];
    } else {
      // Default result for any other image
      mockResult = [
        {'name': 'Food Item 1', 'weight': '100g', 'calories': 150},
        {'name': 'Food Item 2', 'weight': '50g', 'calories': 75},
      ];
    }

    setState(() {
      _isAnalyzing = false;
      _ingredients = mockResult;
    });
  }

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  int _getTotalCalories() {
    return _ingredients.fold(0, (sum, item) => sum + (item['calories'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isAnalyzing ? 'Analysis' : 'Result'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isAnalyzing ? _buildAnalysisView() : _buildResultView(),
    );
  }

  // View while "analyzing"
  Widget _buildAnalysisView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.file(File(widget.imageFile.path)),
        const SizedBox(height: 20),
        const Text(
          'Scanning...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const CircularProgressIndicator(color: Color(0xFF3F7E03)),
      ],
    );
  }

  // View with the final result
  Widget _buildResultView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Total Calories
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(widget.imageFile.path)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total Calories ${_getTotalCalories()}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F7E03),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Ingredients List
          const Text(
            'Ingredients',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = _ingredients[index];
                return _buildIngredientTile(ingredient);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientTile(Map<String, dynamic> ingredient) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(ingredient['name']),
      subtitle: Text('Weight: ${ingredient['weight']}'),
      trailing: Text(
        '${ingredient['calories']} kcal',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF3F7E03),
        ),
      ),
    );
  }
}