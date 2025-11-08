import 'package:flutter/material.dart';
import 'package:snapcal_app/splash_screen.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

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
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // Add both Auth and Storage plugins
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.addPlugin(AmplifyStorageS3());
      
      // Configure Amplify with the configuration
      await Amplify.configure(amplifyconfig);
      
      if (mounted) {
        setState(() {
          _isAmplifyConfigured = true;
          _hasError = false;
        });
      }
      
      safePrint('✅ Amplify configured successfully');
      
    } on AmplifyAlreadyConfiguredException {
      // Amplify is already configured, which is fine
      safePrint('⚠️ Amplify was already configured');
      if (mounted) {
        setState(() {
          _isAmplifyConfigured = true;
          _hasError = false;
        });
      }
    } on AmplifyException catch (e) {
      // Amplify-specific errors
      safePrint('❌ Amplify configuration error: ${e.message}');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.message;
          // Allow app to continue with limited functionality
          _isAmplifyConfigured = true;
        });
      }
    } catch (e) {
      // General errors
      safePrint('❌ An error occurred configuring Amplify: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          // Allow app to continue with limited functionality
          _isAmplifyConfigured = true;
        });
      }
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
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_isAmplifyConfigured) {
      // Still loading
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF3F7E03)),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      // Show error but allow app to continue
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Warning',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Some features may be limited:\n$_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F7E03),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue Anyway'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Successfully configured
    return const SplashScreen();
  }
}
