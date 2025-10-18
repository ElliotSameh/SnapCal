import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'sign_up_screen.dart';
import 'main_navigation_screen.dart';
import 'app_transitions.dart';
import 'user_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSigningIn = true;
      });

      try {
        // Transform email to username the same way as sign-up
        String username = _emailController.text.trim().toLowerCase().replaceAll('@', '_');

        SignInResult result = await Amplify.Auth.signIn(
          username: username,
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          if (result.isSignedIn) {
            // Fetch user information after successful sign-in
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
              email: email ?? _emailController.text.trim(),
            );

            // Navigate to main navigation screen
            Navigator.pushAndRemoveUntil(
              context,
              createRoute(MainNavigationScreen(user: user)),
              (Route<dynamic> route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign in was not completed. Please try again.')),
            );
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          String errorMessage = 'Error signing in: ${e.message}';
          
          if (e.message.contains('UserNotFoundException')) {
            errorMessage = 'No account found with this email. Please sign up first.';
          } else if (e.message.contains('NotAuthorizedException')) {
            errorMessage = 'Incorrect email or password. Please try again.';
          } else if (e.message.contains('UserNotConfirmedException')) {
            errorMessage = 'Please verify your email first.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
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

                  Center(
                    child: Image.asset(
                      'assets/images/logo_un1.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Sign in to continue to your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7E7C7C),
                    ),
                  ),
                  const SizedBox(height: 30),

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
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        print('Forgot Password tapped');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF3F7E03),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                    onPressed: _isSigningIn ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F7E03),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSigningIn
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: Colors.black54),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  createRoute(const SignUpScreen()),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF3F7E03),
                                  fontWeight: FontWeight.bold,
                                ),
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
        child: Image.asset(
          assetPath,
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}
