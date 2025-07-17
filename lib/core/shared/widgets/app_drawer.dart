import 'package:flutter/material.dart';
import 'package:spider_doctor/core/shared/widgets/dialog_widgets.dart';
import 'package:spider_doctor/core/shared/widgets/floating_snackbar.dart';
import 'package:spider_doctor/core/shared/widgets/loading_widgets.dart';
import 'package:spider_doctor/features/auth/services/auth_service.dart';
import 'package:spider_doctor/features/auth/view/screens/login_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          FutureBuilder<Map<String, dynamic>?>(
            future: user != null ? AuthService.getUserProfile(user.uid) : null,
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              final userName =
                  userProfile?['name'] ?? user?.displayName ?? 'Unknown User';
              final userEmail =
                  userProfile?['email'] ?? user?.email ?? 'No email';

              print('Drawer - User profile: $userProfile');
              print('Drawer - User name: $userName, email: $userEmail');

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue[600]),
                ),
              );
            },
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('My Devices'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                    FloatingSnackBar.showWarning(
                      context,
                      message: 'Settings - Coming Soon',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.of(context).pop();
                    FloatingSnackBar.showWarning(
                      context,
                      message: 'Help & Support - Coming Soon',
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout at bottom
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pop();
              _showLogoutConfirmation();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() async {
    final shouldSignOut = await ConfirmationDialog.show(
      context,
      title: 'Sign Out',
      content: 'Are you sure you want to sign out from your account?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );

    if (shouldSignOut == true) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LoadingDialog(message: 'Signing out...'),
        );

        await AuthService.signOut();

        // Navigate to login screen immediately
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          FloatingSnackBar.showError(
            context,
            message: 'Error signing out: ${e.toString()}',
          );
        }
      }
    }
  }
}
