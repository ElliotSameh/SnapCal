import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amplify_flutter/amplify_flutter.dart'; 
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'; 
import 'sign_up_screen.dart';
import 'sign_in_screen.dart';
import 'app_transitions.dart';
import 'main_navigation_screen.dart';
import 'user_model.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // CHANGE: Added a helper function to handle social sign-in(test baiad beshe)
  Future<void> _handleSocialSignIn(BuildContext context, AuthProvider provider) async {
    try {
      // This opens a web view for the user to sign in with the selected provider
      SignInResult result = await Amplify.Auth.signInWithWebUI(provider: provider);
      
      // After successful sign-in, the main.dart logic will detect the session change
      // and navigate the user to the correct screen automatically.
      // For now, we can just show a success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed in with ${provider.name}!')),
      );

    } on AuthException catch (e) {
      // Handle sign-in errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo_un1.png',
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 50),
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
                    const Text(
                      'Continue with',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // CHANGE: Updated social buttons to call our new handler
                        _buildSocialButton(context, 'assets/images/google_logo.png', AuthProvider.google),
                        _buildSocialButton(context, 'assets/images/apple_logo.png', AuthProvider.apple),
                        _buildSocialButton(context, 'assets/images/x_logo.png', AuthProvider.twitter), // Note: X/Twitter might need extra setup in Cognito
                        _buildSocialButton(context, 'assets/images/facebook_logo.png', AuthProvider.facebook), // Note: Facebook might need extra setup in Cognito
                      ],
                    ),
                    const SizedBox(height: 40),
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
                        // CHANGE: Replaced the temporary mock logic with navigation to the SignInScreen
                        onPressed: () {
                          Navigator.push(context, createRoute(const SignInScreen()));
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
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: GestureDetector(
                  onTap: () {
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

  // CHANGE: Updated the helper widget to accept context and provider
  Widget _buildSocialButton(BuildContext context, String assetPath, AuthProvider provider) {
    return InkWell(
      onTap: () => _handleSocialSignIn(context, provider), // Call the new handler
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