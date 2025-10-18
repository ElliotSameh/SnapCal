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

  // A helper function to get meals for a specific date
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

  // Helper to pick a new date
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

  @override
  Widget build(BuildContext context) {
    final mealsForSelectedDate = _getMealsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('History', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- REDESIGNED DATE HEADER ---
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
          // --- REDESIGNED MEAL LIST ---
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

  // Widget for the overall empty state (no meals ever scanned)
  Widget _buildOverallEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/images/empty.png'),
            width: 150,
            height: 150,
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

  // Widget for the empty state when no meals are found for the selected date
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

  // --- REDESIGNED MEAL LIST ITEM ---
  Widget _buildMealListItem(Map<String, dynamic> meal) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      title: Text(
        meal['name'],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        '${meal['calories']} Kcal',
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF3F7E03),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}