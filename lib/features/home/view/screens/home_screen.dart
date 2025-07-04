import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/device_bloc.dart';
import '../../bloc/device_event.dart';
import '../../bloc/device_state.dart';
import '../widgets/device_card.dart';
import 'add_device_screen.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/view/screens/profile_screen.dart';
import '../../../auth/view/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Load devices when screen opens, but only if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.isSignedIn) {
        context.read<DeviceBloc>().add(LoadDevices());
      }
    });

    // Listen to auth state changes
    _authSubscription = AuthService.authStateChanges.listen((user) {
      if (user != null && mounted) {
        context.read<DeviceBloc>().add(LoadDevices());
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Time Monitoring'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state is DeviceLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading devices...'),
                ],
              ),
            );
          }

          if (state is DeviceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DeviceBloc>().add(LoadDevices());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DeviceLoaded) {
            if (state.devices.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DeviceBloc>().add(LoadDevices());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.devices.length,
                itemBuilder: (context, index) {
                  return DeviceCard(device: state.devices[index]);
                },
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
        },
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services,
                size: 60,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Devices Added',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first medical device to start monitoring vital signs in real-time.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 16),
            // Demo button for testing
            OutlinedButton(
              onPressed: () {
                // Add a demo device for testing
                context.read<DeviceBloc>().add(
                  const AddDevice('DEMO001', 'Demo Device'),
                );
              },
              child: const Text('Add Demo Device'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = AuthService.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          FutureBuilder<Map<String, dynamic>?>(
            future: user != null ? AuthService.getUserProfile(user.uid) : null,
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              final userName = userProfile?['name'] ?? 'Unknown User';
              final userEmail = userProfile?['email'] ?? 'No email';

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
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    // Navigate immediately without waiting for drawer to close
                    Navigator.of(context)
                        .push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ProfileScreen(),
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  // Scale + Fade transition (no slide from right)
                                  var scaleTween = Tween(begin: 0.8, end: 1.0)
                                      .chain(
                                        CurveTween(curve: Curves.easeOutBack),
                                      );
                                  var fadeTween = Tween(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).chain(CurveTween(curve: Curves.easeOut));

                                  return FadeTransition(
                                    opacity: animation.drive(fadeTween),
                                    child: ScaleTransition(
                                      scale: animation.drive(scaleTween),
                                      child: child,
                                    ),
                                  );
                                },
                          ),
                        )
                        .then((_) {
                          // Close drawer only after navigation
                          Navigator.of(context).pop();
                        });
                  },
                ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings - Coming Soon'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support - Coming Soon'),
                        backgroundColor: Colors.orange,
                      ),
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

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out from your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await AuthService.signOut();

                // Navigate to login screen immediately
                if (mounted) {
                  Navigator.of(context).pop(); // Close loading dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
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
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
