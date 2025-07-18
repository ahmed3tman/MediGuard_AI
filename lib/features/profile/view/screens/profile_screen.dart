import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/view/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  int _devicesCount = 0;
  bool _isLoading = true;
  StreamSubscription? _devicesSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupDevicesListener();
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    super.dispose();
  }

  void _setupDevicesListener() {
    final user = AuthService.currentUser;
    if (user != null) {
      final devicesRef = FirebaseDatabase.instance.ref(
        'users/${user.uid}/devices',
      );

      _devicesSubscription = devicesRef.onValue.listen((event) {
        if (mounted) {
          final data = event.snapshot.value;
          final count = data != null ? (data as Map).length : 0;
          setState(() {
            _devicesCount = count;
          });
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        print('Loading user data for UID: ${user.uid}');

        // Check Firebase connection first
        final isConnected = await AuthService.checkFirebaseConnection();
        print('Firebase connected: $isConnected');

        final profile = await AuthService.getUserProfile(user.uid);
        final devicesCount = await AuthService.getUserDevicesCount(user.uid);

        print('Loaded profile: $profile');
        print('Devices count: $devicesCount');

        if (mounted) {
          setState(() {
            _userProfile = profile;
            _devicesCount = devicesCount; // Load initial count
            _isLoading = false;
          });
        }
      } else {
        print('No current user found');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        FloatingSnackBar.showError(
          context,
          message: 'Error loading profile: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Header
                    GradientContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryLightColor,
                      ],
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          // Profile Avatar
                          ProfileAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            iconColor: AppColors.primaryColor,
                          ),
                          const SizedBox(height: 16),

                          // User Name
                          Text(
                            _userProfile?['name'] ??
                                AuthService.currentUser?.displayName ??
                                'Unknown User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // User Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _userProfile?['isAnonymous'] == true
                                  ? 'Guest User'
                                  : 'Medical Professional',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Devices',
                            value: _devicesCount.toString(),
                            icon: Icons.medical_services,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Account Type',
                            value: _userProfile?['isAnonymous'] == true
                                ? 'Guest'
                                : 'Full',
                            icon: Icons.account_circle,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Profile Information
                    _buildSectionTitle('Account Information'),
                    const SizedBox(height: 16),

                    InfoCard(
                      title: 'Email Address',
                      value:
                          _userProfile?['email'] ??
                          AuthService.currentUser?.email ??
                          'Not available',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 12),

                    InfoCard(
                      title: 'Full Name',
                      value:
                          _userProfile?['name'] ??
                          AuthService.currentUser?.displayName ??
                          'Not available',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),

                    InfoCard(
                      title: 'Member Since',
                      value: _formatDate(_userProfile?['createdAt']),
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 24),

                    // Coming Soon Features
                    _buildSectionTitle('Coming Soon'),
                    const SizedBox(height: 16),

                    ComingSoonCard(
                      title: 'Push Notifications',
                      icon: Icons.notifications,
                    ),
                    const SizedBox(height: 12),
                    ComingSoonCard(title: 'Data Export', icon: Icons.download),
                    const SizedBox(height: 12),
                    ComingSoonCard(title: 'Device Sharing', icon: Icons.share),
                    const SizedBox(height: 12),
                    ComingSoonCard(
                      title: 'Advanced Analytics',
                      icon: Icons.analytics,
                    ),
                    const SizedBox(height: 32),

                    // Sign Out Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: CustomButton(
                        text: 'Sign Out',
                        icon: Icons.logout,
                        onPressed: _handleSignOut,
                        backgroundColor: Colors.red[200],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _handleSignOut() async {
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
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LoadingDialog(message: 'Signing out...'),
        );

        await AuthService.signOut();

        // Navigate to root and clear all previous routes
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
