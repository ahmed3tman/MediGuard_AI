import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/widgets.dart';
import '../../../../core/shared/theme/theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/localization/language_switcher.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../services/auth_service.dart';
import '../../../../navigation/view/screens/main_navigation_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [const LanguageSwitcher()],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  // Logo and title
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).appTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).realTimeMonitoringSystem,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 48),

                  // Name field (only for sign up)
                  if (_isSignUp) ...[
                    CustomTextField(
                      labelText: AppLocalizations.of(context).fullName,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context).pleaseEnterName;
                        }
                        if (value.trim().length < 2) {
                          return AppLocalizations.of(context).nameMinLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email field
                  CustomTextField(
                    labelText: AppLocalizations.of(context).email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context).pleaseEnterEmail;
                      }
                      if (!value.contains('@')) {
                        return AppLocalizations.of(
                          context,
                        ).pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    labelText: AppLocalizations.of(context).password,
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context).pleaseEnterPassword;
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context).passwordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login/Sign up button
                  CustomButton(
                    text: _isSignUp
                        ? AppLocalizations.of(context).createAccount
                        : AppLocalizations.of(context).login,
                    onPressed: _handleAuth,
                    isLoading: _isLoading,
                    width: double.infinity,
                    fontFamily: 'NeoSansArabic',
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),

                  // Switch between login and signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? '${AppLocalizations.of(context).alreadyHaveAccount} '
                            : '${AppLocalizations.of(context).dontHaveAccount} ',
                        style: AppTextStyles.body,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isSignUp
                              ? AppLocalizations.of(context).login
                              : AppLocalizations.of(context).signUp,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isSignUp) {
        final name = _nameController.text.trim();
        await AuthService.createUserWithEmailAndPassword(email, password, name);

        // Show welcome screen for new users
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(userName: name),
            ),
            (route) => false,
          );
        }
      } else {
        await AuthService.signInWithEmailAndPassword(email, password);

        // تشغيل مزامنة البيانات بعد تسجيل الدخول
        try {
          await DataSyncService.syncAllDataOnLogin();
          print('Data sync completed after login');
        } catch (e) {
          print('Data sync failed after login: $e');
          // لا نعرض خطأ للمستخدم لأن تسجيل الدخول نجح
        }

        // Navigate to main app for existing users
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
            (route) => false,
          );
        }
      }

      // Navigation handled above for both cases
    } catch (e) {
      if (mounted) {
        FloatingSnackBar.showError(
          context,
          message: e.toString(),
          position: SnackBarPosition.bottom,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


}
