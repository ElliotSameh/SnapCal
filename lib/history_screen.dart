import 'dart:io';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> meals;

  const HistoryScreen({super.key, required this.meals});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  List<Map<String, dynamic>> _getMealsForDate(DateTime date) {
    final selectedDay = DateTime(date.year, date.month, date.day);
    return widget.meals.where((meal) {
      final mealDay = DateTime(
        meal['timestamp'].year,
        meal['timestamp'].month,
        meal['timestamp'].day,
      );
      return mealDay.isAtSameMomentAs(selectedDay);
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showMealDetails(Map<String, dynamic> meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Image
              if (meal['imagePath'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(meal['imagePath']),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),

              // Meal name
              Text(
                meal['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '${DateTime.parse(meal['timestamp'].toString()).hour}:${DateTime.parse(meal['timestamp'].toString()).minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Nutrition summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3F7E03), Color(0xFF5BA805)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutritionItem(
                      'Calories',
                      '${meal['calories']}',
                      'kcal',
                      Icons.local_fire_department,
                    ),
                    _buildNutritionItem(
                      'Protein',
                      '${meal['protein']?.toStringAsFixed(1) ?? '0'}',
                      'g',
                      Icons.egg_outlined,
                    ),
                    _buildNutritionItem(
                      'Carbs',
                      '${meal['carbs']?.toStringAsFixed(1) ?? '0'}',
                      'g',
                      Icons.rice_bowl_outlined,
                    ),
                    _buildNutritionItem(
                      'Fat',
                      '${meal['fat']?.toStringAsFixed(1) ?? '0'}',
                      'g',
                      Icons.water_drop_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ingredients section
              if (meal['ingredients'] != null && (meal['ingredients'] as List).isNotEmpty) ...[
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...(meal['ingredients'] as List).map((ingredient) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF3F7E03).withOpacity(0.1),
                        child: const Icon(
                          Icons.restaurant,
                          color: Color(0xFF3F7E03),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        ingredient['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${ingredient['weight']?.toStringAsFixed(0) ?? '0'}g • ${ingredient['calories']?.toStringAsFixed(0) ?? '0'} kcal',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${((ingredient['confidence'] ?? 0) * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
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

  @override
  Widget build(BuildContext context) {
    final mealsForSelectedDate = _getMealsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('History', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF3F7E03).withOpacity(0.1),
              border: const Border(
                bottom: BorderSide(color: Color(0xFF3F7E03), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Previous Meals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Row(
                    children: [
                      Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3F7E03),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF3F7E03),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.meals.isEmpty
                ? _buildOverallEmptyState()
                : mealsForSelectedDate.isEmpty
                    ? _buildEmptyStateForDate()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        itemCount: mealsForSelectedDate.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final meal = mealsForSelectedDate[index];
                          return _buildMealListItem(meal);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            'No meal history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start scanning your meals to see your history here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateForDate() {
    return const Center(
      child: Text(
        'No meals recorded for this day.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMealListItem(Map<String, dynamic> meal) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      leading: meal['imagePath'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(meal['imagePath']),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          : const CircleAvatar(
              backgroundColor: Color(0xFF3F7E03),
              child: Icon(Icons.restaurant, color: Colors.white),
            ),
      title: Text(
        meal['name'],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${DateTime.parse(meal['timestamp'].toString()).hour}:${DateTime.parse(meal['timestamp'].toString()).minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${meal['calories']} Kcal',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF3F7E03),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Colors.grey,
          ),
        ],
      ),
      onTap: () => _showMealDetails(meal),
    );
  }
}
