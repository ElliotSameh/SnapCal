import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:snapcal_app/user_model.dart';
import 'package:snapcal_app/main_navigation_screen.dart';
import 'package:snapcal_app/app_transitions.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _field1 = TextEditingController();
  final TextEditingController _field2 = TextEditingController();
  final TextEditingController _field3 = TextEditingController();
  final TextEditingController _field4 = TextEditingController();
  final TextEditingController _field5 = TextEditingController();
  final TextEditingController _field6 = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _onChanged(String value, TextEditingController current, TextEditingController? next) {
    if (value.length == 1) {
      current.text = value;
      if (next != null) {
        FocusScope.of(context).nextFocus();
      }
    } else if (value.isEmpty) {
      current.text = value;
      FocusScope.of(context).previousFocus();
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final otpCode = _field1.text + _field2.text + _field3.text + _field4.text + _field5.text + _field6.text;

    try {
      // Step 1: Confirm the signup with the verification code
      SignUpResult confirmResult = await Amplify.Auth.confirmSignUp(
        username: widget.username,
        confirmationCode: otpCode,
      );

      if (!confirmResult.isSignUpComplete) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Sign up confirmation failed. Please try again.';
          });
        }
        return;
      }

      // Step 2: Automatically sign in after successful confirmation
      SignInResult signInResult = await Amplify.Auth.signIn(
        username: widget.username,
        password: widget.password,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (signInResult.isSignedIn) {
          // Get user attributes and ID
          final attributes = await Amplify.Auth.fetchUserAttributes();
          final currentUser = await Amplify.Auth.getCurrentUser();
          
          String? name;
          String? email;
          
          // Extract name and email from attributes
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
            email: email ?? widget.email,
          );

          Navigator.pushAndRemoveUntil(
            context,
            createRoute(MainNavigationScreen(user: user)),
            (Route<dynamic> route) => false,
          );
        } else {
          setState(() {
            _errorMessage = 'Sign-in failed after confirmation. Please try signing in manually.';
          });
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void dispose() {
    _field1.dispose();
    _field2.dispose();
    _field3.dispose();
    _field4.dispose();
    _field5.dispose();
    _field6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Verify Email', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Confirmation Code',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a code to ${widget.email}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF7E7C7C)),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOtpField(_field1, _field2),
                  _buildOtpField(_field2, _field3),
                  _buildOtpField(_field3, _field4),
                  _buildOtpField(_field4, _field5),
                  _buildOtpField(_field5, _field6),
                  _buildOtpField(_field6, null),
                ],
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F7E03),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  try {
                    await Amplify.Auth.resendSignUpCode(username: widget.username);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code resent successfully!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to resend code: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Didn\'t receive the code? Resend',
                  style: TextStyle(color: Color(0xFF3F7E03)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(TextEditingController current, TextEditingController? next) {
    return SizedBox(
      width: 45,
      height: 60,
      child: TextFormField(
        controller: current,
        onChanged: (value) => _onChanged(value, current, next),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24),
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF91C788)),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF3F7E03), width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
