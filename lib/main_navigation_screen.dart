import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_model.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'share_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final User user;

  const MainNavigationScreen({super.key, required this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('📱 App started - loading meals...');
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? mealsJson = prefs.getString('meals');
      
      print('🔍 Raw storage data: $mealsJson');
      
      if (mealsJson != null) {
        final List<dynamic> decoded = json.decode(mealsJson);
        setState(() {
          _meals = decoded.map((item) {
            final meal = Map<String, dynamic>.from(item);
            meal['timestamp'] = DateTime.parse(meal['timestamp']);
            return meal;
          }).toList();
          _isLoading = false;
        });
        print('✅ Loaded ${_meals.length} meals from storage');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('ℹ️ No saved meals found in storage');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading meals: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMeals() async {
    try {
      print('💾 Attempting to save ${_meals.length} meals...');
      final prefs = await SharedPreferences.getInstance();
      
      final mealsToSave = _meals.map((meal) {
        final mealCopy = Map<String, dynamic>.from(meal);
        mealCopy['timestamp'] = meal['timestamp'].toIso8601String();
        return mealCopy;
      }).toList();
      
      final String mealsJson = json.encode(mealsToSave);
      print('📝 Saving JSON: ${mealsJson.substring(0, mealsJson.length > 200 ? 200 : mealsJson.length)}...');
      
      final success = await prefs.setString('meals', mealsJson);
      print('✅ Save result: $success - Saved ${_meals.length} meals to storage');
    } catch (e, stackTrace) {
      print('❌ Error saving meals: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _addMeal(Map<String, dynamic> meal) {
    print('➕ Adding new meal: ${meal['name']}');
    setState(() {
      _meals.add(meal);
    });
    _saveMeals();
    print('✅ Meal added! Total meals: ${_meals.length}');
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3F7E03),
          ),
        ),
      );
    }

    
    final List<Widget> screens = [
      HomeScreen(
        meals: _meals,
        onAddMeal: _addMeal,
        onNavigateToHistory: () => _onTabTapped(1), 
      ),
      HistoryScreen(meals: _meals),
      CameraScreen(onMealSaved: _addMeal),
      ShareScreen(meals: _meals),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3F7E03),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share_outlined),
            activeIcon: Icon(Icons.share),
            label: 'Share',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
