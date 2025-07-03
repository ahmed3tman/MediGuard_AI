// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// مش مستخدممممممممممم - غير مستخدم في المشروع
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spider_doctor/features/auth/view/screen/login_screen.dart';
import 'package:spider_doctor/features/home/view/screen/home.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // إظهار loading أثناء التحقق من حالة المصادقة
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // لو فيه user مسجل دخول
        if (snapshot.hasData && snapshot.data != null) {
          print("User authenticated: ${snapshot.data?.email}");
          return const HomeScreen();
        }
        // لو مفيش user مسجل دخول
        else {
          print("No user authenticated");
          return const LoginScreen();
        }
      },
    );
  }
}
