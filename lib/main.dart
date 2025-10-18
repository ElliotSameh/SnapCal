// lib/main.dart
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Your existing splash screen
import 'sign_in_screen.dart'; // We will create this
import 'home_screen.dart'; // We will create this
import 'amplifyconfiguration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This will hold the state of our app
  bool _isAmplifyConfigured = false;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    // Start the configuration process when the app starts
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // Add the plugins
      final auth = AmplifyAuthCognito();
      final api = AmplifyAPI(
          pluginOptions:
              APIPluginOptions(authorizationType: APIAuthorizationType.userPools));

      await Amplify.addPlugins([auth, api]);

      // Configure Amplify with your config file
      await Amplify.configure(amplifyconfig);

      // After configuration, check if the user is already signed in
      await _checkAuthStatus();

      setState(() {
        _isAmplifyConfigured = true;
      });
    } on Exception catch (e) {
      print('An error occurred configuring Amplify: $e');
      // In a real app, you might want to show an error message
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Get the current auth session
      AuthSession session = await Amplify.Auth.fetchAuthSession();
      setState(() {
        // Check if the session is valid and the user is signed in
        _isSignedIn = session.isSignedIn;
      });
    } catch (e) {
      // If there's an error fetching the session, assume user is not signed in
      setState(() {
        _isSignedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapCal',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      // This builder will decide which screen to show
      home: _buildInitialScreen(),
    );
  }

  Widget _buildInitialScreen() {
    if (!_isAmplifyConfigured) {
      // While Amplify is configuring, show the splash screen
      return const SplashScreen();
    }

    // Once configured, check sign-in status
    if (_isSignedIn) {
      // If signed in, go to the home screen
      return const HomeScreen();
    } else {
      // If not signed in, go to the sign-in screen
      return const SignInScreen();
    }
  }
}