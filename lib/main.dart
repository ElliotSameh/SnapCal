import 'package:flutter/material.dart';
import 'package:snapcal_app/splash_screen.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyconfig);
      setState(() {
        _isAmplifyConfigured = true;
      });
    } catch (e) {
      print('An error occurred configuring Amplify: $e');
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
      home: _isAmplifyConfigured ? const SplashScreen() : const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3F7E03)),
        ),
      ),
    );
  }
}
