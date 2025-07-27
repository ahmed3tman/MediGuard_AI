import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spider_doctor/features/profile/view/widgets/coming_soon_card.dart';
import 'package:spider_doctor/features/profile/view/widgets/stat_card.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/services/auth_service.dart';

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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                AppLocalizations.of(context).unknownUser,
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
                                  ? AppLocalizations.of(context).guestUser
                                  : AppLocalizations.of(
                                      context,
                                    ).medicalProfessional,
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
                            title: AppLocalizations.of(context).devices,
                            value: _devicesCount.toString(),
                            icon: Icons.medical_services,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: AppLocalizations.of(context).accountType,
                            value: _userProfile?['isAnonymous'] == true
                                ? AppLocalizations.of(context).guest
                                : AppLocalizations.of(context).full,
                            icon: Icons.account_circle,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Profile Information
                    _buildSectionTitle(
                      AppLocalizations.of(context).accountInformation,
                    ),
                    const SizedBox(height: 16),

                    InfoCard(
                      title: AppLocalizations.of(context).emailAddress,
                      value:
                          _userProfile?['email'] ??
                          AuthService.currentUser?.email ??
                          AppLocalizations.of(context).notAvailable,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 12),

                    InfoCard(
                      title: AppLocalizations.of(context).fullName,
                      value:
                          _userProfile?['name'] ??
                          AuthService.currentUser?.displayName ??
                          AppLocalizations.of(context).notAvailable,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),

                    InfoCard(
                      title: AppLocalizations.of(context).memberSince,
                      value: _formatDate(_userProfile?['createdAt']),
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 24),

                    // Coming Soon Features
                    _buildSectionTitle(AppLocalizations.of(context).comingSoon),
                    const SizedBox(height: 16),

                    ComingSoonCard(
                      title: AppLocalizations.of(context).pushNotifications,
                      icon: Icons.notifications,
                    ),
                    const SizedBox(height: 12),
                    ComingSoonCard(
                      title: AppLocalizations.of(context).dataExport,
                      icon: Icons.download,
                    ),
                    const SizedBox(height: 12),
                    ComingSoonCard(
                      title: AppLocalizations.of(context).deviceSharing,
                      icon: Icons.share,
                    ),
                    const SizedBox(height: 12),
                    ComingSoonCard(
                      title: AppLocalizations.of(context).advancedAnalytics,
                      icon: Icons.analytics,
                    ),
                    const SizedBox(height: 40),
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
    if (timestamp == null) return AppLocalizations.of(context).unknown;

    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return AppLocalizations.of(context).unknown;
    }
  }
}
