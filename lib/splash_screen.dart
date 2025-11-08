import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'onboarding_screen1.dart';
import 'main_navigation_screen.dart';
import 'user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash screen display
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      // Check if user is already signed in
      final session = await Amplify.Auth.fetchAuthSession();
      
      if (!mounted) return;

      if (session.isSignedIn) {
        // User is signed in, fetch user info and go to main screen
        safePrint('✅ User already signed in, fetching user info');
        
        // Get user attributes
        final attributes = await Amplify.Auth.fetchUserAttributes();
        final currentUser = await Amplify.Auth.getCurrentUser();
        
        String? name;
        String? email;
        
        for (var attribute in attributes) {
          if (attribute.userAttributeKey == CognitoUserAttributeKey.name) {
            name = attribute.value;
          } else if (attribute.userAttributeKey == CognitoUserAttributeKey.email) {
            email = attribute.value;
          }
        }
        
        final user = User(
          id: currentUser.userId,
          name: name ?? 'User',
          email: email ?? 'No email',
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(user: user),
          ),
        );
      } else {
        // User not signed in, go to onboarding
        safePrint('ℹ️ User not signed in, navigating to onboarding');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen1()),
        );
      }
    } catch (e) {
      safePrint('⚠️ Error checking auth status: $e');
      
      if (!mounted) return;
      
      // If error, go to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen1()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 340,
              height: 340,
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: Text(
                'MHM Vision',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF616161),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
