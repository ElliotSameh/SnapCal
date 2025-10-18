import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:snapcal_app/user_model.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> meals;
  final Function(Map<String, dynamic>) onAddMeal;
  final VoidCallback onNavigateToHistory;

  const HomeScreen({
    super.key,
    required this.meals,
    required this.onAddMeal,
    required this.onNavigateToHistory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserAttributes();
  }

  Future<void> _fetchCurrentUserAttributes() async {
    try {
      // Get user attributes
      List<AuthUserAttribute> attributes = await Amplify.Auth.fetchUserAttributes();
      String? name;
      String? email;
      
      // Get user ID using getCurrentUser
      final user = await Amplify.Auth.getCurrentUser();
      String userId = user.userId;

      // Extract name and email from attributes
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == CognitoUserAttributeKey.name) {
          name = attribute.value;
        } else if (attribute.userAttributeKey == CognitoUserAttributeKey.email) {
          email = attribute.value;
        }
      }

      if (mounted) {
        setState(() {
          _currentUser = User(
            id: userId,
            name: name ?? 'User',
            email: email ?? 'No email',
          );
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error fetching user attributes: ${e.message}');
      }
    }
  }

  int _getTotalCalories() {
    int total = 0;
    for (var meal in widget.meals) {
      total += meal['calories'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3F7E03),
          ),
        ),
      );
    }

    final totalCalories = _getTotalCalories();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Color(0xFF000000)),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${_currentUser?.name ?? 'User'}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F7E03), Color(0xFF91C788)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meals.isEmpty ? 'No record yet' : "Today's Intake",
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalCalories Kcal',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onNavigateToHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3F7E03),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Track your Scans'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Your Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMockChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildMockChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: ChartPainter(),
        child: const Center(
          child: Text(
            'Weekly Calorie Intake',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3F7E03)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
