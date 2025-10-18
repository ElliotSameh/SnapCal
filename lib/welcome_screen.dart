import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sign_up_screen.dart'; // Import Sign Up screen
import 'sign_in_screen.dart'; // Import Sign In screen
import 'app_transitions.dart';
import 'main_navigation_screen.dart';
import 'user_model.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            // Use spaceBetween to push content to top and bottom
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOP SECTION: Main Content
              // We wrap the main content in a Column to keep it together
              // and use an Expanded widget to make it fill the middle space.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo_un1.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Title
                    const Text(
                      "Let's get started!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Social Login Buttons
                    const Text(
                      'Continue with',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton('assets/images/google_logo.png'),
                        _buildSocialButton('assets/images/apple_logo.png'),
                        _buildSocialButton('assets/images/x_logo.png'),
                        _buildSocialButton('assets/images/facebook_logo.png'),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // OR Divider
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('OR', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Sign Up and Sign In Buttons (FULL WIDTH)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, createRoute(const SignUpScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F7E03),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Sign up'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        
                        //replace it later
                        // onPressed: () {
                        //   Navigator.push(context, createRoute(const SignInScreen()));
                          
                        // },
                        onPressed: () {
                          // TEMPORARY: Bypass login and go straight to the main app with a mock user
                          final mockUser = User(name: 'Guest', email: 'guest@example.com');
                          Navigator.pushAndRemoveUntil(
                            context,
                            createRoute(MainNavigationScreen(user: mockUser)),
                            (Route<dynamic> route) => false,
                          );
                        },


                        
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3F7E03),
                          side: const BorderSide(color: Color(0xFF3F7E03)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Sign in'),
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM SECTION
              // Added some padding to lift the text off the bottom edge
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Navigate to Privacy Policy & Terms screen
                    print('Privacy Policy & Term of Use tapped');
                  },
                  child: const Text(
                    'Privacy Policy & Term of Use',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7E7C7C),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build social login buttons
  Widget _buildSocialButton(String assetPath) {
    return InkWell(
      onTap: () {
        print('Social button tapped: $assetPath');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          assetPath,
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}