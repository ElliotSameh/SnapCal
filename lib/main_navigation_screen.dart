// lib/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'app_transitions.dart';
import 'user_model.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';
import 'share_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final User user; // <-- ADD THIS PROPERTY

  const MainNavigationScreen({super.key, required this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _meals = [];

  void _addMeal(Map<String, dynamic> meal) {
    setState(() {
      _meals.add(meal);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        meals: _meals,
        onAddMeal: _addMeal,
        onNavigateToHistory: () => _onTabTapped(1),
      ),
      ShareScreen(meals: _meals),
      HistoryScreen(meals: _meals),
      const ProfileScreen(),
      const CameraScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
            icon: Icon(Icons.share_outlined),
            activeIcon: Icon(Icons.share),
            label: 'Share',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
        ],
      ),
    );
  }
}