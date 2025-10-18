import 'package:flutter/material.dart';

class ShareScreen extends StatelessWidget {
  final List<Map<String, dynamic>> meals;

  const ShareScreen({super.key, required this.meals});

  // Helper to calculate total calories
  int _getTotalCalories() {
    int total = 0;
    for (var meal in meals) {
      total += meal['calories'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Check if there are any meals to share
    if (meals.isEmpty) {
      // --- UPDATED EMPTY STATE ---
      return Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          title: const Text('Share', style: TextStyle(color: Colors.black)),
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty State Icon
              Image(
                image: AssetImage('assets/images/empty.png'),
                width: 150,
                height: 150,
              ),
              SizedBox(height: 24),

              // Empty State Text
              Text(
                'Nothing to share yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 8),

              Text(
                'Scan a meal to start sharing your progress!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If there are meals, build the shareable content (this part is unchanged)
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Share', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shareable Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Placeholder for meal image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/onboarding_fruits.gif', // Use a placeholder image
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'My Healthy Meal',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Calories ${_getTotalCalories()}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF3F7E03),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // List of meals
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meals.map((meal) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '• ${meal['name']} (${meal['calories']} Kcal)',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Social Share Buttons
            const Text(
              'Share your progress',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialShareButton('assets/images/instagram_logo.png'),
                _buildSocialShareButton('assets/images/facebook_logo.png'),
                _buildSocialShareButton('assets/images/twitter_logo.png'),
                _buildSocialShareButton('assets/images/whatsapp_logo.png'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper for social share buttons
  Widget _buildSocialShareButton(String assetPath) {
    return InkWell(
      onTap: () {
        // TODO: Implement actual sharing logic
        print('Share to $assetPath');
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Image.asset(assetPath, width: 30, height: 30),
      ),
    );
  }
}