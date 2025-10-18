import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'app_transitions.dart';
import 'user_model.dart';
import 'main_navigation_screen.dart';
import 'sign_in_screen.dart';
import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isSigningUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms and conditions.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSigningUp = true;
      });

      try {
        // Create a unique username from the email
        String username = _emailController.text.trim().toLowerCase().replaceAll('@', '_');

        Map<CognitoUserAttributeKey, String> userAttributes = {
          CognitoUserAttributeKey.email: _emailController.text.trim(),
          CognitoUserAttributeKey.name: _nameController.text.trim(),
        };

        SignUpResult result = await Amplify.Auth.signUp(
          username: username,
          password: _passwordController.text.trim(),
          options: SignUpOptions(userAttributes: userAttributes),
        );

        if (mounted) {
          setState(() {
            _isSigningUp = false;
          });

          if (!result.isSignUpComplete) {
            // Navigate to OTP screen with email, password, and username
            Navigator.of(context).pushReplacement(
              createRoute(OtpScreen(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
                username: username,
              )),
            );
          } else {
            // This case happens if sign-up is complete without confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up complete! Please sign in.')),
            );
            Navigator.of(context).pushReplacement(createRoute(const SignInScreen()));
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          setState(() {
            _isSigningUp = false;
          });
          String errorMessage = 'An error occurred during sign up.';
          if (e.message.contains('UsernameExistsException')) {
            errorMessage = 'An account with this email already exists. Please sign in.';
          } else if (e.message.contains('InvalidPasswordException')) {
            errorMessage = 'Password does not meet the policy requirements.';
          } else if (e.message.contains('InvalidParameterException')) {
            errorMessage = e.message;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSigningUp = false;
          });
        }
      }
    }
  }

  Future<void> _handleSocialSignIn(AuthProvider provider) async {
    try {
      await Amplify.Auth.signInWithWebUI(provider: provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully signed in with ${provider.name}!')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Image.asset('assets/images/logo.png', height: 100)),
                  const SizedBox(height: 20),
                  const Text(
                    'Join SnapCal today!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a SnapCal account to track your meal calories.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF7E7C7C)),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Image.asset('assets/images/user.png', width: 24),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF91C788)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF3F7E03), width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      prefixIcon: Image.asset('assets/images/email.png', width: 24),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF91C788)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF3F7E03), width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Image.asset('assets/images/password.png', width: 24),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF91C788)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF3F7E03), width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreedToTerms = value!;
                          });
                        },
                        activeColor: const Color(0xFF3F7E03),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    print('Privacy Policy tapped');
                                  },
                                  child: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(color: Color(0xFF3F7E03), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    print('Terms of Use tapped');
                                  },
                                  child: const Text(
                                    'Term of Use',
                                    style: TextStyle(color: Color(0xFF3F7E03), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton('assets/images/google_logo.png', AuthProvider.google),
                      _buildSocialButton('assets/images/apple_logo.png', AuthProvider.apple),
                      _buildSocialButton('assets/images/x_logo.png', AuthProvider.twitter),
                      _buildSocialButton('assets/images/facebook_logo.png', AuthProvider.facebook),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isSigningUp ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F7E03),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSigningUp
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(color: Colors.black54),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, createRoute(const SignInScreen()));
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(color: Color(0xFF3F7E03), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath, AuthProvider provider) {
    return InkWell(
      onTap: () => _handleSocialSignIn(provider),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(assetPath, width: 32, height: 32),
      ),
    );
  }
}
