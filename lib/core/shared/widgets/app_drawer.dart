import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:spider_doctor/core/shared/widgets/floating_snackbar.dart';
import 'package:spider_doctor/features/auth/services/auth_service.dart';
import 'package:spider_doctor/features/settings/view/screens/settings_screen.dart';
import 'package:spider_doctor/features/buy_your_device/view/screens/buy_ur_device_screen.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'about_developer_links.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Widget _getSocialIcon(String icon) {
    switch (icon) {
      case 'linkedin':
        return Icon(IconlyBold.profile, color: Colors.blue, size: 22);
      case 'github':
        return Icon(IconlyBold.work, color: Colors.black, size: 22);
      case 'tiktok':
        return Icon(IconlyBold.play, color: Colors.pink, size: 22);
      case 'instagram':
        return Icon(IconlyBold.camera, color: Colors.purple, size: 22);
      case 'youtube':
        return Icon(IconlyBold.video, color: Colors.red, size: 22);
      default:
        return Icon(IconlyBold.paper, size: 22);
    }
  }

  Widget _buildSquareAvatar(String? photoUrl) {
    final double size = 56;
    final borderRadius = BorderRadius.circular(12);

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.person, size: 36, color: Colors.blue[600]),
            );
          },
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.person, size: 36, color: Colors.blue[600]),
    );
  }

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
                  userProfile?['name'] ??
                  user?.displayName ??
                  AppLocalizations.of(context).unknownUser;
              final userEmail =
                  userProfile?['email'] ??
                  user?.email ??
                  AppLocalizations.of(context).noEmail;

              print('Drawer - User profile: $userProfile');
              print('Drawer - User name: $userName, email: $userEmail');

              final photoUrl =
                  userProfile?['photoUrl'] ??
                  userProfile?['imageUrl'] ??
                  user?.photoURL;

              return Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSquareAvatar(photoUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                  title: Text(AppLocalizations.of(context).dashboard),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: Text(AppLocalizations.of(context).buyYourDevice),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BuyDeviceScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(AppLocalizations.of(context).settings),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.help),
                  title: Text(AppLocalizations.of(context).helpSupport),
                  onTap: () {
                    Navigator.of(context).pop();
                    FloatingSnackBar.showWarning(
                      context,
                      message: AppLocalizations.of(context).comingSoon,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(AppLocalizations.of(context).about),
                  onTap: () {
                    Navigator.of(context).pop();
                    FloatingSnackBar.showWarning(
                      context,
                      message: AppLocalizations.of(context).comingSoon,
                    );
                  },
                ),
                // about developer
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppLocalizations.of(context).aboutDeveloper),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        contentPadding: const EdgeInsets.fromLTRB(
                          24,
                          24,
                          24,
                          8,
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).aboutDeveloperName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).aboutDeveloperTitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      textAlign: TextAlign.center,
                                      AppLocalizations.of(
                                        context,
                                      ).aboutDeveloperFaculty,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      ).aboutDeveloperDepartment,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      ).aboutDeveloperUniversity,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),
                              ...AboutDeveloperLinks.links.map(
                                (link) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      final uri = Uri.parse(link.url);
                                      try {
                                        final launched = await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                        if (!launched && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).error,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).error,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        _getSocialIcon(link.icon),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            link.url,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context).cancel),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout at bottom
          const Divider(),
          SizedBox(height: 40),
          // ListTile(
          //   leading: const Icon(Icons.logout, color: Colors.red),
          //   title: Text(
          //     AppLocalizations.of(context).signOut,
          //     style: const TextStyle(color: Colors.red),
          //   ),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     _showLogoutConfirmation();
          //   },
          // ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  //   void _showLogoutConfirmation() async {
  //     final shouldSignOut = await ConfirmationDialog.show(
  //       context,
  //       title: AppLocalizations.of(context).signOut,
  //       content: AppLocalizations.of(context).signOutConfirm,
  //       confirmText: AppLocalizations.of(context).signOut,
  //       cancelText: AppLocalizations.of(context).cancel,
  //       confirmColor: Colors.red,
  //     );

  //     if (shouldSignOut == true) {
  //       try {
  //         // Show loading dialog
  //         showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (context) =>
  //               LoadingDialog(message: AppLocalizations.of(context).signingOut),
  //         );

  //         await AuthService.signOut();

  //         // Navigate to login screen immediately
  //         if (mounted) {
  //           Navigator.of(context).pop(); // Close loading dialog
  //           Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (context) => const LoginScreen()),
  //             (route) => false,
  //           );
  //         }
  //       } catch (e) {
  //         if (mounted) {
  //           Navigator.of(context).pop(); // Close loading dialog
  //           FloatingSnackBar.showError(
  //             context,
  //             message: 'Error signing out: ${e.toString()}',
  //           );
  //         }
  //       }
  //     }
  //   }
  // }
}
