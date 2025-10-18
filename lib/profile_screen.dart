import 'package:flutter/material.dart';
import 'user_model.dart';
import 'welcome_screen.dart';
import 'app_transitions.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  // A helper method to handle navigation on log out
  void _handleLogout(BuildContext context) {
    // Navigate to the Welcome screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      createRoute(const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        automaticallyImplyLeading: false, // No back button on profile
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Header
            Center(
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF3F7E03),
                    child: Text(
                      // Display the first letter of the user's name
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Name
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Options List
            ListView(
              shrinkWrap: true, // Important to take only the space it needs
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this list
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
                  onTap: () => _handleLogout(context),
                  isDestructive: true, // To style it differently if needed
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each option row
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