import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'app_transitions.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Image.asset(
                  'assets/images/onboarding_fruits.gif',
                ),
              ),
              const SizedBox(height: 40),
              // Text
              
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                    style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.4,
                    ),
                    children: [
                    const TextSpan(text: 'Track Your '),
                    const TextSpan(
                        text: 'Calorie',
                        style: TextStyle(
                        color: Color(0xFF0F57FF),
                        ),
                    ),
                    const TextSpan(text: ',\nTransform Your '),
                    TextSpan(
                        text: 'Health',
                        style: TextStyle(
                        color: Color(0xFF3F7E03),
                        ),
                    ),
                    ],
                ),
                ),
                const SizedBox(height: 6), // <-- ADDED: Spacing between the two text blocks

                // Subtitle Text
                const Text(
                'Stay healthy by tracking every meal',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, // I chose 14 for readability, you can change to 12
                    color: Color(0xFF7E7C7C), // The requested grey color
                ),
              ),


              const Spacer(flex: 1),
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, createRoute(const WelcomeScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F7E03), // UPDATED: New button color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}