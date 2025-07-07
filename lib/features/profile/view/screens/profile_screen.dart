import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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

    // Listen for navigation back to this screen to refresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureUserProfileAndLoad();
    });
  }

  Future<void> _ensureUserProfileAndLoad() async {
    await AuthService.ensureUserProfile();
    await _loadUserData();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue[600],
                            ),
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
                          child: _buildStatCard(
                            'Devices',
                            _devicesCount.toString(),
                            Icons.medical_services,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Account Type',
                            _userProfile?['isAnonymous'] == true
                                ? 'Guest'
                                : 'Full',
                            Icons.account_circle,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Profile Information
                    _buildSectionTitle('Account Information'),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      'Email Address',
                      _userProfile?['email'] ??
                          AuthService.currentUser?.email ??
                          'Not available',
                      Icons.email,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      'Full Name',
                      _userProfile?['name'] ??
                          AuthService.currentUser?.displayName ??
                          'Not available',
                      Icons.person,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoCard(
                      'Member Since',
                      _formatDate(_userProfile?['createdAt']),
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 24),

                    // Coming Soon Features
                    _buildSectionTitle('Coming Soon'),
                    const SizedBox(height: 16),

                    _buildComingSoonCard(
                      'Push Notifications',
                      Icons.notifications,
                    ),
                    const SizedBox(height: 12),
                    _buildComingSoonCard('Data Export', Icons.download),
                    const SizedBox(height: 12),
                    _buildComingSoonCard('Device Sharing', Icons.share),
                    const SizedBox(height: 12),
                    _buildComingSoonCard('Advanced Analytics', Icons.analytics),
                    const SizedBox(height: 32),

                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleSignOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out from your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
