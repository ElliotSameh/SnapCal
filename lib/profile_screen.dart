import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:snapcal_app/user_model.dart';
import 'package:snapcal_app/welcome_screen.dart';
import 'package:snapcal_app/app_transitions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserAttributes();
  }

  Future<void> _fetchCurrentUserAttributes() async {
    try {
      // Get user attributes
      List<AuthUserAttribute> attributes = await Amplify.Auth.fetchUserAttributes();
      String? name;
      String? email;
      
      // Get user ID using getCurrentUser
      final user = await Amplify.Auth.getCurrentUser();
      String userId = user.userId;

      // Extract name and email from attributes
      for (var attribute in attributes) {
        if (attribute.userAttributeKey == CognitoUserAttributeKey.name) {
          name = attribute.value;
        } else if (attribute.userAttributeKey == CognitoUserAttributeKey.email) {
          email = attribute.value;
        }
      }

      if (mounted) {
        setState(() {
          _currentUser = User(
            id: userId,
            name: name ?? 'User',
            email: email ?? 'No email',
          );
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error fetching user attributes: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load profile: ${e.message}')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await Amplify.Auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          createRoute(const WelcomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3F7E03)),
        ),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(
          child: Text('Could not load user profile.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF3F7E03),
                    child: Text(
                      _currentUser!.name.isNotEmpty ? _currentUser!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser!.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOptionTile(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit Profile tapped')),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.lock,
                  title: 'Privacy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy tapped')),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support tapped')),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  onTap: _handleLogout,
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.redAccent : const Color(0xFF3F7E03),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
